class AddAssignedForInterviewAtToEnrollments < ActiveRecord::Migration
	def change
		add_column :enrollments, :assigned_for_interview_at, :datetime
	end
end
