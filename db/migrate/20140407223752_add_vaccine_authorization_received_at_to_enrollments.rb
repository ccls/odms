class AddVaccineAuthorizationReceivedAtToEnrollments < ActiveRecord::Migration
	def change
		add_column :enrollments, :vaccine_authorization_received_at, :datetime
	end
end
