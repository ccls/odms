class RemoveSampleLocationsPosition < ActiveRecord::Migration
  def self.up
		remove_column :sample_locations, :position
  end
  def self.down
		add_column :sample_locations, :position, :integer
  end
end
