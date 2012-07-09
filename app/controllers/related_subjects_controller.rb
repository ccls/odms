class RelatedSubjectsController < ApplicationController

	layout 'subject'

	#	may create?  Perhaps, just may read.
	before_filter :may_create_study_subjects_required
	before_filter :valid_study_subject_id_required

	def index
		@unrejected_controls = CandidateControl.related_patid(
			@study_subject.patid).unassigned.unrejected
		#@control_subjects  = @study_subject.controls
		@matching_subjects = @study_subject.matching.order('last_name, first_name')
		#@family_subjects   = @study_subject.family
		@rejected_controls = @study_subject.rejected_controls
	end

end
