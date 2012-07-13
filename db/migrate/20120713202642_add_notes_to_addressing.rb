class AddNotesToAddressing < ActiveRecord::Migration
	def change
		add_column :addressings, :notes, :text
	end
end
