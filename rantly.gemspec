Gem::Specification.new do |s|
  s.name             = "rantly"
  s.summary          = "Ruby Imperative Random Data Generator and Quickcheck"
  s.homepage         = "https://github.com/rantly-rb/rantly"
  s.version          = "1.2.0"
  s.license          = "MIT"
  s.require_paths    = ["lib"]
  s.authors          = ["Ana María Martínez Gómez", "Howard Yeh", "Anthony Bargnesi", "Eric Bischoff"]
  s.email            = ["anamma06@gmail.com", "hayeah@gmail.com", "abargnesi@gmail.com", "ebischoff@nerim.net"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]
  s.files            = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "LICENSE",
    "README.md",
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
end

