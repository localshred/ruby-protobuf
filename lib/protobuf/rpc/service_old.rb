require 'protobuf/rpc/stub'

module Protobuf
  module Rpc
    
    # Generic service method not found error
    class ServiceMethodNotFoundError < StandardError; end

    # Struct mapping request and response types to a given method
    class ServiceMethodProto < Struct.new(:method, :request_proto, :response_proto); end

    # Struct mapping user-defined blocks to a given method
    class ServiceMethodBlock < Struct.new(:method, :block); end

    # Service class that will be extended by generated proto service implementations
    class Service
  
      class << self
        
        def client_stub(channel)
          Stub.new(channel, self.name, @service_protos)
        end
        
        def service_method_defined?(method)
          !(self.service_protos[method].nil? && self.service_blocks[method].nil?)
        end
    
        def method_missing(method, *params, &server)
          # Pull the protobuf request from the passed params
          protobuf_request = params[0]
          
          # Get the appropriate proto and block definitions
          # from the implementing service class
          m = self.service_protos[method]
          b = self.service_blocks[method]
      
          # If method not defined, throw the error
          raise ServiceMethodNotFoundError, "Invalid service method :#{method} for service" unless service_method_defined?(method)
      
          # Pull data from the socket, setting stuff up
          request = m.request_proto.new
          request.parse_from_string(protobuf_request.request_proto)
          response = m.response_proto.new
      
          # Call the implementation block
          b.block.call(request, response)
      
          # write the response to the socket
          server.call(response)
        end

        def inherited(klass)
          # @service_blocks = klass.service_blocks
          klass.service_protos = @service_protos
        end

        protected
    
          def proto(method, request, response)
            service_protos[method] = ServiceMethodProto.new(method, request, response)
          end

          def service_protos
            @service_protos ||= Hash.new
          end
    
          def service_protos=(service_protos)
            @service_protos = service_protos
          end
    
          def service_blocks
            @service_blocks ||= Hash.new
          end
    
          def service_method(method, &block)
            self.service_blocks[method] = ServiceMethodBlock.new(method, block)
          end
    
      end
  
    end
    
  end
end