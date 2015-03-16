class RemovePatientTreatmentBeganOn < ActiveRecord::Migration
  def self.up
		remove_column :patients, :treatment_began_on
  end
  def self.down
		add_column :patients, :treatment_began_on, :date
  end
end
