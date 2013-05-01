class AddDeceasedToBirthDatum < ActiveRecord::Migration
	def change
		add_column :birth_data, :deceased, :string
	end
end
