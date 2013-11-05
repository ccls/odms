class RemoveTracingStatusIdFromEnrollments < ActiveRecord::Migration
	def up
		remove_column :enrollments, :tracing_status_id
	end

	def down
		add_column :enrollments, :tracing_status_id, :integer
	end
end
