require 'eventmachine'
require 'protobuf/rpc/rpc.pb'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'

# Handles client connections to the server
module Protobuf
  module Rpc
    ClientError = Struct.new(:ClientError, :code, :message)
    
    class ClientConnection < EM::Connection
      # include EM::Deferrable
      
      attr_reader :options, :request, :response
      attr_reader :error, :error_reason, :error_message

      DEFAULT_OPTIONS = {
        
        # Service to invoke
        :service => nil,
        
        # Service method to call
        :method => nil,
        
        # A default host (usually overridden)
        :host => 'localhost',
        
        # A default port (usually overridden)
        :port => '9938',
        
        # The request object sent by the client
        :request => nil, 
        
        # The request type expected by the client
        :request_type => nil, 
        
        # The response type expected by the client
        :response_type => nil, 
        
        # Whether or not to block a client call, this is actually handled by client.rb
        :async => false,
        
        # The default timeout for the request, also handled by client.rb
        :timeout => 30
        
      }
      
      STATUSES = {
        :pending => 0,
        :succeeded => 1,
        :failed => 2,
        :completed => 3
      }
      
      def self.connect options={}
        options = DEFAULT_OPTIONS.merge(options)
        host = options[:host]
        port = options[:port]
        EventMachine.connect host, port, self, options
      end
      
      def initialize options={}, &failure_callback
        @failure_callback = failure_callback
        
        # Verify the options that are necessary and merge them in
        [:service, :method, :host, :port].each do |opt|
          fail :RPC_ERROR, "Invalid client connection configuration. #{opt} must be a defined option." if !options[opt] || options[opt].nil?
        end
        @options = DEFAULT_OPTIONS.merge(options)
        
        @error = ClientError.new
        @success_callback = nil
        @status = STATUSES[:pending]
      rescue
        unless failed?
          fail :RPC_ERROR, 'Failed to initialize connection: %s' % $!.message
        end
      end
      
      # Called after the EM.connect
      def connection_completed
        send_request unless error?
      rescue
        unless failed?
          fail :RPC_ERROR, 'Connection error: %s' % $!.message
        end
      end
      
      def post_init
        # Setup the read buffer for data coming back
        @buffer = Protobuf::Rpc::Buffer.new :read
      rescue
        unless failed?
          fail :RPC_ERROR, 'Connection error: %s' % $!.message
        end
      end

      # Success callback registration
      def on_success &success_callback
        @success_callback = success_callback
      end
      
      # Failure callback registration
      def on_failure &failure_callback
        @failure_callback = failure_callback
      end
      
      # Completion callback registration
      def on_complete &complete_callback
        @complete_callback = complete_callback
      end
      
      def receive_data data
        @buffer << data
        parse_response if @buffer.flushed?
      end

      def parse_response
        # Close up the connection as we no longer need it
        close_connection
        
        # Parse out the raw response
        response_wrapper = Protobuf::Socketrpc::Response.new
        response_wrapper.parse_from_string @buffer.data
        
        # Determine success or failure based on parsed data
        if response_wrapper.has_field? :error_reason
          # fail the call if we already know the client is failed
          # (don't try to parse out the response payload)
          fail response_wrapper.error_reason, response_wrapper.error
        else
          # Ensure client_response is an instance
          response_type = @options[:response_type].new
          parsed = response_type.parse_from_string(response_wrapper.response_proto.to_s)
      
          if parsed.nil? and not response_wrapper.has_field?(:error_reason)
            fail :BAD_RESPONSE_PROTO, 'Unable to parse response from server'
          else
            succeed parsed
          end
        end
      end
      
    private
    
      def pending?
        @status == STATUSES[:pending]
      end
    
      def succeeded?
        @status == STATUSES[:succeeded]
      end
    
      def failed?
        @status == STATUSES[:failed]
      end
    
      def completed?
        @status == STATUSES[:completed]
      end
    
      # Sends the request to the server, invoked by the connection_completed event
      def send_request
        request_wrapper = Protobuf::Socketrpc::Request.new
        request_wrapper.service_name = @options[:service].name
        request_wrapper.method_name = @options[:method].to_s
        
        if @options[:request].class == @options[:request_type]
          request_wrapper.request_proto = @options[:request].serialize_to_string
        else
          expected = @options[:request_type].name
          actual = @options[:request].class.name
          fail :INVALID_REQUEST_PROTO, 'Expected request type to be type of %s, got %s instead' % [expected, actual]
        end
        
        request_buffer = Protobuf::Rpc::Buffer.new :write, request_wrapper
        send_data request_buffer.write
      end
      
      def fail code, message
        @status = STATUSES[:failed]
        @error.code = code.is_a?(Symbol) ? Protobuf::Socketrpc::ErrorReason.values[code] : code
        @error.message = message
        @failure_callback.call(@error) unless @failure_callback.nil?
        complete
      end
      
      def succeed response
        @status = STATUSES[:succeeded]
        @success_callback.call(response) unless @success_callback.nil?
        complete
      end
      
      def complete
        @status = STATUSES[:completed]
        @complete_callback.call(@status) unless @complete_callback.nil?
      end
  
    end
  end
end