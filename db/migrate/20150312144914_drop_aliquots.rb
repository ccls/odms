class DropAliquots < ActiveRecord::Migration
	def self.down
		create_table :aliquots do |t|
			t.integer :position
			t.integer :owner_id
			t.integer :sample_id
			t.integer :unit_id
			t.string  :location
			t.string  :mass
			t.string  :external_aliquot_id
			t.string  :external_aliquot_id_source
			t.timestamps
		end
		add_index :aliquots, :owner_id
		add_index :aliquots, :sample_id
		add_index :aliquots, :unit_id
	end

	def self.up
		drop_table :aliquots
	end
end
