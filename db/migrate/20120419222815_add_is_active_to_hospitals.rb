class AddIsActiveToHospitals < ActiveRecord::Migration
	def change
		add_column :hospitals, :is_active, :boolean, :null => false, :default => true
	end
end
