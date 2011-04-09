require 'logger'

module Protobuf
  class Logger < ::Logger
    
    class << self
      attr_accessor :file, :level
      
      def instance
        @__instance ||= (@file && @level ? new(@file, @level) : nil)
      end
      
      [:debug, :info, :warn, :error, :fatal, :any, :add, :log].each do |m|
        define_method(m) do |*params|
          instance && instance.__send__(m, *params)
        end
      end
    end
    
  end
end