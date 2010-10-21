require 'eventmachine'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'

# Handles client connections to the server
module Protobuf
  module Rpc
    module ClientConnection
      include EM::Deferrable

      attr_accessor :client

      def post_init
        @buffer = Protobuf::Rpc::Buffer.new :read
        timeout 30
      end

      def receive_data data
        @buffer << data
        parse_response if @buffer.flushed?
      end

      def parse_response
        @buffer.data.inspect
        @client.response.parse_from_string @buffer.data
        
        unless @client.failed?
          # Ensure client_response is an instance
          response_type = client.rpc.response_type.new
        
          parsed = response_type.parse_from_string client.response.response_proto.to_s
      
          if parsed.nil? && !@client.failed?
            raise RpcError, 'Unable to parse response from server' 
          else
            succeed parsed
          end
        else
          # fail the call if we already know the client is failed
          # (don't try to parse out the response payload)
          fail nil
        end
      rescue
        unless $!.is_a? Protobuf::Rpc::PbError
          raise Protobuf::Rpc::BadResponseProto, 'Unable to parse the response from the server: %s' % $!.message
        else
          raise
        end
      end
  
    end
  end
end