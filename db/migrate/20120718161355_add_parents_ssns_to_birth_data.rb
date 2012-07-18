class AddParentsSsnsToBirthData < ActiveRecord::Migration
	def change
		add_column :birth_data, :father_ssn, :string
		add_column :birth_data, :mother_ssn, :string
	end
end
