require 'listen'
require 'ptools'

module Drydocker
  # Configuration file reader
  class Config
    attr_reader :name, :command, :image, :entrypoint, :path

    def self.default_config
      {
        name: nil,
        image: 'silarsis/drydocker',
        command: 'rspec spec',
        entrypoint: nil,
        path: `pwd`.strip
      }
    end

    def initialize(params = {})
      config = Config.default_config.merge(params)
      @image = config[:image]
      @name = config[:name] || name_from_image
      @entrypoint = config[:entrypoint]
      @command = config[:command]
      @path = config[:path]
      @testing = config[:testing]
    end

    private

    def name_from_image
      "#{image.gsub(/[\/:]/, '-')}-test"
    end
  end

  # Class to actually run the monitor and tests
  class Monitor
    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def listen
      listener = Listen.to(config.path) do |modified, added, removed|
        puts "triggering change: #{modified + added + removed}"
        run_or_start
      end
      listener.start # not blocking
    end

    def clean_containers
      fail 'No docker found' if File.which('docker').nil?
      return unless system("docker ps | grep #{config.name}")
      `docker kill #{config.name}`
      `docker rm #{config.name}`
    end

    private

    def docker_run_cmd
      %W(
        #{docker_cmd} #{name_opt} #{path_opt} #{entrypoint_opt} #{config.image}
        #{command}
      ).reject { |x| x == '' }.join(' ')
    end

    def docker_start_cmd
      "docker start -ai #{config.name}"
    end

    def docker_check_cmd
      "docker ps -a | grep #{config.name} >/dev/null"
    end

    def docker_cmd
      'docker run -it'
    end

    def name_opt
      "--name #{config.name}"
    end

    def entrypoint_opt
      config.entrypoint.nil? ? '' : "--entrypoint #{config.entrypoint}"
    end

    def path_opt
      "-v #{config.path}:/app"
    end

    def command
      config.command.nil? ? '' : config.command
    end

    def run
      system(docker_run_cmd)
    end

    def start
      system(docker_start_cmd)
    end

    def run_or_start
      system(docker_check_cmd) ? start : run
    end
  end
end
