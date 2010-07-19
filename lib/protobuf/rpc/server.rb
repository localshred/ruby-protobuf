require 'webrick/config'
require 'webrick/server'

module Protobuf
  module Rpc
    class Server < WEBrick::GenericServer
      def initialize(config={:Port => 9999}, default=WEBrick::Config::General)
        super(config, default)
        setup_handlers
      end

      def setup_handlers
        @handlers = {}
      end

      def get_handler(socket)
        handler = ''
        handler = socket.readline.strip while (handler.empty?)
        $stdout.puts "-=-=-= handler from client = '#{handler}'"
        @handlers[handler.strip.to_sym]
      end

      def run(socket)
        pb_request = Protobuf::Socketrpc::Request.new
        pb_request.parse_from socket
        
        # service_class = pb_request.service_name.split('.').each {|e| e.capitalize! }.join('::')
        # service = const_get(service_class)
        $stdout.puts pb_request.method_name
        method = pb_request.method_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym
        $stdout.puts "method found from request: #{method}"
        handler = @handlers[method]

        request = handler.request_class.new
        request.parse_from_string(pb_request.request_proto)
        response = handler.response_class.new

        pb_response = Protobuf::Socketrpc::Response.new
        begin
          handler.process_request(request, response)
        rescue StandardError
          @logger.error $!
        ensure
          begin
            pb_response.response_proto = response.serialize_to_string
            pb_response.serialize_to socket
            # response.serialize_to(socket)
          rescue Errno::EPIPE, Errno::ECONNRESET, Errno::ENOTCONN
            @logger.error $!
          end
        end
        

      # rescue => e
      #   $stderr.puts e.message
      #   $stderr.puts e.backtrace.join("\n")
        
        # handler = get_handler socket
        # request = handler.request_class.new
        # request.parse_from(socket)
        # response = handler.response_class.new
        # begin
        #   handler.process_request(request, response)
        # rescue StandardError
        #   @logger.error $!
        # ensure
        #   begin
        #     response.serialize_to(socket)
        #   rescue Errno::EPIPE, Errno::ECONNRESET, Errno::ENOTCONN
        #     @logger.error $!
        #   end
        # end
      end
    end
  end
end
