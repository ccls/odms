class CreateSubjectRaces < ActiveRecord::Migration
	def self.up
		create_table :subject_races do |t|
			t.integer :study_subject_id
			t.integer :race_id
			t.boolean :is_primary, :default => false, :null => false
#			t.string  :other
			t.string  :other_race
			t.timestamps
		end
	end

	def self.down
		drop_table :subject_races
	end
end
