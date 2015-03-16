class RemoveSamplesAliquottedAt < ActiveRecord::Migration
  def self.up
		remove_column :samples, :aliquotted_at
  end
  def self.down
		add_column :samples, :aliquotted_at, :datetime
  end
end
