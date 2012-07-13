class CreateInterviewAssignments < ActiveRecord::Migration
	def change
		create_table :interview_assignments do |t|
			t.integer :study_subject_id
			t.date    :sent_on
			t.date    :returned_on
			t.boolean :needs_hosp_search
			t.string  :status
			t.text    :notes_for_interviewer
			t.timestamps
		end
	end
end
