class RemoveSamplesUnitId < ActiveRecord::Migration
  def self.up
		remove_column :samples, :unit_id
  end
  def self.down
		add_column :samples, :unit_id, :integer
  end
end
