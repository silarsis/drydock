require 'listen'
require 'ptools'
require 'logger'
require 'shellwords'

module Drydocker
  # Configuration file reader
  class Config
    attr_reader :name, :command, :image, :entrypoint, :path, :verbose, :logger

    def self.default_config
      {
        name: nil,
        image: 'silarsis/drydocker',
        command: 'rspec spec',
        entrypoint: nil,
        path: `pwd`.strip,
        verbose: false
      }
    end

    def initialize(params = {})
      config = Config.default_config.merge(params)
      @image = config[:image]
      @name = config[:name] || name_from_image
      @entrypoint = config[:entrypoint]
      @command = config[:command].shellescape
      @path = config[:path]
      @logger = Logger.new(STDERR)
      @logger.level = Logger::DEBUG if config[:verbose]
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
        config.logger.info("triggering change: #{modified + added + removed}")
        run_or_start
      end
      listener.start # not blocking
      config.logger.info('now listening')
    end

    def clean_containers
      fail 'No docker found' if File.which('docker').nil?
      return unless system(docker_check_cmd)
      config.logger.debug('cleaning up previous containers')
      `docker kill #{config.name}`
      `docker rm #{config.name}`
    end

    private

    def docker_run_cmd
      %W(
        #{docker_cmd} #{name_opt} #{path_opt} #{entrypoint_opt} #{config.image}
        sh -c #{command}
      ).reject { |x| x == '' }.join(' ')
    end

    def docker_start_cmd
      "docker start -ai #{config.name}"
    end

    def docker_check_cmd
      "docker ps -a | grep #{config.name} >/dev/null"
    end

    def docker_cmd
      'docker run -it -w /app'
    end

    def name_opt
      "--name #{config.name}"
    end

    def entrypoint_opt
      config.entrypoint.nil? ? '' : "--entrypoint #{config.entrypoint.shellescape}"
    end

    def path_opt
      "-v #{config.path}:/app"
    end

    def command
      config.command.nil? ? '' : config.command
    end

    def run
      config.logger.debug(docker_run_cmd)
      system(docker_run_cmd)
    end

    def start
      config.logger.debug(docker_start_cmd)
      system(docker_start_cmd)
    end

    def run_or_start
      system(docker_check_cmd) ? start : run
    end
  end
end
