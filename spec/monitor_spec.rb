require "spec_helper"
require "drydocker/monitor"
require "shellwords"

# Tests for the main module
module Drydocker
  describe Monitor do
    let(:config) { Config.new(name: "spec-container") }
    let(:monitor) { Monitor.new(config) }

    describe "#monitor" do
      it "should run the docker container the first time" do
        expect(monitor).to receive(:system) \
          .with("docker ps -a | grep #{config.name} >/dev/null") \
          .and_return false
        expect(monitor).to receive(:system) \
          .with("docker run -it -w /app -e RUBYOPT -e SPEC_OPTS -e RSPEC_OPTS --name #{config.name} -v #{config.path}:/app #{config.image} sh -c #{config.command}") \
          .and_return true
        monitor.send(:run_or_start)
      end

      it "should start the docker container the second time" do
        expect(monitor).to receive(:system) \
          .with("docker ps -a | grep #{config.name} >/dev/null") \
          .and_return true
        expect(monitor).to receive(:system) \
        .with("docker start -ai #{config.name}") \
        .and_return true
        monitor.send(:run_or_start)
      end
    end

  end
end
