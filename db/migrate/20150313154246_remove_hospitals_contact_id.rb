class RemoveHospitalsContactId < ActiveRecord::Migration
  def self.up
		remove_column :hospitals, :contact_id
  end
  def self.down
		add_column :hospitals, :contact_id, :integer
  end
end
