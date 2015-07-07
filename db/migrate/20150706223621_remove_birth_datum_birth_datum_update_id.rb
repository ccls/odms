class RemoveBirthDatumBirthDatumUpdateId < ActiveRecord::Migration
	def up
		remove_column :birth_data, :birth_datum_update_id
	end
	def down
		add_column :birth_data, :birth_datum_update_id, :integer
	end
end
