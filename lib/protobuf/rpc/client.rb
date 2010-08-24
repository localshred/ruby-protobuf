require 'protobuf/rpc/channel'

module Protobuf
  module Rpc
    class Client
      
      attr_reader :klass, :host, :port, :channel, :stub
      
      def initialize klass, host, port
        @klass, @host, @port = klass, host, port
        @channel = Channel.new host, port
        @stub = @klass.client_stub(@channel)
      end
      
      def method_missing method, *params
        @stub.__send__(method, *params)
      end
      
    end
  end
end