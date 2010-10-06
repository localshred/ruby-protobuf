require 'eventmachine'
require 'protobuf/rpc/error'

# Handles client connections to the server
module Protobuf
  module Rpc
    module ClientConnection
      include EM::Deferrable

      attr_accessor :client

      def post_init
        @buffer = ''
        timeout 30
      end

      def receive_data data
        @buffer << data
        if @buffer =~ /^.+?\r?\n?/
          parse_response
        end
      end

      def parse_response
        client.response.parse_from_string @buffer.chomp
        
        # Ensure client_response is an instance
        response_type = client.rpc.response_type.new
        
        parsed = response_type.parse_from_string client.response.response_proto.to_s
      
        if parsed.nil? && !@client.failed?
          raise RpcError, 'Unable to parse response from socket' 
        else
          succeed parsed
        end
      rescue
        unless $!.is_a? Protobuf::Rpc::PbError
          raise Protobuf::Rpc::BadResponseProto, 'Unable to parse the response from the server: %s' % $!.message
        end
      end
  
    end
  end
end