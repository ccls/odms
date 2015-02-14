class CreateSubjectRaces < ActiveRecord::Migration
	def self.up
		create_table :subject_races do |t|
			t.integer :study_subject_id
			t.integer :race_code
			t.boolean :is_primary, :default => false, :null => false
			t.string  :other_race
			t.timestamps
		end
		add_index :subject_races, :study_subject_id
	end

	def self.down
		drop_table :subject_races
	end
end
