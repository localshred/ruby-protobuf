require 'protobuf/rpc/service'
require 'utils/word_utils'

module Protobuf
  module Rpc
    class Stub
      
      def initialize(channel, klass, methods)
        @channel, @klass, @methods = channel, klass, methods
      end
      
      def method_missing(method, *params, &block)
        raise ServiceMethodNotFoundError, "Service method not found" unless @methods.include?(method)
        @channel.call(WordUtils.packagize(@klass).gsub(/Impl$/, ''), WordUtils.camelize(method).to_s, params[0], params[1], &block)
      end
      
    end
  end
end