# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{Rant}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Howard Yeh"]
  s.date = %q{2009-08-28}
  s.email = %q{hayeah@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    "LICENSE",
    "README.textile",
    "Rakefile",
    "Rant.gemspec",
    "VERSION.yml",
    "lib/rant.rb",
    "lib/rant/check.rb",
    "lib/rant/data.rb",
    "lib/rant/generator.rb",
    "lib/rant/silly.rb",
    "test/rant_test.rb",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hayeah/rant}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby Imperative Random Data Generator and Quickcheck}
  s.test_files = [
    "test/rant_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
