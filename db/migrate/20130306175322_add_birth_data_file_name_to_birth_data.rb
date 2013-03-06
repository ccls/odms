class AddBirthDataFileNameToBirthData < ActiveRecord::Migration
	def change
		add_column :birth_data, :birth_data_file_name, :string
	end
end
