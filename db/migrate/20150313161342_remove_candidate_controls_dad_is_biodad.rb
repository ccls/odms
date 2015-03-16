class RemoveCandidateControlsDadIsBiodad < ActiveRecord::Migration
  def self.up
		remove_column :candidate_controls, :dad_is_biodad
  end
  def self.down
		add_column :candidate_controls, :dad_is_biodad, :integer
  end
end
