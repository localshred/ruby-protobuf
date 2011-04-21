require 'eventmachine'
require 'socket'
require 'protobuf/common/logger'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'
require 'protobuf/rpc/stat'
require 'utils/word_utils'

module Protobuf
  module Rpc
    class Server < EventMachine::Connection
      include Protobuf::Logger::LogMethods
      
      # Initialize a new read buffer for storing client request info
      def post_init
        log_debug '[server] Post init, new read buffer created'
        
        @stat = Protobuf::Rpc::Stat.new(:SERVER, true)
        @stat.client = Socket.unpack_sockaddr_in(get_peername)
        
        @buffer = Protobuf::Rpc::Buffer.new :read
        @did_respond = false
      end
      
      # Receive a chunk of data, potentially flushed to handle_client
      def receive_data data
        log_debug '[server] receive_data: %s' % data
        @buffer << data
        handle_client if @buffer.flushed?
      end
      
      # Invoke the service method dictated by the proto wrapper request object
      def handle_client
        @stat.request_size = @buffer.size
        
        # Setup the initial request and response
        @request = Protobuf::Socketrpc::Request.new
        @response = Protobuf::Socketrpc::Response.new
        
        # Parse the protobuf request from the socket
        log_debug '[server] Parsing request from client'
        parse_request_from_buffer
      
        # Determine the service class and method name from the request
        log_debug '[server] Extracting procedure call info from request'
        parse_service_info
        
        # Call the service method
        log_debug '[server] Dispatching client request to service'
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
        @service.on_send_response do |response|
          unless @did_respond
            parse_response_from_service(response)
            send_response
          end
        end
        
        @service.on_rpc_failed do |error|
          unless @did_respond
            handle_error(error)
            send_response
          end
        end
        
        # Call the service method
        log_debug '[server] Invoking %s#%s with request %s' [@klass.name, @method, @request.inspect]
        @service.__send__ @method, @request
      end
      
      # Parse the incoming request object into our expected request object
      def parse_request_from_buffer
        begin
          log_debug '[server] parsing request from buffer: %s' % @buffer.data.inspect
          @request.parse_from_string @buffer.data
        rescue => error
          exc = BadRequestData.new 'Unable to parse request: %s' % error.message
          log_error exc.message
          log_error exc.backtrace.join("\n")
          raise exc
        end
      end
      
      # Read out the response from the service method,
      # setting it on the pb request, and serializing the
      # response to the protobuf response wrapper
      def parse_response_from_service response
        begin
          expected = @klass.rpcs[@klass][@method].response_type
          
          # Cannibalize the response if it's a Hash
          response = expected.new(response) if response.is_a?(Hash)
          actual = response.class
          
          log_debug '[server] response (should/actual): %s/%s' % [expected.name, actual.name]
          
          # Determine if the service tried to change response types on us
          if expected == actual
            begin
              # Response types match, so go ahead and serialize
              log_debug '[server] serializing response: %s' % response.inspect
              @response.response_proto = response.serialize_to_string
            rescue
              raise BadResponseProto, $!.message
            end
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
        raise 'Response already sent to client' if @did_respond
        log_debug '[server] Sending response to client: %s' % @response.inspect
        response_buffer = Protobuf::Rpc::Buffer.new(:write, @response)
        send_data(response_buffer.write)
        @stat.response_size = response_buffer.size
        @stat.log_stats
        @did_respond = true
      end
      
      # Client error handler. Receives an exception object and writes it into the @response
      def handle_error error
        log_debug '[server] handle_error: %s' % error.inspect
        if error.is_a? PbError
          error.to_response @response
        elsif error.is_a? ClientError
          PbError.new(error.message, error.code.to_s).to_response @response
        else
          message = error.is_a?(String) ? error : error.message
          PbError.new(message, 'RPC_ERROR').to_response @response
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
