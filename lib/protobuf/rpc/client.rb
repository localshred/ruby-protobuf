require 'eventmachine'
require 'protobuf/common/logger'
require 'protobuf/rpc/client_connection'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'
require 'timeout'

module Protobuf
  module Rpc
    class Client
      include Protobuf::Logger::LogMethods
      
      attr_reader :error, :options, :do_block
      
      def initialize options={}
        raise "Invalid client configuration. Service must be defined." if !options[:service] || options[:service].nil?
        @error = {}
        @options = ClientConnection::DEFAULT_OPTIONS.merge(options)
        @success_callback = nil
        @failure_callback = nil
        @do_block = !@options[:async]
        log_debug '[client] Initialized with options: %s' % @options.inspect
      end
      
      def on_success &success_callback
        @success_callback = success_callback
      end
      
      def on_failure &failure_callback
        @failure_callback = failure_callback
      end
      
      # Intercept calls to service rpcs
      def method_missing method, *params, &client_callback
        service = @options[:service]
        unless service.rpcs[service].keys.include?(method)
          log_error '[client] %s#%s not rpc method, passing to super' % [service.name, method.to_s]
          super method, *params
        else
          log_debug '[client] %s#%s' % [service.name, method.to_s]
          rpc = service.rpcs[service][method.to_sym]
          @options[:request_type] = rpc.request_type
          log_debug '[client] Request Type: %s' % @options[:request_type].name
          @options[:response_type] = rpc.response_type
          log_debug '[client] Response Type: %s' % @options[:response_type].name
          @options[:method] = method.to_s
          @options[:request] = params[0].is_a?(Hash) ? @options[:request_type].new(params[0]) : params[0]
          log_debug '[client] Request Data: %s' % @options[:request].inspect
          
          #### TODO remove first part here once we are able to convert everything to the new event based way of handling success/failure
          unless client_callback.nil?
            if client_callback.arity == 2
              @options[:version] = 1.0
              log_debug '[client] version = 1.0'
              
              deprecation_warning = %Q{
##################################################
# Deprecation Warning - Upgrade Client Callbacks
# ==============================================
# 
# You are attempting to use two block arguments (presumably client and response)
# in your client callback for the call to #{@options[:service].name}.client.#{@options[:method]}.
# 
# The next version of ruby-protobuf will completely remove the 
# style of client calls that accepts two arguments in favor of a more explicit evented approach.
# 
# You should refactor the code before upgrading to the next version of this gem. An example of callback style v1:
# 
#     #{@options[:service]}.client.#{@options[:method]}(request) do |client, response|
#       if client.failed?
#         # do something with client.error or client.message
#       else
#         # do something with response
#       end
#     end
# 
# Refactor the previous example of callback style v1 usage to v2 with the following:
# 
#     #{@options[:service]}.client.#{@options[:method]}(request) do |c|
#       c.on_failure do |error|
#         # do something with error.code or error.message
#       end
#       c.on_success do |response|
#         # do something with response
#       end
#     end
# 
##################################################
}
              log_warn deprecation_warning
              STDOUT.puts deprecation_warning unless Protobuf::Logger.configured?
              
              on_success {|res| client_callback.call(self, res) }
              on_failure {|err| client_callback.call(self, nil) }
            else
              ### TODO Replace block above with this once all client definitions use new event driven approach
              # Call client to setup on_success and on_failure event callbacks
              @options[:version] = 2.0
              log_debug '[client] version = 2.0'
              client_callback.call(self)
            end
          else
            log_debug '[client] no callbacks given'
          end
      
          call_rpc
        end
      end

      # Controller error/failure methods
      # TODO remove these when v1 is gone
      def failed?
        !@error.nil? and !@error[:code].nil?
      end
      
      def error
        @error[:message] if failed?
      end
      
      def error_reason
        Protobuf::Socketrpc::ErrorReason.name_by_value(@error[:code]).to_s if failed?
      end
      
      def error_message
        "%s: %s" % [error_reason, error] if failed?
      end
       
    private
      
      def call_rpc
        ### If a failure callback was set, just use that as a direct assignment
        ### otherwise implement one here that simply throws an exception, since we
        ### don't want to swallow the black holes
        ### TODO- remove "else" portion below once 1.0 is gone
        if @options[:version] == 2.0
          if @failure_callback.nil?
            ensure_callback = proc do |error|
              raise '%s: %s' % [error.code.name, error.message]
            end
          else
            ensure_callback = @failure_callback
          end
        else
          ensure_callback = proc do |error|
            @error = error
            @failure_callback ? @failure_callback.call(self) : raise('%s: %s' % [error.code.name, error.message])
          end
        end
        
        Thread.new { EM.run } unless EM.reactor_running?
        
        EM.schedule do
          log_debug '[client] Scheduling client connection to be created on next tick'
          connection = ClientConnection.connect @options, &ensure_callback
          connection.on_success &@success_callback unless @success_callback.nil?
          connection.on_failure &ensure_callback
          connection.on_complete { @do_block = false } if @do_block
          log_debug '[client] Connection scheduled'
        end
        
        return unless @do_block
        
        begin
          Timeout.timeout(@options[:timeout]) {
            sleep 0.5 while @do_block
            true
          }
        rescue
          error = ClientError.new
          error.code = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
          error.message = 'Client timeout of %d seconds expired' % @options[:timeout]
          ensure_callback.call(error)
        end
      end
      
    end
  end
end