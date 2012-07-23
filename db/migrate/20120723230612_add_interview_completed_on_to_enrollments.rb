class AddInterviewCompletedOnToEnrollments < ActiveRecord::Migration
	def change
		add_column :enrollments, :interview_completed_on, :date
	end
end
