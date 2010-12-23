require 'protobuf/rpc/client'
require 'protobuf/rpc/error'

module Protobuf
  module Rpc
    
    RpcMethod = Struct.new "RpcMethod", :service, :method, :request_type, :response_type
    
    class Service
    
      attr_reader :request
      attr_accessor :response, :async_responder
      private :request, :response, :response=
      
      DEFAULT_LOCATION = {
        :host => 'localhost',
        :port => 9939
      }
      
      class << self
        
        # You MUST add the method name to this list if you are adding
        # instance methods below, otherwise stuff will definitely break
        NON_RPC_METHODS = %w( rpcs call_rpc on_rpc_failed rpc_failed request response method_missing async_responder on_send_response send_response  )
        
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
          
          begin
            define_method(old) do |pb_request|
              call_rpc old.to_sym, pb_request
            end
          rescue ArgumentError => e
            # Wrap a known issue where an instance method was defined in the class without
            # it being ignored with NON_RPC_METHODS. 
            raise ArgumentError, "#{e.message} (Note: This could mean that you need to add the method #{old} to the NON_RPC_METHODS list)"
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
            :async => false,
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

      # Convenience wrapper around the rpc method list for a given class
      def rpcs
        self.class.rpcs[self.class]
      end
      
      def on_rpc_failed &rpc_failure_callback
        @rpc_failure_callback = rpc_failure_callback
      end
      
      # Convenience method for automatically failing a service method.
      # Note that this shortcuts the @async_responder paradigm. There is
      # not any way to get around this currently (and I'm not sure you should want to)
      def rpc_failed message="RPC Failed while executing service method #{@current_method}"
        raise 'Unable to invoke rpc_failed, no failure callback is setup.' if @rpc_failure_callback.nil?
        error = message.is_a?(String) ? RpcFailed.new(message) : message
        @rpc_failure_callback.call(error)
      end
      
      def on_send_response &responder
        @responder = responder
      end
      
      # Should only be called by rpc methods who set @async_responder to true
      def send_response
        raise "Unable to send response, responder is nil. It appears you aren't inside of an RPC request/response cycle." if @responder.nil?
        @responder.call @response
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
      #
      # Async behavior of responding can be achieved in the rpc method
      # by explicitly setting self.async_responder = true. It is then
      # the responsibility of the service method to send the response,
      # by calling self.send_response without any arguments. The rpc
      # server is setup to handle synchronous and asynchronous responses.
      def call_rpc method, pb_request
        @current_method = method
        
        # Allows the service to set whether or not
        # it would like to asynchronously respond to the connected client(s)
        @async_responder = false
        
        begin
          # Setup the request
          @request = rpcs[method].request_type.new
          @request.parse_from_string pb_request.request_proto
        rescue
          raise BadRequestProto, 'Unable to parse request: %s' % $!.message
        end
        
        # Setup the response
        @response = rpcs[method].response_type.new

        # Call the aliased rpc method (e.g. :rpc_find for :find)
        __send__("rpc_#{method}".to_sym)
        
        # Pass the populated response back to the server
        # Note this will only get called if the rpc method didn't explode (by design)
        send_response unless @async_responder
      end
      
    end
    
  end
end