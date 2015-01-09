require 'listen'
require 'yaml'

module LoopTest
  # Configuration file reader
  class Config
    attr_reader :name, :command, :image, :entrypoint, :path

    def default_config
      {
        'name' => 'test-container',
        'command' => 'rspec spec',
        'path' => `pwd`.strip,
      }
    end

    def initialize(filename)
      config = default_config.merge(YAML.load(open(filename)))
      @name = config['name']
      @entrypoint = config['entrypoint']
      @image = config['image']
      @command = config['command']
      @path = config['path']
    end
  end

  # Class to actually run the monitor and tests
  class Monitor
    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def listen
      listener = Listen.to(config.path) do
        run_or_start
      end
      listener.start # not blocking
    end

    private

    def docker_run_cmd
      %W(#{docker_cmd} #{name_opt} #{path_opt} #{entrypoint_opt} #{config.image} #{command}).reject { |x| x == '' }.join(' ')
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
      config.entrypoint.nil? ? nil : "--entrypoint #{config.entrypoint}"
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
