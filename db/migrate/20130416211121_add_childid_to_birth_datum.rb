class AddChildidToBirthDatum < ActiveRecord::Migration
	def change
		add_column :birth_data, :childid, :integer
	end
end
