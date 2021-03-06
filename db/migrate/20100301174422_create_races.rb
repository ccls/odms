class CreateRaces < ActiveRecord::Migration
	def self.up
		create_table :races do |t|
			t.integer :position
			t.string  :key, :null => false
			t.integer :code
			t.string  :description
			t.timestamps
		end
		add_index :races, :key, :unique => true
		add_index :races, :code, :unique => true
		add_index :races, :description, :unique => true
	end

	def self.down
		drop_table :races
	end
end
