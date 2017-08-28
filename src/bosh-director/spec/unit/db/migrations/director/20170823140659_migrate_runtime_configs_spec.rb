require_relative '../../../../db_spec_helper'

module Bosh::Director
  describe 'change id from int to bigint variable_sets & variables' do
    let(:db) {DBSpecHelper.db}
    let(:migration_file) {'20170823140659_migrate_runtime_configs.rb'}
    let(:some_time) do
      Time.at(Time.now.to_i).utc
    end

    before do
      DBSpecHelper.migrate_all_before(migration_file)
    end

    describe 'runtime_configs' do

      context 'without name' do
        it 'copies config data into config table and updates deployments runtime configs table' do
          db[:deployments] << { name: 'fake-name'}
          db[:runtime_configs] << { properties: 'old content', created_at: some_time }
          db[:deployments_runtime_configs] << { deployment_id: 1, runtime_config_id: 1 }

          DBSpecHelper.migrate(migration_file)

          expect(db[:configs].count).to eq(1)
          deployment_runtime = db[:deployments_runtime_configs].first
          expect(deployment_runtime[:runtime_config_id]).to be
          expect(deployment_runtime[:runtime_config_old_id]).to be
          new_config = db[:configs].where(id: deployment_runtime[:runtime_config_id]).first
          expect(new_config).to include({
            type: 'runtime',
            name: 'default',
            content: 'old content',
            created_at: some_time
          })
        end

      end

      context 'with name' do
        it 'copies config data into config table and updates deployments runtime configs table' do
          db[:deployments] << { name: 'fake-name'}
          db[:runtime_configs] << { properties: 'old content with name', name: 'old_name', created_at: some_time }
          db[:deployments_runtime_configs] << { deployment_id: 1, runtime_config_id: 1 }

          DBSpecHelper.migrate(migration_file)

          deployment_runtime_with_name = db[:deployments_runtime_configs].first
          expect(deployment_runtime_with_name[:runtime_config_id]).to be
          expect(deployment_runtime_with_name[:runtime_config_old_id]).to be
          new_config_with_name = db[:configs].where(id: deployment_runtime_with_name[:runtime_config_id]).first
          expect(new_config_with_name).to include({
            type: 'runtime',
            name: 'old_name',
            content: 'old content with name',
            created_at: some_time
          })
        end

      end

      it 'changes the foreign key of runtime_config_id' do
        DBSpecHelper.migrate(migration_file)

        expect(db.foreign_key_list(:deployments_runtime_configs).size).to eq(2) # deployment_id and runtime_config_id
        configs_foreign_key = db.foreign_key_list(:deployments_runtime_configs).select { |entry| entry[:table] == :configs }.first
        expect(configs_foreign_key).to include(
          columns: [:runtime_config_id],
          table: :configs
        )
      end
    end
  end
end