class StudySubject::RelatedSubjectsController < StudySubjectController

	before_filter :may_create_study_subjects_required

	def index
		@unrejected_controls = CandidateControl.with_related_patid(
			@study_subject.patid).unassigned.unrejected
		@matching_subjects = @study_subject.matching.order('last_name, first_name')
		@rejected_controls = @study_subject.rejected_controls
	end

end
