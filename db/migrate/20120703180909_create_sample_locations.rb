class CreateSampleLocations < ActiveRecord::Migration
	def change
		create_table :sample_locations do |t|
			t.integer :position
			t.integer :organization_id
			t.text :notes
			t.boolean :is_active, :null => false, :default => true
			t.timestamps
		end
		#	could this be unique?
		add_index :sample_locations, :organization_id
	end
end
