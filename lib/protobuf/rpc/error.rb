require 'protobuf/rpc/rpc.pb'

module Protobuf
  module Rpc
    
    autoload :ClientError, 'protobuf/rpc/error/client_error'
    autoload :ServerError, 'protobuf/rpc/error/server_error'
    
    # Base RpcError class for client and server errors
    class RpcError < StandardError
      attr_reader :error_type
      
      def initialize message='An unknown RpcError occurred', error_type='RPC_ERROR'
        @error_type = error_type.is_a?(String) ? Protobuf::Socketrpc::ErrorReason.values[error_type.to_sym] : error_type
        super message
      end
    end
    
  end
end