require 'eventmachine'
require 'protobuf/rpc/error'
require 'protobuf/rpc/rpc.pb'
require 'utils/word_utils'

module Protobuf
  module Rpc
    
    class Server < EventMachine::Connection
      
      def receive_data(data)
        # Setup the initial request and response
        @request = Protobuf::Socketrpc::Request.new
        @response = Protobuf::Socketrpc::Response.new
        
        begin
          
          # Parse the protobuf request from the socket
          begin
            @request.parse_from(data)
          rescue
            raise BadRequestData, 'Unable to parse request: %s' % $!.message
          end
        
          # Determine the service class and method name from the request
          service, method = parse_service_info
          
          # Call the service method
          # Read out the response from the service method,
          # setting it on the pb request, and serializing the whole 
          # response to the socket
          service.__send__ method, @request do |client_response|
            @response.response_proto = client_response.serialize_to_string
          end
          
        rescue => error
          
          unless error.is_a? RpcError
            @response.error = error.message
            @response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
          else
            error.to_response @response
          end
          
        ensure
          send_data @response.serialize_to_string
        end
      end
      
      private
      
      def parse_service_info
        service, method = nil, nil
        begin
          service = WordUtils.constantize request.service_name
        rescue
          raise ServiceNotFound, "Service class #{request.service_name} does not exist"
        end
        
        begin
          method = WordUtils.underscore(request.method_name).to_sym
        rescue
          raise MethodNotFound, "Service method #{request.method_name} does not exist"
        end
        
        return service, method
      end
      
    end
  end
end
