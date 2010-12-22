require 'eventmachine'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'
require 'utils/word_utils'

module Protobuf
  module Rpc
    
    class Server < EventMachine::Connection
      
      attr_accessor :logger
      
      def post_init
        @buffer = Protobuf::Rpc::Buffer.new :read
      end
      
      def receive_data data
        @buffer << data
        handle_client if @buffer.flushed?
      end
      
      def handle_client
        # Setup the initial request and response
        @request = Protobuf::Socketrpc::Request.new
        @response = Protobuf::Socketrpc::Response.new
        
        # Parse the protobuf request from the socket
        begin
          @request.parse_from_string @buffer.data
        rescue
          raise BadRequestData, 'Unable to parse request: %s' % $!.message
        end
      
        # Determine the service class and method name from the request
        service, method = parse_service_info
        
        # Call the service method
        # Read out the response from the service method,
        # setting it on the pb request, and serializing the whole 
        # response to the socket
        service.new.__send__ method, @request do |client_response|
          
          # Determine if the service tried to change response types on us
          expected = service.rpcs[service][method].response_type
          actual = client_response.class
          if expected == actual
            # response types match, so go ahead and serialize
            @response.response_proto = client_response.serialize_to_string
          else
            # response types do not match, throw the appropriate error
            raise BadResponseProto, 'Response proto changed from %s to %s' % [expected.name, actual.name]
          end
        end
        
      rescue => error
        unless error.is_a? PbError
          @response.error = error.message
          @response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
        else
          error.to_response @response
        end
      ensure
        response_buffer = Protobuf::Rpc::Buffer.new :write, @response
        send_data response_buffer.write
      end
      
      private
      
      def parse_service_info
        service, method = nil, nil
        begin
          service = WordUtils.constantize @request.service_name
        rescue
          raise ServiceNotFound, "Service class #{@request.service_name} does not exist"
        end
        
        begin
          method = WordUtils.underscore(@request.method_name).to_sym
        rescue
          raise MethodNotFound, "Service method #{@request.method_name} does not exist"
        end
        
        return service, method
      end
      
    end
  end
end
