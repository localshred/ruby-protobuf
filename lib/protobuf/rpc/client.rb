require 'socket'
require '/code/src/ruby-protobuf/lib/protobuf/rpc/rpc.pb'

module Protobuf
  module Rpc
    class Client
      attr_reader :reason
      
      def initialize(host, port)
        @host, @port = host, port
      end

      def call(service_name, method_name, request, response)
        # Create the socket
        socket = TCPSocket.open(@host, @port)
        
        # Setup the request wrapper object
        pb_request = Protobuf::Socketrpc::Request.new
        pb_request.service_name = service_name
        pb_request.method_name = method_name
        pb_request.request_proto = request.serialize_to_string
        pb_request.serialize_to socket
        socket.close_write
        
        @response = Protobuf::Socketrpc::Response.new
        @response.parse_from(socket)
        
        response.parse_from_string(@response.response_proto.to_s)
      rescue => e
        $stderr.puts e.message
        $stderr.puts e.backtrace.join("\n")
      end
    
      def failed?
        @response.nil? ? false : (@response.error_reason > 0)
      end
      
      def error
        @response.nil? || !failed? ? nil : @response.error
      end
      
      def error_reason
        return nil if @response.nil? || !failed?
        ::Protobuf::Socketrpc::ErrorReason.constants.first {|const| ::Protobuf::Socketrpc::ErrorReason.const_get(const) == @response.error_reason }.to_s
      end
      
      def error_message
        return nil if @response.nil? || !failed?
        "Response Error: #{error} (#{error_reason})" if failed?
      end
      
    end
  end
end
