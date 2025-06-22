# frozen_string_literal: true

require 'rake'

task default: %i[test rubocop]

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rubocop/rake_task'

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
end

RuboCop::RakeTask.new('rubocop:auto_gen_config') do |task|
  task.options = ['--display-cop-names', '--auto-gen-config', '--auto-gen-only-exclude']
end

require 'rdoc/task'

Rake::RDocTask.new do |rdoc|
  require 'yaml'
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ''
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rant #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
