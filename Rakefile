# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'drydocker'
  gem.homepage = 'http://github.com/silarsis/drydocker'
  gem.license = 'MIT'
  gem.summary = 'Test something in a loop, in a docker container'
  gem.description = 'Run tests on change in a docker container continuously'
  gem.email = 'kevin@littlejohn.id.au'
  gem.authors = ['Kevin Littlejohn']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

desc 'Code coverage detail'
task :simplecov do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

task default: :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "drydocker #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :build do
  desc 'Build the Docker container'
  task :docker do
    system('docker build -t silarsis/drydocker .')
  end
end
