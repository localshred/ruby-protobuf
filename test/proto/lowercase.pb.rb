### Generated by rprotoc. DO NOT EDIT!
### <proto file: test/proto/lowercase.proto>
# package test.lowercase;
# 
# message foo {  
#   message bar {
#   } 
# }
# message baaz {  
#   required foo.bar x = 1;
# }

require 'protobuf/message/message'
require 'protobuf/message/enum'
require 'protobuf/message/extend'

module Test
  module Lowercase
    class Foo < ::Protobuf::Message
      defined_in __FILE__
      class Bar < ::Protobuf::Message
        defined_in __FILE__
      end
    end
    class Baaz < ::Protobuf::Message
      defined_in __FILE__
      required :'foo::bar', :x, 1
    end
  end
end