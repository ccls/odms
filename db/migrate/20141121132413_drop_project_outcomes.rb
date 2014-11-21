class DropProjectOutcomes < ActiveRecord::Migration
	def self.up
		drop_table :project_outcomes
		remove_column :enrollments, :project_outcome_id
		add_column :enrollments, :project_outcome, :string
	end

	def self.down
		create_table :project_outcomes do |t|
			t.integer :position
			t.integer :project_id
			t.string  :key, :null => false
			t.string  :description
			t.timestamps
		end
		add_index :project_outcomes, :key, :unique => true
		add_column :enrollments, :project_outcome_id, :integer
		remove_column :enrollments, :project_outcome
	end
end
