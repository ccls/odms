class RemoveHospitalsPosition < ActiveRecord::Migration
  def self.up
		remove_column :hospitals, :position
  end
  def self.down
		add_column :hospitals, :position, :integer
  end
end
