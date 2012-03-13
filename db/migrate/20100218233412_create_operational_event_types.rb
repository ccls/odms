class CreateOperationalEventTypes < ActiveRecord::Migration
	def self.up
		create_table :operational_event_types do |t|
			t.integer :position
			t.string  :key, :null => false
			t.string  :description
			t.string  :event_category
			t.timestamps
		end
		add_index :operational_event_types, :key, :unique => true
		add_index :operational_event_types, :description, :unique => true
	end

	def self.down
		drop_table :operational_event_types
	end
end
