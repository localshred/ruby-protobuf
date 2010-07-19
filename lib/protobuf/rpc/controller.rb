module Protobuf
  module Rpc
    class Controller
      attr_accessor :response
      
      def failed?
        @response.nil? ? false : (@response.error_reason > 0)
      end
      
      def error
        @response.nil? || !failed? ? nil : @response.error
      end
      
      def error_reason
        return nil if @response.nil? || !failed?
        ::Protobuf::Socketrpc::ErrorReason.constants.first {|const| ::Protobuf::Socketrpc::ErrorReason.const_get(const) == @response.error_reason }.to_s
      end
      
      def error_message
        return nil if @response.nil? || !failed?
        "Response Error: #{error} (#{error_reason})" if failed?
      end
      
      
    end
  end
end