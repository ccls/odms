class CreateBirthDataChanges < ActiveRecord::Migration
	def change
		create_table :birth_data_changes do |t|
			t.integer :birth_data_update_id
			t.integer :birth_data_id
			t.boolean :new_data_record, :default => false, :null => false
			t.string  :modified_column
			t.string  :previous_value
			t.string  :new_value
			t.timestamps
		end
	end
end
