class DropInterviewOutcomes < ActiveRecord::Migration
	def self.up
		drop_table :interview_outcomes
		remove_column :homex_outcomes, :interview_outcome_id
		add_column :homex_outcomes, :interview_outcome, :string
	end

	def self.down
		create_table :interview_outcomes do |t|
			t.integer :position
			t.string  :key, :null => false
			t.string  :description
			t.timestamps
		end
		add_index :interview_outcomes, :key, :unique => true
		remove_column :homex_outcomes, :interview_outcome
		add_column :homex_outcomes, :interview_outcome_id, :integer
	end
end
