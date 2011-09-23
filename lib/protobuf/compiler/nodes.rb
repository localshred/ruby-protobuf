require 'protobuf/common/util'
require 'protobuf/descriptor/descriptor_proto'
require 'utils/word_utils'

module Protobuf
  module Node
    class Base
      def define_in_the_file(visitor)
        visitor.write("defined_in __FILE__") if visitor.attach_proto?
      end

      def accept_message_visitor(visitor)
      end

      def accept_rpc_visitor(vistor)
      end

      def accept_descriptor_visitor(visitor)
      end
    end

    class ProtoNode < Base
      attr_reader :children

      def initialize(children)
        @children = children || []
      end

      def accept_message_visitor(visitor)
        visitor.write('### Generated by rprotoc. DO NOT EDIT!')
        visitor.write("### <proto file: #{visitor.proto_file}>") if visitor.attach_proto?
        visitor.write(visitor.commented_proto_contents) if visitor.attach_proto?
        visitor.write(<<-EOS)
require 'protobuf/message/message'
require 'protobuf/message/enum'
require 'protobuf/message/extend'
        EOS
        @children.each {|child| child.accept_message_visitor(visitor) }
        visitor.close_ruby
      end

      def accept_rpc_visitor(visitor)
        @children.each {|child| child.accept_rpc_visitor(visitor) }
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::FileDescriptorProto.new(:name => visitor.filename)
        visitor.file_descriptor = descriptor
        visitor.in_context(descriptor) do
          @children.each {|child| child.accept_descriptor_visitor(visitor) }
        end
      end
    end

    class ImportNode < Base
      def initialize(path)
        @path = path
      end

      def accept_message_visitor(visitor)
        visitor.write("require '#{visitor.required_message_from_proto(@path)}'")
      end

      def accept_descriptor_visitor(visitor)
        visitor.current_descriptor.dependency << @path
      end
    end

    class PackageNode < Base
      def initialize(path_list)
        @path_list = path_list
      end

      def accept_message_visitor(visitor)
        visitor.package = @path_list.dup
        @path_list.each do |path|
          visitor.write("module #{Util.camelize(path)}")
          visitor.increment
        end
      end

      def accept_rpc_visitor(visitor)
        visitor.package = @path_list.dup
      end

      def accept_descriptor_visitor(visitor)
        visitor.current_descriptor.package = @path_list.join('.')
      end
    end

    class OptionNode < Base
      def initialize(name_list, value)
        @name_list, @value = name_list, value
      end

      def accept_message_visitor(visitor)
        visitor.write("::Protobuf::OPTIONS[:#{@name_list.join('.').inspect}] = #{@value.inspect}")
      end

      def accept_descriptor_visitor(visitor)
        visitor.add_option(@name_list.join('.'), @value)
      end
    end

    class MessageNode < Base
      def initialize(name, children)
        @name, @children = name, children
      end

      def accept_message_visitor(visitor)
        class_name = @name.to_s
        class_name.gsub!(/\A[a-z]/) {|c| c.upcase}
        visitor.write("class #{class_name} < ::Protobuf::Message")
        visitor.in_context(self.class) do
          define_in_the_file(visitor)
          @children.each {|child| child.accept_message_visitor(visitor) }
        end
        visitor.write('end')
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::DescriptorProto.new(:name => @name.to_s)
        visitor.descriptor = descriptor
        visitor.in_context(descriptor) do
          @children.each {|child| child.accept_descriptor_visitor(visitor) }
        end
      end
    end

    class ExtendNode < Base
      def initialize(name, children)
        @name, @children = name, children
      end

      def accept_message_visitor(visitor)
        name = @name.is_a?(Array) ? @name.join : name.to_s
        visitor.write("class #{name} < ::Protobuf::Message")
        visitor.in_context(self.class) do
          define_in_the_file(visitor)
          @children.each {|child| child.accept_message_visitor(visitor) }
        end
        visitor.write('end')
      end

      def accept_descriptor_visitor(visitor)
        # TODO: how should i handle this?
      end
    end

    class EnumNode < Base
      def initialize(name, children)
        @name, @children = name, children
      end

      def accept_message_visitor(visitor)
        visitor.write("class #{@name} < ::Protobuf::Enum")
        visitor.in_context(self.class) do
          define_in_the_file(visitor)
          @children.each {|child| child.accept_message_visitor(visitor) }
        end
        visitor.write('end')
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::EnumDescriptorProto.new(:name => @name.to_s)
        visitor.enum_descriptor = descriptor
        visitor.in_context(descriptor) do
          @children.each {|child| child.accept_descriptor_visitor(visitor) }
        end
      end
    end

    class EnumFieldNode < Base
      def initialize(name, value)
        @name, @value = name, value
      end

      def accept_message_visitor(visitor)
        visitor.write("define :#{@name}, #{@value}")
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::EnumValueDescriptorProto.new(:name => @name.to_s, :number => @value)
        visitor.enum_value_descriptor = descriptor
      end
    end

    class ServiceNode < Base
      def initialize(name, children)
        @name, @children = name, children
      end

      def accept_message_visitor(visitor)
        # do nothing
      end

      def accept_rpc_visitor(visitor)
        visitor.current_service = @name
        @children.each {|child| child.accept_rpc_visitor(visitor) }
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::ServiceDescriptorProto.new(:name => @name.to_s)
        visitor.service_descriptor = descriptor
        visitor.in_context(descriptor) do
          @children.each {|child| child.accept_descriptor_visitor(visitor) }
        end
      end
    end

    class RpcNode < Base
      def initialize(name, request, response)
        @name, @request, @response = name, request, response
      end

      def accept_message_visitor(visitor)
        # do nothing
      end

      def accept_rpc_visitor(visitor)
        visitor.add_rpc(@name, @request, @response)
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::MethodDescriptorProto.new(:name => @name.to_s, :input_type => @request.to_s, :output_type => @response.to_s)
        visitor.method_descriptor = descriptor
      end
    end

    class GroupNode < Base
      def initialize(label, name, value, children)
        @label, @name, @value, @children = label, name, value, children
      end

      def accept_message_visitor(visitor)
        raise NotImplementedError
      end

      def accept_descriptor_visitor(visitor)
        raise NotImplementedError
      end
    end

    class FieldNode < Base
      def initialize(label, type, name, value, opts={})
        @label, @type, @name, @value, @opts = label, type, name, value, opts
      end

      def accept_message_visitor(visitor)
        opts = @opts.empty? ? '' : ", #{@opts.map{|k, v| ":#{k} => #{v.inspect}" }.join(', ')}"
        if visitor.context.first == ExtendNode
          opts << ', :extension => true'
        end
        type = if @type.is_a?(Array)
               then (@type.size > 1) ? "'#{@type.map{|e| WordUtils.camelize(e) }.join('::')}'" : @type[0]
               else @type
               end
        visitor.write("#{@label} :#{type}, :#{@name}, #{@value}#{opts}")
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::FieldDescriptorProto.new(:name => @name.to_s, :number => @value)
        descriptor.label = Google::Protobuf::FieldDescriptorProto::Label.const_get("LABEL_#{@label.to_s.upcase}")
        descriptor.type = Google::Protobuf::FieldDescriptorProto::Type.const_get("TYPE_#{@type.to_s.upcase}") if predefined_type?
        descriptor.type_name = @type.is_a?(Array) ? @type.join : @type.to_s
        @opts.each do |key, val|
          case key.to_sym
          when :default
            descriptor.default_value = val.to_s
          end
        end
        visitor.field_descriptor = descriptor
      end

      private

      def predefined_type?
        # TODO: constantize
        %w{double float int64 uint64 int32 fixed64 fixed32 bool string group message bytes uint32 enum sfixed32 sfixed64 sint32 sint64}.include?(@type.to_s)
      end
    end

    class ExtensionsNode < Base
      def initialize(range)
        @range = range
      end

      def accept_message_visitor(visitor)
        visitor.write("extensions #{@range.first.to_s}")
      end

      def accept_descriptor_visitor(visitor)
        descriptor = Google::Protobuf::DescriptorProto::ExtensionRange.new(:start => @range.first.low)
        case @range.first.high
        when NilClass then # ignore
        when :max     then descriptor.end = 1
        else               descriptor.end = @range.first.high
        end
        visitor.extension_range_descriptor = descriptor
      end
    end

    class ExtensionRangeNode < Base
      attr_reader :low, :high

      def initialize(low, high=nil)
        @low, @high = low, high
      end

      #def accept_message_visitor(visitor)
      #end

      def to_s
        if @high.nil?
          @low.to_s
        elsif @high == :max
          "#{@low}..::Protobuf::Extend::MAX"
        else
          "#{@low}..#{@high}"
        end
      end
    end
  end
end
