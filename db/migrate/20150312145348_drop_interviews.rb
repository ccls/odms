class DropInterviews < ActiveRecord::Migration
	def self.down
		create_table :interviews do |t|
			t.integer :position
			t.integer :study_subject_id
			t.integer :address_id
			t.integer :interviewer_id
			t.integer :instrument_version_id
			t.integer :interview_method_id
			t.integer :language_id
			t.string  :respondent_first_name
			t.string  :respondent_last_name
			t.string  :other_subject_relationship
			t.date    :intro_letter_sent_on
			t.boolean :consent_read_over_phone
			t.boolean :respondent_requested_new_consent
			t.boolean :consent_reviewed_with_respondent
			t.datetime :began_at
			t.datetime :ended_at
			t.timestamps
			t.string  :subject_relationship
		end
		add_index :interviews, :study_subject_id
	end

	def self.up
		drop_table :interviews
	end
end
