class RemoveSamplesReceiptConfirmedAt < ActiveRecord::Migration
  def self.up
		remove_column :samples, :receipt_confirmed_at
  end
  def self.down
		add_column :samples, :receipt_confirmed_at, :datetime
  end
end
