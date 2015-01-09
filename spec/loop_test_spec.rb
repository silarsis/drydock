require 'spec_helper'
require 'loop_test'

module LoopTest
  describe Config do
    specify { expect { Config.new('nosuchfile') }.to raise_exception }
    context 'with basic configuration' do
      let(:config) { Config.new('spec/fixtures/basic.yaml') }
      specify { expect(config.name).to eq 'basic-test' }
      specify { expect(config.entrypoint).to be_nil }
      specify { expect(config.image).to eq 'silarsis/test-image' }
      specify { expect(config.command).to eq '/app/test.sh' }
    end
  end

  describe Monitor do
    let(:config) { LoopTest::Config.new('spec/fixtures/basic.yaml') }
    let(:monitor) { Monitor.new(config) }

    describe '#monitor' do
      it 'should run the docker run command the first time' do
        expect(monitor).to receive(:system).with("docker ps -a | grep #{config.name} >/dev/null").and_return false
        expect(monitor).to receive(:system).with("docker run -it --name #{config.name} -v #{config.path}:/app #{config.image} #{config.command}").and_return true
        monitor.send(:run_or_start)
      end

      it 'should run the docker start command the second time' do
        expect(monitor).to receive(:system).with("docker ps -a | grep #{config.name} >/dev/null").and_return true
        expect(monitor).to receive(:system).with("docker start -ai #{config.name}").and_return true
        monitor.send(:run_or_start)
      end
    end

  end
end
