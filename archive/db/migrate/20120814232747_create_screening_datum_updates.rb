class CreateScreeningDatumUpdates < ActiveRecord::Migration
	def change
		create_table :screening_datum_updates do |t|
			t.timestamps
		end
	end
end
