class CreateCandidateControls < ActiveRecord::Migration
	def self.up
		create_table :candidate_controls do |t|
			t.integer :birth_datum_id
			t.string  :related_patid, :limit => 5
			t.integer :study_subject_id
			t.date    :assigned_on
			t.boolean :reject_candidate, :null => false, :default => false
			t.string  :rejection_reason
			t.integer :mom_is_biomom
			t.integer :dad_is_biodad
			t.timestamps
		end
	end

	def self.down
		drop_table :candidate_controls
	end
end
