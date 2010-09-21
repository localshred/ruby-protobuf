# -*- encoding: utf-8 -*-

$:.push(File.dirname(__FILE__) + '/lib')
require 'ruby_protobuf'

Gem::Specification.new do |s|
  s.name = %q{ruby_protobuf}
  s.version = RubyProtobuf::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["BJ Neilsen"]
  s.date = %q{2010-06-15}
  s.default_executable = %q{rprotoc}
  s.description = %q{Ruby implementation for Protocol Buffers. Works with other rpc implementations}
  s.email = ["bj.neilsen@gmail.com"]
  s.executables = ["rprotoc"]
  s.extra_rdoc_files = ["History.txt", "README.txt"]
  s.files = Dir.glob('lib/**/*.{erb,rb,y,ebnf,proto}') + ["History.txt", "README.txt", "Rakefile", "TODO", "bin/rprotoc"]
  s.homepage = %q{http://github.com/localshred/ruby-protobuf}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Protocol Buffers for Ruby}
  s.test_files = Dir.glob('test/**/*.rb')
  s.add_dependency('eventmachine', ['~> 0.12.10'])
end
