require 'eventmachine'
require 'protobuf/rpc/client_connection'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'

module Protobuf
  module Rpc
    class Client
      
      # attr_reader :service, :method, :host, :port, :request, :response, :rpc
      
      def initialize options={}
        raise "Invalid client configuration. Service must be defined." if !options[:service] || options[:service].nil?
        @error = {}
        @options = ClientConnection::DEFAULT_OPTIONS.merge(options)
        @success_callback = nil
        @failure_callback = nil
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
        unless service.rpcs[service].keys.include? method
          super method, *params
        else
          rpc = service.rpcs[service][method.to_sym]
          @options[:request_type] = rpc.request_type
          @options[:response_type] = rpc.response_type
          @options[:method] = method.to_s
          @options[:request] = params[0]
          
          #### TODO remove first part here once we are able to convert everything to the new event based way of handling success/failure
          unless client_callback.nil?
            @options[:version] = 1.0
            if client_callback.arity == 2
              on_success do |response|
                client_callback.call self, response
              end

              on_failure do |error|
                client_callback.call self, nil
              end
            else
              @options[:version] = 2.0
              ### TODO Replace block above with this once all client definitions use new event driven approach
              
              # Call client to setup on_success and on_failure event callbacks
              client_callback.call self
            end
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
        # TODO handle async
        
        # Run the event loop (terminated by the connection &callback_ensure)
        EM.run {
          begin
            ### TODO 
            ### If a failure callback was set, just use that as a direct assignment
            ### otherwise implement one here that simply throws an exception, since we
            ### don't want to swallow the black holes
            if @options[:version] == 2.0
              if @failure_callback.nil?
                ensure_callback = proc {|error| raise '%s: %s' % [error.code.name, error.message] }
              else
                ensure_callback = @failure_callback
              end
            else
              ensure_callback = proc {|error|
                # populate the error
                @error = error
            
                unless @failure_callback.nil?
                  @failure_callback.call(self)
                else
                  # No failure callback given, so raise
                  raise '%s: %s' % [@error.code.name, @error.message]
                end
              }
            end
            
            server = ClientConnection.connect @options, &ensure_callback
          
            unless @success_callback.nil?
              # Response came back
              server.on_success &@success_callback
            end
          
            # Error occurred
            server.on_failure &ensure_callback
            
          rescue
            # Ensure the callback is set appropriately
            # server.on_failure &ensure_callback
            
            # Trigger the error
            server.fail :RPC_ERROR, $!.message
          end
        }
      end
      
    end
  end
end