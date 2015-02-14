class CreateSampleTypes < ActiveRecord::Migration
	def self.up
		create_table :sample_types do |t|
			t.integer :position
			t.integer :parent_id
			t.string  :key, :null => false
			t.string  :description
			t.boolean :for_new_sample, :default => true, :null => false
			t.integer :t2k_sample_type_id
			t.string  :gegl_sample_type_id
			t.timestamps
		end
		add_index :sample_types, :parent_id
		add_index :sample_types, :key, :unique => true
		add_index :sample_types, :description, :unique => true
	end

	def self.down
		drop_table :sample_types
	end
end
