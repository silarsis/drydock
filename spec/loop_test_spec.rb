require 'spec_helper'
require 'loop_test'

# Tests for the main module
module LoopTest
  describe Config do
    context 'with basic configuration' do
      let(:config) { Config.new }
      specify { expect(config.name).to eq 'loop_test-test' }
      specify { expect(config.entrypoint).to be_nil }
      specify { expect(config.image).to eq 'loop_test' }
      specify { expect(config.command).to eq 'rspec spec' }
    end
    context 'with provide value for' do
      context 'name' do
        let(:config) { Config.new(name: 'args-test') }
        specify { expect(config.name).to eq 'args-test' }
      end
      context 'command' do
        let(:config) { Config.new(command: 'args-test') }
        specify { expect(config.command).to eq 'args-test' }
      end
      context 'image' do
        let(:config) { Config.new(image: 'args-test') }
        specify { expect(config.image).to eq 'args-test' }
      end
      context 'entrypoint' do
        let(:config) { Config.new(entrypoint: 'args-test') }
        specify { expect(config.entrypoint).to eq 'args-test' }
      end
      context 'path' do
        let(:config) { Config.new(path: 'args-test') }
        specify { expect(config.path).to eq 'args-test' }
      end
    end
  end

  describe Monitor do
    let(:config) { LoopTest::Config.new }
    let(:monitor) { Monitor.new(config) }

    describe '#monitor' do
      it 'should run the docker container the first time' do
        expect(monitor).to receive(:system) \
          .with("docker ps -a | grep #{config.name} >/dev/null") \
          .and_return false
        expect(monitor).to receive(:system) \
          .with("docker run -it --name #{config.name} -v #{config.path}:/app #{config.image} #{config.command}") \
          .and_return true
        monitor.send(:run_or_start)
      end

      it 'should start the docker container the second time' do
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
