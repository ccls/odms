class RemoveSamplesQuantityInSample < ActiveRecord::Migration
  def self.up
		remove_column :samples, :quantity_in_sample
  end
  def self.down
		add_column :samples, :quantity_in_sample, :decimal, :precision => 8, :scale => 2
  end
end
