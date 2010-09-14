require 'protobuf/rpc/rpc.pb'

module Protobuf
  module Rpc
    
    class BadRequestData < RpcError
      def initialize message='Unable to parse request'
        super message, 'BAD_REQUEST_DATA'
      end
    end
    
    class BadRequestProto < RpcError
      def initialize message='Request is of wrong type'
        super message, 'BAD_REQUEST_PROTO'
      end
    end
    
    class ServiceNotFound < RpcError
      def initialize message='Service class not found'
        super message, 'SERVICE_NOT_FOUND'
      end
    end
    
    class MethodNotFound < RpcError
      def initialize message='Service method not found'
        super message, 'METHOD_NOT_FOUND'
      end
    end
    
    class RpcError < RpcError
      def initialize message='RPC exception occurred'
        super message, 'RPC_ERROR'
      end
    end
    
    class RpcFailed < RpcError
      def initialize message='RPC failed'
        super message, 'RPC_FAILED'
      end
    end
    
  end
end
