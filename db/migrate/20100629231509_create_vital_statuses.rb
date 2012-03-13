class CreateVitalStatuses < ActiveRecord::Migration
	def self.up
		create_table :vital_statuses do |t|
			t.integer :position
			t.string  :key, :null => false
			t.integer :code
			t.string  :description, :null => false
			t.timestamps
		end
		add_index :vital_statuses, :key,  :unique => true
		add_index :vital_statuses, :code, :unique => true
	end

	def self.down
		drop_table :vital_statuses
	end
end
