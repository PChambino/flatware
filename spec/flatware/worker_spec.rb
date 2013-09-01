require 'spec_helper'

describe Flatware::Worker do
  context 'when a worker is started' do
    after { Flatware.close }

    it 'exits when dispatch is done' do
      pid = fork { described_class.listen! }
      task = Flatware.socket ZMQ::REP, bind: Flatware::Dispatcher::PORT
      task.recv
      task.send 'seppuku'

      waitall
      child_pids.should_not include pid
    end

    it 'exits when fired' do
      fork do
        Flatware::Fireable.bind
        task = Flatware.socket ZMQ::REP, bind: Flatware::Dispatcher::PORT
        task.recv.should eq 'ready'
        Flatware::Fireable.kill
      end
      pid = fork { described_class.listen! }
      wait pid
    end
  end
end
