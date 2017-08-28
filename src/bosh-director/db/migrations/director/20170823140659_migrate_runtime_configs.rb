Sequel.migration do
  change do

    alter_table :deployments_runtime_configs do
      drop_foreign_key [:runtime_config_id]
      rename_column :runtime_config_id, :runtime_config_old_id
      add_foreign_key :runtime_config_id, :configs
    end

    self[:runtime_configs].each do |runtime_config|
      name = runtime_config[:name].empty? ? 'default' : runtime_config[:name]
      config_id = self[:configs].insert({
        type: 'runtime',
        name: name,
        content: runtime_config[:properties],
        created_at: runtime_config[:created_at]
      })

      self[:deployments_runtime_configs].where(runtime_config_old_id: [runtime_config[:id]]).update(
        runtime_config_id: config_id
      )
    end

  end
end
