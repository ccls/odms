class CreateProjects < ActiveRecord::Migration
	def self.up
		create_table :projects do |t|
			t.integer :position
			t.date    :began_on
			t.date    :ended_on
			t.string  :key, :null => false
			t.string  :description
			t.text    :eligibility_criteria
			t.string  :label
			t.timestamps
		end
		add_index :projects, :key, :unique => true
		add_index :projects, :description, :unique => true
	end

	def self.down
		drop_table :projects
	end
end
