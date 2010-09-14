require 'socket'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/controller'

module Protobuf
  module Rpc
    class Channel
      
      attr_reader :controller
      
      def initialize(host='localhost', port=7575)
        @host, @port = host, port
        @controller = Protobuf::Rpc::Controller.new
      end
      
      def call(service_name, method_name, client_request, client_response, &callback)
        # Open the socket connection
        open_socket
        
        # Setup the request
        setup_request service_name, method_name, client_request
        
        # Call the server with the request, reading its response
        write_request_and_read_response
        
        # Parse the response from the controller
        parsed_response = deserialize_response client_response
        
      rescue => error
        
        unless error.is_a? RpcError
          @controller.response.error = error.message
          @controller.response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
        else
          error.to_response @controller.response
        end
        
      ensure
        
        if block_given?
          block.call @controller, parsed_response
        end
        
      end
      
    end
    
    private
    
    def open_socket
      @socket = TCPSocket.open @host, @port
    rescue
      if $!.message =~ /getaddrinfo/
        raise UnknownHost, 'Nothing known about host %s' % @host
      else
        raise IOError, 'An unknown IO Error occurred while connecting to %s:%s : %s' % [@host, @port, $!.message]
      end
    end
    
    def setup_request service, method, client_request
      # Plug data into the request wrapper object
      @request = Protobuf::Socketrpc::Request.new
      @request.service_name = service_name
      @request.method_name = method_name
      
      # Verify the request type
      service_const = WordUtils.constantize(service_name)
      expected_request_type = service_const.rpcs[method_name.to_sym].request_type
      if client_request.class == expected_request_type
        @request.request_proto = client_request.serialize_to_string
      else
        raise InvalidRequestProto, 'Expected request type to be type of %s' % expected_request_type.to_s
      end
    end
    
    def write_request_and_read_response
      # Write the request and close the socket's write session
      @request.serialize_to @socket
      @socket.close_write
    
      # Parse the socket for a response wrapper
      @controller.response.parse_from @socket
    rescue
      raise IOError, $!.message
    end
    
    # Pull the response out of the controller and populate the expected response type
    def deserialize_response client_response
      # Initialize the response for this request
      @controller.response = Protobuf::Socketrpc::Response.new
      
      # Ensure client_response is an instance
      client_response = client_response.new if client_response.instance_of? Class
      
      # 
      parsed = client_response.parse_from_string @controller.response.response_proto.to_s
      
      if parsed.nil? && !@controller.failed?
        raise RpcError, 'Unable to parse response from socket' 
      else
        parsed
      end
    rescue
      raise BadResponseData, 'Unable to parse the response from the controller: %s' % $!.message
    end
    
  end
end
