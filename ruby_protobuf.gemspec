# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby_protobuf}
  s.version = "0.4.0.1"

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
