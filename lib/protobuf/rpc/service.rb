require 'protobuf/rpc/stub'

module Protobuf
	module Rpc
		
		class NoRpcMethodError < NoMethodError; end
		RpcMethod = Struct.new "RpcMethod", :klass, :method, :request_type, :response_type
		
		class Service
		
			attr_reader :request, :response
			private :request, :response
			
			class << self
				
				# You MUST add the method name to this list if you are 
				# adding class methods here, otherwise stuff will probably break
				NON_RPC_METHODS = %w( rpcs call_rpc request response method_missing )
				
				# Shorthand for @rpcs class instance var
				def rpcs
					@rpcs ||= {}
				end
				
				# Generated service classes should call this method on themselves to add rpc methods
				# to the stack with a given request and response type
				def rpc method, request_type, response_type
					rpcs[self] ||= {}
					rpcs[self][method] = RpcMethod.new(self, method, request_type, response_type)
				end
				
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
			
				def client_stub(channel)
					Stub.new(channel, self.name, rpcs[self].keys)
				end
			
			end
			
			# If a method comes through that hasn't been found, and it
			# is defined in the rpcs method list, we know that the rpc
			# stub has been created, but no implementing method provides the
			# functionality, so throw an appropriate error, otherwise go to super
			def method_missing method, *params
				if rpcs.key? method
					raise NoRpcMethodError, "#{self}##{method} was defined as a valid rpc method, but was not implemented."
				else
					super method, args
				end
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
				# Setup the request
				pb_request = args[0]
				@request = rpcs[old_method.to_sym].request_type.new
				@request.parse_from_string pb_request.request_proto
				
				# Setup the response
				@response = rpcs[old_method.to_sym].response_type.new
				
				# Call the rpc method
				__send__ method, *args
				
				# Pass the populated response back to the server
				server.call @response
			end
			
			# Convenience wrapper around the rpc method list for a given class
			def rpcs
				self.class.rpcs[self.class]
			end
	
		end
		
	end
end