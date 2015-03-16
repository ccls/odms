class RemoveSamplesReceiptConfirmedBy < ActiveRecord::Migration
  def self.up
		remove_column :samples, :receipt_confirmed_by
  end
  def self.down
		add_column :samples, :receipt_confirmed_by, :string
  end
end
