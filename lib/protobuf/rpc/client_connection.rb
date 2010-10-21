require 'eventmachine'
require 'protobuf/rpc/buffer'
require 'protobuf/rpc/error'

# Handles client connections to the server
module Protobuf
  module Rpc
    ClientError = Struct.new(:ClientError, :code, :message)
    
    module ClientConnection < EM::Connection
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
        
        # The request sent by the client
        :request => nil, 
        
        # The response type expected by the client
        :response => nil, 
        
        # The callback to invoke after the response comes back
        :response_callback => nil, 
        
        # Whether or not to block a client call, this is actually handled by client.rb
        :async => true
        
      }
      
      def self.connect options={}
        options = DEFAULT_OPTIONS.merge(options)
        host = options[:host]
        port = options[:port]
        EventMachine.connect host, port, self, options
      end
      
      def initialize options={}
        [:service, :method].each do |opt|
          raise "Invalid client connection configuration. #{opt} must be a defined option." if !options[opt] || options[opt].nil?
        end
        @options = DEFAULT_OPTIONS.merge(options)
        @client_error = ClientError.new
        @success_callback = nil
        @failure_callback = nil
      end
      
      def on_success &success_callback
        @success_callback = success_callback
      end
      
      def on_failure &failure_callback
        @failure_callback = failure_callback
      end
      
      # Called after the EM.connect
      def connection_completed
        send_request
      end
      
      def post_init
        # Setup the read buffer for data coming back
        @buffer = Protobuf::Rpc::Buffer.new :read
        timeout 30
      end

      # Called if user code closes connection or if network error occurs
      def unbind
        if error?
          fail :IO_ERROR, 'Unable to connect to %s:%s' % [@host, @port]
        end
      end
      
      def receive_data data
        @buffer << data
        parse_response if @buffer.flushed?
      end

      def parse_response
        response_wrapper = Protobuf::Socketrpc::Response.new
        response_wrapper.parse_from_string @buffer.data
        
        unless response_wrapper.has_field? :error_reason
          # Ensure client_response is an instance
          response_type = @options[:rpc].response_type.new
        
          parsed = response_type.parse_from_string client.response.response_proto.to_s
      
          if parsed.nil? && !@client.failed?
            raise RpcError, 'Unable to parse response from server' 
          else
            succeed parsed
          end
        else
          # fail the call if we already know the client is failed
          # (don't try to parse out the response payload)
          fail response_wrapper.error_reason, response_wrapper.error
        end
      rescue
        unless $!.is_a? Protobuf::Rpc::PbError
          fail :BAD_RESPONSE_PROTO, 'Unable to parse the response from the server: %s' % $!.message
        else
          fail $!.error_type, $!.message
        end
      end
      
    private
    
      # Sends the request to the server, invoked by the connection_completed event
      def send_request
        request_wrapper = Protobuf::Socketrpc::Request.new
        request.service_name = @service.name
        request.method_name = @method.to_s
        
        if @options[:request].class == @options[:rpc].request_type
          request.request_proto = @options[:request].serialize_to_string
        else
          fail :INVALID_REQUEST_PROTO, 'Expected request type to be type of %s' % @options[:rpc].request_type.name
        end
        
        request_buffer = Protobuf::Rpc::Buffer.new :write, request
        send_data request_buffer.write
      end
      
      def fail code, message
        @client_error[:code] = code.is_a?(Symbol) ? Protobuf::Socketrpc::ErrorReason.const_get(error_type.to_s) : error_type
        @client_error[:message] = message
        @error_callback.call(@client_error) unless @error_callback.nil?
        shutdown
      end
      
      def succeed response
        @success_callback.call(response) unless @success_callback.nil?
        shutdown
      end
      
      def shutdown
        close_connection
        EM.stop
      end
  
    end
  end
end