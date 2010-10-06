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
        @request = Protobuf::Socketrpc::Request.new
        @response = Protobuf::Socketrpc::Response.new
      end
      
      # Intercept calls to service rpcs
      def method_missing method, *params, &block
        unless @service.rpcs[@service].keys.include? method
          super method, *params
        else
          @method = method
          @client_request = params[0]
          @client_callback = block
          call_rpc
        end
      end

      # Controller error/failure methods
      def failed?
        !@response.nil? && @response.has_field?(:error_reason)
      end
      
      def error
        @response.error if failed?
      end
      
      def error_reason
        Protobuf::Socketrpc::ErrorReason.name_by_value(@response.error_reason).to_s if failed?
      end
      
      def error_message
        "%s: %s" % [error_reason, error] if failed?
      end
   
    private
      
      def call_rpc
        @rpc = @service.rpcs[@service][@method.to_sym]

        # Run the event loop (terminated by the connection &callback_ensure)
        EM.run {
          
          # Setup the error handler
          EM.error_handler {|error|
            unless error.kind_of? PbError
              @response.error = error.message
              @response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
            else
              error.to_response @response
            end
            @connection.fail # callback ensures em loop is stopped
          }
          
          # Connect to the service
          @connection = EM.connect(@host, @port, ClientConnection) {|conn|
            # Give the connection self
            conn.client = self
            
            # Setup the callback
            callback_ensure = proc { |response|
              # We should always call the client callback code if it was given
              @client_callback.call self, response unless @client_callback.nil?
              # Stop the event loop
              EM.stop_event_loop
            }
            
            # Bind the callback to the connection
            conn.callback &callback_ensure
            conn.errback &callback_ensure
          }
          
          if @connection.error?
            raise Protobuf::Rpc::IOError, 'Unable to connect to %s:%s' % [@host, @port]
          end
          
          # Plug data into the request wrapper object
          @request.service_name = @service.name
          @request.method_name = @method.to_s
    
          # Verify the request type
          if @client_request.class == @rpc.request_type
            @request.request_proto = @client_request.serialize_to_string
          else
            raise InvalidRequestProto, 'Expected request type to be type of %s' % @rpc.request_type.to_s
          end
          
          # Write the data to the connection, depend on event handing to parse/invoke response
          @connection.send_data @request.serialize_to_string.chomp + "\n"
          
        }
      end
      
    end
  end
end