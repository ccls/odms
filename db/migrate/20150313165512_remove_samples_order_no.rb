class RemoveSamplesOrderNo < ActiveRecord::Migration
  def self.up
		remove_column :samples, :order_no
  end
  def self.down
		add_column :samples, :order_no, :integer
  end
end
