require 'date'
require 'protobuf/common/logger'

module Protobuf
  module Rpc
    class Stat
      attr_accessor :type, :start_time, :end_time, :request_size, :response_size, :client
      
      TYPES = [:SERVER, :CLIENT]
      
      def initialize type=:SERVER, do_start=true
        @type = type
        start if do_start
      end
      
      def client= peer
        @client = {:port => peer[0], :ip => peer[1]}
      end
      
      def client
        @client ? '%s:%d' % [@client[:ip], @client[:port]] : nil
      end
      
      def sizes
        '%dB/%dB' % [@request_size || 0, @response_size || 0]
      end
      
      def start
        @start_time ||= Time.now
      end
      
      def end
        start if !@start_time
        @end_time ||= Time.now
      end
      
      def elapsed_time
        (start_time && end_time ? (end_time - start_time).round(2) : nil)
      end
      
      def log_stats
        Protobuf::Logger.info to_s
      end
      
      def to_s
        [
          @type == :SERVER ? 'SRV' : 'CLT',
          @start_time.strftime('%x %X'),
          elapsed_time,
          sizes,
          client
        ].delete_if{|v| v.nil? }.join(' - ')
      end
      
    end
  end
end

