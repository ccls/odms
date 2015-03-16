class RemoveSampleLocationsNotes < ActiveRecord::Migration
  def self.up
		remove_column :sample_locations, :notes
  end
  def self.down
		add_column :sample_locations, :notes, :text
  end
end
