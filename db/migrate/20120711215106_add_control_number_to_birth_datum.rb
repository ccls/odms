class AddControlNumberToBirthDatum < ActiveRecord::Migration
	def change
		add_column :birth_data, :control_number, :integer
	end
end
