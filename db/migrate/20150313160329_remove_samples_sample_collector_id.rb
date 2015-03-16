class RemoveSamplesSampleCollectorId < ActiveRecord::Migration
  def self.up
		remove_column :samples, :sample_collector_id
  end
  def self.down
		add_column :samples, :sample_collector_id, :integer
  end
end
