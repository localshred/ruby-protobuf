require 'protobuf/rpc/client'
require 'protobuf/rpc/error'

module Protobuf
  module Rpc
    
    RpcMethod = Struct.new "RpcMethod", :service, :method, :request_type, :response_type
    
    class Service
    
      attr_reader :request
      attr_accessor :response
      private :request, :response, :response=
      
      DEFAULT_LOCATION = {
        :host => 'localhost',
        :port => 9939
      }
      
      class << self
        
        # You MUST add the method name to this list if you are adding
        # instance methods below, otherwise stuff will definitely break
        NON_RPC_METHODS = %w( rpcs call_rpc rpc_failed request response method_missing )
        
        # Override methods being added to the class
        # If the method isn't already a private instance method, or it doesn't start with rpc_, 
        # or it isn't in the reserved method list (NON_RPC_METHODS),
        # We want to remap the method such that we can wrap it in before and after behavior,
        # most notably calling call_rpc against the method. See call_rpc for more info.
        def method_added old
          new_method = :"rpc_#{old}"
          return if private_instance_methods.include?(new_method) or old =~ /^rpc_/ or NON_RPC_METHODS.include?(old.to_s)
          
          alias_method new_method, old
          private new_method
          
          define_method old do |*args, &server|
            call_rpc new_method.to_sym, old.to_sym, *args, &server
          end
        end
      
        # Generated service classes should call this method on themselves to add rpc methods
        # to the stack with a given request and response type
        def rpc method, request_type, response_type
          rpcs[self] ||= {}
          rpcs[self][method] = RpcMethod.new self, method, request_type, response_type
        end

        # Shorthand for @rpcs class instance var
        def rpcs
          @rpcs ||= {}
        end
        
        # Create a new client for the given service
        # See client.rb for options available, though you will likely
        # only be passing (if anything) a host, port, or the async setting
        def client options={}
          configure
          Client.new({
            :service => self,
            :async => true,
            :host => self.host,
            :port => self.port
          }.merge(options))
        end
        
        # Allows service-level configuration of location
        def configure config={}
          locations[self] ||= {}
          locations[self][:host] = config[:host] if config.key? :host
          locations[self][:port] = config[:port] if config.key? :port
        end
        
        # Shorthand call to configure, passing a string formatted as hostname:port
        # e.g. 127.0.0.1:9933
        # e.g. localhost:0
        def located_at location
          return if location.nil? or location.downcase.strip !~ /[a-z0-9.]+:\d+/
          host, port = location.downcase.strip.split ':'
          configure :host => host, :port => port.to_i
        end
        
        def host
          configure
          locations[self][:host] || DEFAULT_LOCATION[:host]
        end
        
        def port
          configure
          locations[self][:port] || DEFAULT_LOCATION[:port]
        end
      
        # Shorthand for @locations class instance var
        def locations
          @locations ||= {}
        end
        
      end
      
      # If a method comes through that hasn't been found, and it
      # is defined in the rpcs method list, we know that the rpc
      # stub has been created, but no implementing method provides the
      # functionality, so throw an appropriate error, otherwise go to super
      def method_missing method, *params
        if rpcs.key? method
          raise MethodNotFound, "#{self}##{method} was defined as a valid rpc method, but was not implemented."
        else
          super method, args
        end
      end
      
      # Convenience method for automatically failing a service method
      def rpc_failed message="RPC Failed while executing service method #{@method}"
        raise RpcFailed, message
      end
      
      # Convenience wrapper around the rpc method list for a given class
      def rpcs
        self.class.rpcs[self.class]
      end
  
    private
      
      # Call the rpc method that was previously privatized.
      # call_rpc allows us to wrap the normal method call with 
      # before and after behavior, most notably setting up the request
      # and response instances.
      # 
      # Implementing rpc methods should be aware
      # that request and response are implicitly available, and
      # that response should be manipulated during the rpc method,
      # as there is no way to reliably determine the response like
      # a normal (http-based) controller method would be able to
      def call_rpc method, old_method, *args, &server
        @method = old_method
        
        begin
          # Setup the request
          pb_request = args[0]
          @request = rpcs[old_method.to_sym].request_type.new
          @request.parse_from_string pb_request.request_proto
        rescue
          raise BadRequestProto, 'Unable to parse request: %s' % $!.message
        end
        
        # Setup the response
        @response = rpcs[old_method.to_sym].response_type.new

        # Call the rpc method
        __send__ method
        
        # Pass the populated response back to the server
        # Note this will only get called if the rpc method didn't explode (by design)
        server.call @response
      end
      
    end
    
  end
end