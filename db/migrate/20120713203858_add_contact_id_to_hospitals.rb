class AddContactIdToHospitals < ActiveRecord::Migration
	def change
		add_column :hospitals, :contact_id, :integer
	end
end
