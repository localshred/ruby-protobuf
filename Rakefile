# -*- ruby -*-

$:.push(File.dirname(__FILE__) + '/lib')
require 'rubygems'
require 'hoe'
require 'hoe/rcov'
require 'ruby_protobuf'

Hoe.spec('ruby_protobuf') do
  self.version = RubyProtobuf::VERSION
  self.rubyforge_name = 'ruby-protobuf'
  self.developer('BJ Neilsen', 'bj.neilsen@gmail.com')
  self.summary = 'Protocol Buffers for Ruby'
  self.description = 'Ruby implementation for Protocol Buffers. Works with other rpc implementations'
  self.url = 'http://github.com/dcardon/ruby-protobuf'
end

task :cultivate do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end

# vim: syntax=ruby
