class RemoveOrganizationPersonId < ActiveRecord::Migration
  def self.up
		remove_column :organizations, :person_id
  end
  def self.down
		add_column :organizations, :person_id, :integer
  end
end
