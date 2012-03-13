class CreateInstrumentTypes < ActiveRecord::Migration
	def self.up
		create_table :instrument_types do |t|
			t.integer :position
			t.integer :project_id
			t.string  :key, :null => false
			t.string  :description
			t.timestamps
		end
		add_index :instrument_types, :key, :unique => true
		add_index :instrument_types, :description, :unique => true
	end

	def self.down
		drop_table :instrument_types
	end
end
