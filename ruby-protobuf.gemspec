# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby_protobuf}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["BJ Neilsen"]
  s.date = %q{2010-06-15}
  s.default_executable = %q{rprotoc}
  s.description = %q{Ruby implementation for Protocol Buffers. Works with other rpc implementations}
  s.email = ["bj.neilsen@gmail.com"]
  s.executables = ["erprotoc"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "TODO", "bin/erprotoc", "examples/addressbook.pb.rb", "examples/addressbook.proto", "examples/reading_a_message.rb", "examples/writing_a_message.rb", "lib/ruby_protobuf.rb", "lib/protobuf/common/exceptions.rb", "lib/protobuf/common/util.rb", "lib/protobuf/common/wire_type.rb", "lib/protobuf/compiler/compiler.rb", "lib/protobuf/compiler/nodes.rb", "lib/protobuf/compiler/proto.y", "lib/protobuf/compiler/proto2.ebnf", "lib/protobuf/compiler/proto_parser.rb", "lib/protobuf/compiler/template/rpc_bin.erb", "lib/protobuf/compiler/template/rpc_client.erb", "lib/protobuf/compiler/template/rpc_service.erb", "lib/protobuf/compiler/template/rpc_service_implementation.erb", "lib/protobuf/compiler/visitors.rb", "lib/protobuf/descriptor/descriptor.proto", "lib/protobuf/descriptor/descriptor.rb", "lib/protobuf/descriptor/descriptor_builder.rb", "lib/protobuf/descriptor/descriptor_proto.rb", "lib/protobuf/descriptor/enum_descriptor.rb", "lib/protobuf/descriptor/field_descriptor.rb", "lib/protobuf/descriptor/file_descriptor.rb", "lib/protobuf/message/decoder.rb", "lib/protobuf/message/encoder.rb", "lib/protobuf/message/enum.rb", "lib/protobuf/message/extend.rb", "lib/protobuf/message/field.rb", "lib/protobuf/message/message.rb", "lib/protobuf/message/protoable.rb", "lib/protobuf/message/service.rb", "lib/protobuf/rpc/channel.rb", "lib/protobuf/rpc/client.rb", "lib/protobuf/rpc/controller.rb", "lib/protobuf/rpc/handler.rb", "lib/protobuf/rpc/new_server.rb", "lib/protobuf/rpc/rpc.pb.rb", "lib/protobuf/rpc/server.rb", "lib/protobuf/rpc/service.rb", "lib/protobuf/rpc/stub.rb", "lib/utils/word_utils.rb", "proto/rpc.proto", "script/mk_parser", "test/check_unbuild.rb", "test/data/data.bin", "test/data/data_source.py", "test/data/types.bin", "test/data/types_source.py", "test/data/unk.png", "test/proto/addressbook.pb.rb", "test/proto/addressbook.proto", "test/proto/addressbook_base.pb.rb", "test/proto/addressbook_base.proto", "test/proto/addressbook_ext.pb.rb", "test/proto/addressbook_ext.proto", "test/proto/collision.pb.rb", "test/proto/collision.proto", "test/proto/ext_collision.pb.rb", "test/proto/ext_collision.proto", "test/proto/ext_range.pb.rb", "test/proto/ext_range.proto", "test/proto/float_default.proto", "test/proto/lowercase.pb.rb", "test/proto/lowercase.proto", "test/proto/merge.pb.rb", "test/proto/merge.proto", "test/proto/nested.pb.rb", "test/proto/nested.proto", "test/proto/optional_field.pb.rb", "test/proto/optional_field.proto", "test/proto/packed.pb.rb", "test/proto/packed.proto", "test/proto/rpc.proto", "test/proto/types.pb.rb", "test/proto/types.proto", "test/test_addressbook.rb", "test/test_compiler.rb", "test/test_descriptor.rb", "test/test_enum_value.rb", "test/test_extension.rb", "test/test_lowercase.rb", "test/test_message.rb", "test/test_optional_field.rb", "test/test_packed_field.rb", "test/test_parse.rb", "test/test_repeated_types.rb", "test/test_serialize.rb", "test/test_standard_message.rb", "test/test_types.rb"]
  s.homepage = %q{http://github.com/dcardon/ruby-protobuf}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-protobuf}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Protocol Buffers for Ruby}
  s.test_files = ["test/test_addressbook.rb", "test/test_compiler.rb", "test/test_descriptor.rb", "test/test_enum_value.rb", "test/test_extension.rb", "test/test_lowercase.rb", "test/test_message.rb", "test/test_optional_field.rb", "test/test_packed_field.rb", "test/test_parse.rb", "test/test_repeated_types.rb", "test/test_serialize.rb", "test/test_standard_message.rb", "test/test_types.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.3"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.0"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.3"])
      s.add_dependency(%q<hoe>, [">= 2.6.0"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.3"])
    s.add_dependency(%q<hoe>, [">= 2.6.0"])
  end
end
