class CreateBirthDatumUpdates < ActiveRecord::Migration
	def self.up
		create_table :birth_datum_updates do |t|
			t.timestamps
		end
	end

	def self.down
		drop_table :birth_datum_updates
	end
end
