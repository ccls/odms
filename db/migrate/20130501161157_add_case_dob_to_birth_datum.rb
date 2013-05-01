class AddCaseDobToBirthDatum < ActiveRecord::Migration
	def change
		add_column :birth_data, :case_dob, :date
	end
end
