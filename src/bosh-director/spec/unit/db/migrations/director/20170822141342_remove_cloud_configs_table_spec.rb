require_relative '../../../../db_spec_helper'

module Bosh::Director
  describe 'remove old cloud configs' do
    let(:db) { DBSpecHelper.db }
    let(:migration_file) { '20170822141342_remove_cloud_configs_table.rb' }

    before { DBSpecHelper.migrate_all_before(migration_file) }

    it 'drops the cloud_configs table' do
      DBSpecHelper.migrate(migration_file)

      expect(db.table_exists?(:cloud_configs)).to eq(false)
    end

    it 'removes the old cloud_config_id from deployments' do
      DBSpecHelper.migrate(migration_file)

      expect(db[:deployments].columns.include?(:cloud_config_old_id)).to be_falsey
    end
  end
end