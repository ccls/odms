class DropSampleOutcomes < ActiveRecord::Migration
	def self.up
		drop_table :sample_outcomes
		remove_column :homex_outcomes, :sample_outcome_id
		add_column :homex_outcomes, :sample_outcome, :string
	end

	def self.down
		create_table :sample_outcomes do |t|
			t.integer :position
			t.string  :key, :null => false
			t.string  :description
			t.timestamps
		end
		add_index :sample_outcomes, :key, :unique => true
		remove_column :homex_outcomes, :sample_outcome
		add_column :homex_outcomes, :sample_outcome_id, :integer
	end
end
