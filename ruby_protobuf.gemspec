# -*- encoding: utf-8 -*-

$:.push(File.dirname(__FILE__) + '/lib')
require 'ruby_protobuf'

Gem::Specification.new do |s|
  s.name                        = 'ruby_protobuf'
  s.version                     = RubyProtobuf::VERSION
  s.platform                    = Gem::Platform::RUBY
  s.date                        = %q{2011-09-23}
  s.required_rubygems_version   = ">= 1.3.6"

  s.authors                     = ['BJ Neilsen']
  s.email                       = ["bj.neilsen@gmail.com"]
  s.homepage                    = %q{http://github.com/localshred/ruby-protobuf}
  s.summary                     = 'Ruby implementation for Protocol Buffers. Works with other protobuf rpc implementations.'
  s.description                 = s.summary
  
  s.require_paths               = ["lib"]
  s.executables                 = ['rprotoc', 'rpc_server']
  s.files                       = Dir.glob('lib/**/*.{erb,rb,y,ebnf,proto}') + %w(History.txt README.txt Rakefile TODO bin/rprotoc bin/rpc_server)
  s.test_files                  = Dir.glob('test/**/*.rb')
  
  s.extra_rdoc_files            = ['History.txt', 'README.txt']
  s.rdoc_options                = ["--main", "README.txt"]
  
  s.add_dependency 'eventmachine', '~> 0.12.10'
  
  s.add_development_dependency 'rake', '~> 0.8.7'
  s.add_development_dependency 'rspec', '~> 2.3.0'
end
