Gem::Specification.new do |s|
  s.name             = "rantly"
  s.summary          = "Ruby Imperative Random Data Generator and Quickcheck"
  s.homepage         = "https://github.com/abargnesi/rantly"
  s.version          = "1.1.0"
  s.require_paths    = ["lib"]
  s.authors          = ["Howard Yeh", "Anthony Bargnesi", "Eric Bischoff"]
  s.email            = ["hayeah@gmail.com", "abargnesi@gmail.com", "ebischoff@nerim.net"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile",
    "CHANGELOG.md"
  ]
  s.files            = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "LICENSE",
    "README.textile",
    "CHANGELOG.md",
    "Rakefile",
    "VERSION.yml",
    "lib/rantly.rb",
    "lib/rantly/data.rb",
    "lib/rantly/generator.rb",
    "lib/rantly/minitest.rb",
    "lib/rantly/minitest_extensions.rb",
    "lib/rantly/property.rb",
    "lib/rantly/rspec.rb",
    "lib/rantly/rspec_extensions.rb",
    "lib/rantly/shrinks.rb",
    "lib/rantly/silly.rb",
    "lib/rantly/spec.rb",
    "lib/rantly/testunit_extensions.rb",
    "rantly.gemspec",
    "test/rantly_test.rb",
    "test/shrinks_test.rb",
    "test/test_helper.rb"
  ]
  s.required_ruby_version = '>= 2.4.0'

  s.add_development_dependency('rake',      '~> 12.0.0')
  s.add_development_dependency('minitest',  '~> 5.10.0')
  s.add_development_dependency('simplecov', '>= 0')
  s.add_development_dependency('coveralls', '>= 0')
end

