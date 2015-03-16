class RemoveSamplesState < ActiveRecord::Migration
  def self.up
		remove_column :samples, :state
  end
  def self.down
		add_column :samples, :state, :string
  end
end
