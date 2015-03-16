class DropInterviewMethods < ActiveRecord::Migration
	def self.down
		create_table :interview_methods do |t|
			t.integer :position
			t.string  :key, :null => false
			t.string  :description
			t.timestamps
		end
		add_index :interview_methods, :key, :unique => true
	end

	def self.up
		drop_table :interview_methods
	end
end
