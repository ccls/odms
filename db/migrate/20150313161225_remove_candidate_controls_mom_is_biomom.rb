class RemoveCandidateControlsMomIsBiomom < ActiveRecord::Migration
  def self.up
		remove_column :candidate_controls, :mom_is_biomom
  end
  def self.down
		add_column :candidate_controls, :mom_is_biomom, :integer
  end
end
