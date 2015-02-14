class CreateEnrollments < ActiveRecord::Migration
	def self.up
		create_table :enrollments do |t|
			t.integer :position
			t.integer :study_subject_id
			t.integer :project_id
			t.string  :recruitment_priority
			t.integer :is_candidate
			t.integer :is_eligible
			t.integer :ineligible_reason_id
			t.string  :other_ineligible_reason
			t.integer :consented
			t.date    :consented_on
			t.integer :refusal_reason_id
			t.string  :other_refusal_reason
			t.integer :is_chosen
			t.string  :reason_not_chosen
			t.integer :terminated_participation
			t.string  :terminated_reason
			t.integer :is_complete
			t.date    :completed_on
			t.boolean :is_closed
			t.string  :reason_closed
			t.text    :notes
			t.integer :document_version_id
			t.date    :project_outcome_on
			t.integer :use_smp_future_rsrch
			t.integer :use_smp_future_cancer_rsrch
			t.integer :use_smp_future_other_rsrch
			t.integer :share_smp_with_others
			t.integer :contact_for_related_study
			t.integer :provide_saliva_smp
			t.integer :receive_study_findings
			t.boolean :refused_by_physician
			t.boolean :refused_by_family
			t.timestamps
			t.datetime :assigned_for_interview_at
			t.date    :interview_completed_on
			t.string  :tracing_status
			t.datetime :vaccine_authorization_received_at
			t.string  :project_outcome
		end
		add_index :enrollments, [:project_id, :study_subject_id],
			:unique => true
		add_index :enrollments, :study_subject_id
	end

	def self.down
		drop_table :enrollments
	end
end
