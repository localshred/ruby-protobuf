require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/client_connection'
require 'protobuf/rpc/error'

module Protobuf
  module Rpc
    
    class Client
      
      attr_reader :service, :method, :host, :port, :request, :response, :rpc
      
      def initialize service, options={}
        @service = service
        @host = options[:host] || @service.host || 'localhost'
        @port = options[:port] || @service.port || 9939
        @logger = options[:logger] || Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
        @request = Protobuf::Socketrpc::Request.new
        @response = Protobuf::Socketrpc::Response.new
      end
      
      # Intercept calls to service rpcs
      def method_missing method, *params, &block
        @logger.debug '[C] in method missing for method %s' % method
        if @service.rpcs[@service].keys.include? method
          @logger.debug '[C] invoking call_rpc'
          @method = method
          @client_request = params[0]
          @client_callback = block
          call_rpc
        else
          super method, *params
        end
      end

      # Controller error/failure methods
      def failed?
        @response.nil? ? false : @response.has_field?(:error_reason)
      end
      
      def error
        @response.nil? || !failed? ? nil : @response.error
      end
      
      def error_reason
        @response.nil? || !failed? ? nil : Protobuf::Socketrpc::ErrorReason.name_by_value(@response.error_reason).to_s
      end
      
      def error_message
        @response.nil? || !failed? ? nil : "Response Error: #{error} (#{error_reason})" if failed?
      end
   
      private
      
      # def call service_name, method_name, client_request, client_response, &callback
      def call_rpc
        @rpc = @service.rpcs[@service][@method.to_sym]

        EM.error_handler do |error|
          @logger.error error.class.name
          @logger.error error.class.superclass.name
          unless error.kind_of? PbError
            @logger.debug 'Error is not a PbError, so reset'
            @response.error = error.message
            @response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
          else
            @logger.debug 'Error is a PbError, so merge into the response'
            error.to_response @response
          end
          @logger.error error_message
          @logger.debug error.backtrace.join("\n")
          @connection.failed
          EM.stop_event_loop
        end
        
        @logger.debug '[C] invoking EM.run_block...'
        EM.run_block do
          @logger.debug '[C] inside run_block'
          
          @connection = EM.connect @host, @port, ClientConnection do |conn|
            @logger.debug '[C] in conn setup'
            @logger.debug '[C] conn = %s' % conn.inspect
            conn.client = self
            callback_ensure = proc do |response|
              @logger.info 'setting up ensure callback'
              unless @client_callback.nil?
                @logger.info '@client_callback is not nil, so invoke'
                @client_callback.call self, response
              else
                @logger.debug '@client_callback is nil, so just stop the loop'
              end
              EM.stop_event_loop
            end
            conn.callback &callback_ensure
            conn.errback &callback_ensure
          end
          
          if @connection.error?
            raise Protobuf::Rpc::IOError, 'Unable to connect to %s:%s' % [@host, @port]
          end
          
          # Plug data into the request wrapper object
          @request.service_name = @service.name
          @request.method_name = @method.to_s
    
          # Verify the request type
          @logger.debug @rpc.inspect
          if @client_request.class == @rpc.request_type
            @request.request_proto = @client_request.serialize_to_string
          else
            raise InvalidRequestProto, 'Expected request type to be type of %s' % @rpc.request_type.to_s
          end
          
          @logger.debug '[C] connection.error? %s' % @connection.error?.to_s
          @logger.debug '[C] EM.connection_count %d' % EM.connection_count
          
          @logger.debug '[C] sending data to server from client!'
          # Write the data to the connection, depend on event handing to parse/invoke response
          @connection.send_data @request.serialize_to_string.chomp + "\n"
          @logger.debug '[C] after send data'
        end
      end
      
    end
  end
end