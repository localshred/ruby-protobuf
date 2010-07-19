require 'socket'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/controller'

module Protobuf
  module Rpc
    class Channel
      
      def initialize(host='localhost', port=7575)
        @host, @port = host, port
      end
      
      def controller
        @controller ||= Protobuf::Rpc::Controller.new
      end
      
      def call(service_name, method_name, client_request, client_response, &block)
        # Setup the params we'll need in the block call
        parsed_response = nil
        controller.response = Protobuf::Socketrpc::Response.new
        
        # Create the socket
        socket = TCPSocket.open(@host, @port)
        
        # puts "channel -> #{service_name}, #{method_name}, #{client_request}, #{client_response}"
        
        # Plug data into the request wrapper object
        request = Protobuf::Socketrpc::Request.new
        request.service_name = service_name
        request.method_name = method_name
        request.request_proto = client_request.serialize_to_string
        
        # Write the request and close the socket's write session
        request.serialize_to(socket)
        socket.close_write
        
        # Parse the socket for a response wrapper
        controller.response.parse_from(socket)
        
        # Create a new instance of the client's response, passing the wrapper's data to it
        client_response = client_response.new() if (client_response.is_a? Class)
        parsed_response = client_response.parse_from_string(controller.response.response_proto.to_s)
      rescue SocketError => e
        controller.response.error_reason = Protobuf::Socketrpc::ErrorReason::IO_ERROR
        controller.response.error = "#{e.message} (#{e.class.name})"
      rescue => e
        # TODO: probably do some controller error handling here
        controller.response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
        controller.response.error = "#{e.message} (#{e.class.name})"
      ensure
        # Call the given block, otherwise fall through
        if (parsed_response.nil? && !controller.failed?)
          controller.response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
          controller.response.error = 'An unkown error has occurred'
        end
        block.call(controller, parsed_response) if block_given?
      end
      
    end
  end
end
