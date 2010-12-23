require 'eventmachine'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'
require 'utils/word_utils'

module Protobuf
  module Rpc
    class Server < EventMachine::Connection
      
      # Initialize a new read buffer for storing client request info
      def post_init
        @buffer = Protobuf::Rpc::Buffer.new :read
      end
      
      # Receive a chunk of data, potentially flushed to handle_client
      def receive_data data
        @buffer << data
        handle_client if @buffer.flushed?
      end
      
      # Invoke the service method dictated by the proto wrapper request object
      def handle_client
        # Setup the initial request and response
        @request = Protobuf::Socketrpc::Request.new
        @response = Protobuf::Socketrpc::Response.new
        
        # Parse the protobuf request from the socket
        parse_request_from_buffer
      
        # Determine the service class and method name from the request
        parse_service_info
        
        # Call the service method
        invoke_rpc_method
        
      rescue => error
        # Ensure we're handling any errors that try to slip out the back door
        handle_error(error)
        send_response
      end
      
      private
      
      # Assuming all things check out, we can call the service method
      def invoke_rpc_method
        # Get a new instance of the service
        @service = @klass.new
        
        # Define our response callback to perform the "successful" response to our client
        # This decouples the service's rpc method from our response to the client,
        # allowing the service to be the dictator for when the response should be sent back.
        #
        # In other words, we don't send the response once the service method finishes executing
        # since the service may perform it's own operations asynchronously.
        @service.on_send_response do |client_response|
          parse_response_from_service(client_response)
          send_response
        end
        
        @service.on_rpc_failed &error_handler
        
        # Call the service method
        @service.__send__ @method, @request
      end
      
      # Parse the incoming request object into our expected request object
      def parse_request_from_buffer
        begin
          @request.parse_from_string @buffer.data
        rescue
          raise BadRequestData, 'Unable to parse request: %s' % $!.message
        end
      end
      
      # Read out the response from the service method,
      # setting it on the pb request, and serializing the
      # response to the protobuf response wrapper
      def parse_response_from_service response
        begin
          # Determine if the service tried to change response types on us
          expected = @klass.rpcs[@klass][@method].response_type
          actual = response.class
          if expected == actual
            # response types match, so go ahead and serialize
            @response.response_proto = response.serialize_to_string
          else
            # response types do not match, throw the appropriate error
            raise BadResponseProto, 'Response proto changed from %s to %s' % [expected.name, actual.name]
          end
        rescue => error
          handle_error(error)
        end
      end
      
      # Write the response wrapper to the client
      def send_response
        response_buffer = Protobuf::Rpc::Buffer.new(:write, @response)
        send_data(response_buffer.write)
      end
      
      # Client error handler. Receives an exception object and writes it into the @response
      def handle_error error
        error_handler.call(error)
      end
      
      # Setup a error handler callback for registering with the service
      def error_handler
        @error_handler ||= lambda do |error|
          if error.is_a? PbError
            error.to_response @response
          elsif error.is_a? ClientError
            PbError.new(error.message, error.code.to_s).to_response @response
          else
            message = error.is_a?(String) ? error : error.message
            PbError.new(message, 'RPC_ERROR').to_response @response
          end
        end
      end
      
      # Parses and returns the service and method name from the request wrapper proto
      def parse_service_info
        @klass, @method = nil, nil
        
        begin
          @klass = WordUtils.constantize @request.service_name
        rescue
          raise ServiceNotFound, "Service class #{@request.service_name} is not found"
        end
        
        @method = WordUtils.underscore(@request.method_name).to_sym
        unless @klass.instance_methods.include?(@method)
          raise MethodNotFound, "Service method #{@request.method_name} is not defined by the service"
        end
      end
      
    end
  end
end
