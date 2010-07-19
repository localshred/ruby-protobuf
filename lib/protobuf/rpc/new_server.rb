require 'webrick/config'
require 'webrick/server'
require 'protobuf/rpc/rpc.pb'
require 'utils/word_utils'

module Protobuf
  module Rpc
    class Server < WEBrick::GenericServer
      def initialize(config={:Port => 9999}, default=WEBrick::Config::General)
        super(config, default)
        @services = {}
      end
      
      def register_service(service_class)
        @services[service_class.to_s.to_sym] = service_class if defined? service_class
      end

      # TODO: implement error handling for all ErrorResponse codes

      def run(socket)
        @logger.debug "[SERV] socket run called!"
        # Parse the protobuf request from the socket
        request = Protobuf::Socketrpc::Request.new
        request.parse_from(socket)
        
        @logger.debug "[SERV] socket parsed"
        # Lookup the service class, determine if the method is callable
        service_constants = WordUtils.moduleize(request.service_name).split('::')
        service_class = service_constants.inject(Module.const_get(service_constants.shift)) {|const, obj| const.const_get(obj) }
        method = WordUtils.underscore(request.method_name).to_sym
        
        @logger.debug "[SERV] #{service_class}##{method} service request"
        @logger.debug "[SERV] getting ready to call service"
        begin
          service_class.__send__(method.to_sym, request) do |client_response|
            # Read out the response from the service method,
            # settign it on the pb request, and serializing the whole 
            # response to the socket
            begin
              @logger.debug "[SERV] found client response"
              response = Protobuf::Socketrpc::Response.new
              response.response_proto = client_response.serialize_to_string
            rescue
              @logger.debug "[SERV] rescuing bad error"
              @logger.error $!
              response.error = $!.message
              response.error_reason = Protobuf::Socketrpc::ErrorReason::RPC_ERROR
            ensure
              @logger.debug "[SERV] serializing to socket"
              response.serialize_to(socket)
            end
          end
        rescue
          @logger.debug "[SERV] Error handling request/response for service method call"
          @logger.debug $!
          $!.backtrace.each{|line| @logger.debug line}
        ensure
          
        end
      end
      
    end
  end
end
