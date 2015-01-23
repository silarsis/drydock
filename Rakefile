# encoding: utf-8

# Monkey patch to add an "unindent" method for heredocs
class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

require "rubygems"
require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "rake"

def version
  File.exist?("VERSION") ? File.read("VERSION").strip : ""
end

require "jeweler"
Jeweler::Tasks.new do |gem|
  gem.name = "drydocker"
  gem.homepage = "http://github.com/silarsis/drydocker"
  gem.license = "MIT"
  gem.summary = "Test something in a loop, in a docker container"
  gem.description = "Run tests on change in a docker container continuously"
  gem.email = "kevin@littlejohn.id.au"
  gem.authors = ["Kevin Littlejohn"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

desc "Code coverage detail"
task :simplecov do
  ENV["COVERAGE"] = "true"
  Rake::Task["test"].execute
end

task default: :test

require "rdoc/task"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "drydocker #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

namespace :build do
  desc "Build the Docker container"
  task :docker do
    system("docker build -t silarsis/drydocker:#{version} .")
    system("docker tag -f silarsis/drydocker:#{version} silarsis/drydocker:latest")
  end
end

namespace :release do
  task :create_credentials do
    unless ENV["RUBYGEMS_API_KEY"].nil?
      credfile = File.expand_path("~/.gem/credentials")
      unless File.exist? credfile
        umask = File.umask 0177
        File.write(credfile, <<-EOF.unindent
          ---
          :rubygems_api_key: #{ENV["RUBYGEMS_API_KEY"]}
          EOF
        )
        File.umask umask
      end
    end
    `git config --global user.email kevin@littlejohn.id.au` if `git config user.email`.empty?
    `git config --global user.name "Kevin Littlejohn (Wercker)"` if `git config user.name`.empty?
    `git config --global push.default current` if `git config push.default`.empty?
    `git config --global github.user silarsis` if `git config github.user`.empty?
  end
  desc "Release the Docker container"
  task :docker do
    system("docker push silarsis/drydocker:#{version}")
  end
end
