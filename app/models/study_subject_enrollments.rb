#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectEnrollments
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :enrollments
	accepts_nested_attributes_for :enrollments

	# All subjects are to have a CCLS project enrollment, so create after create.
	after_create :add_ccls_enrollment

	def add_ccls_enrollment
		enrollments.find_or_create_by_project_id(Project['ccls'].id)
	end

#Database error. Check production logs and contact Jake. #<ActiveRecord::RecordNotUnique: Mysql2::Error: Duplicate entry '10-14622' for key 'index_enrollments_on_project_id_and_study_subject_id': INSERT INTO `enrollments` (`assigned_for_interview_at`, `completed_on`, `consented`, `consented_on`, `contact_for_related_study`, `created_at`, `document_version_id`, `ineligible_reason_id`, `interview_completed_on`, `is_candidate`, `is_chosen`, `is_closed`, `is_complete`, `is_eligible`, `notes`, `other_ineligible_reason`, `other_refusal_reason`, `position`, `project_id`, `project_outcome_id`, `project_outcome_on`, `provide_saliva_smp`, `reason_closed`, `reason_not_chosen`, `receive_study_findings`, `recruitment_priority`, `refusal_reason_id`, `refused_by_family`, `refused_by_physician`, `share_smp_with_others`, `study_subject_id`, `terminated_participation`, `terminated_reason`, `tracing_status_id`, `updated_at`, `use_smp_future_cancer_rsrch`, `use_smp_future_other_rsrch`, `use_smp_future_rsrch`) VALUES (NULL, NULL, NULL, NULL, NULL, '2013-04-25 16:09:19', NULL, 3, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'Language does not include English or Spanish.', '', NULL, 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, 14622, NULL, NULL, NULL, '2013-04-25 16:09:19', NULL, NULL, NULL)>
	def ccls_enrollment
		enrollments.where(:project_id => Project['ccls'].id).first
#	for some reason, this doesn't actually find the enrollment and tries to create another one.
#	this violates the uniqueness validation and causes RAF submissions to fail.  ?????
#		enrollments.find_or_create_by_project_id(Project['ccls'].id)
	end

	#	Returns all projects for which the study_subject
	#	does not have an enrollment
	def unenrolled_projects
		#	broke up to try to make 100% coverage (20120411)
		projects = Project.joins("LEFT JOIN enrollments ON " <<
				"projects.id = enrollments.project_id AND " <<
				"enrollments.study_subject_id = #{self.id}" )
		#	everything is NULL actually, but check study_subject_id
		projects = projects.where("enrollments.study_subject_id IS NULL")
	end

end	#	class_eval
end	#	included
end	#	StudySubjectEnrollments
