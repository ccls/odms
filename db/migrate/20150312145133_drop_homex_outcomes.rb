class DropHomexOutcomes < ActiveRecord::Migration
	def self.down
		create_table :homex_outcomes do |t|
			t.integer :position
			t.integer :study_subject_id
			t.date    :sample_outcome_on
			t.date    :interview_outcome_on
			t.timestamps
			t.string  :interview_outcome
			t.string  :sample_outcome
		end
		add_index :homex_outcomes, :study_subject_id, :unique => true
	end

	def self.up
		drop_table :homex_outcomes
	end
end
