require 'spec_helper'

describe 'worker' do
  subject(:worker) { Bosh::Director::Worker.new(config) }
  let(:config_hash) do
    {
      'dir' => '/tmp/boshdir ',
      'db' => {
        'adapter' => 'sqlite'
      },
      'blobstore' => {
        'provider' => 'simple',
        'options' => {}
      }
    }
  end
  let(:config) { Bosh::Director::Config.load_hash(config_hash) }

  describe 'when workers is sent USR2' do
    let(:queues) { worker.queues }
    it 'should not pick up new tasks' do
      ENV['QUEUE']='normal'
      worker.prep
      expect(worker.queues).to eq(['normal'])
      Process.kill('USR2', Process.pid)
      expect(worker.queues).to eq([])
    end
  end
end