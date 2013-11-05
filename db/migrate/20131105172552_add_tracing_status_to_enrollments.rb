class AddTracingStatusToEnrollments < ActiveRecord::Migration
	def change
		add_column :enrollments, :tracing_status, :string
	end
end
