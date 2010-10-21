require 'eventmachine'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/client_connection'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'

module Protobuf
  module Rpc
    class Client
      
      # attr_reader :service, :method, :host, :port, :request, :response, :rpc
      
      def initialize options={}
        [:service, :method].each do |opt|
          raise "Invalid client configuration. #{opt} must be a defined option." if !options[opt] || options[opt].nil?
        end
        @error = nil
        @options = ClientConnection::DEFAULT_OPTIONS.merge(options)
        @success_callback = nil
        @failure_callback = nil
      end
      
      def on_success &success_callback
        @success_callback << success_callback
      end
      
      def on_failure &failure_callback
        @failure_callback << failure_callback
      end
      
      # Intercept calls to service rpcs
      def method_missing method, *params, &client_callback
        service = @options[:service].name
        unless service.rpcs[service].keys.include? method
          super method, *params
        else
          rpc = service.rpcs[service][method.to_sym]
          @options[:request_type] = rpc.request_type
          @options[:response_type] = rpc.response_type
          @options[:method] = method.to_s
          @options[:request] = params[0]
          
          # TODO remove once we are able to convert everything
          # to the new event based way of handling success/failure
          if client_callback.arity == 2
            unless client_callback.nil?
              on_success do |response|
                client_callback.call self, response
              end

              on_failure do |error|
                client_callback.call self, nil
              end
            end
          else
            ### REPLACE WITH THIS
            client_callback.call self
          end

          call_rpc
        end
      end

      # Controller error/failure methods
      def failed?
        !@error.nil? and !@error[:code].nil?
      end
      
      def error
        @error[:message] if failed?
      end
      
      def error_reason
        Protobuf::Socketrpc::ErrorReason.name_by_value(@error[:code]).to_s if failed?
      end
      
      def error_message
        "%s: %s" % [error_reason, error] if failed?
      end
       
    private
      
      def call_rpc
        # TODO handle async
        
        # Run the event loop (terminated by the connection &callback_ensure)
        EM.run {
          
          server = ClientConnection.connect @options
          
          # Response came back
          server.on_success do |response|
            # Invoke the callback
            @success_callback.call(response) unless @success_callback.nil?
            
            # Close the connection, stop the loop
            server.close_connection
            stop_event_loop
          end
          
          # Error occurred
          server.on_failure do |error|
            # populate the error
            @error[:error_reason] = error[:code]
            @error[:error] = error[:message]
            
            # TODO pass the @error instead of "self"
            @failure_callback.call(self) unless @failure_callback.nil?
          end
        }
      end
      
    end
  end
end