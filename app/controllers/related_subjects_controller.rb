class RelatedSubjectsController < ApplicationController

	layout 'subject'

	#	may create?  Perhaps, just may read.
	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required, :only => :show

	#	using the index action seems like it would be more
	#	appropriate, but then it would need to be a nested
	#	controller ... study_subjects/:id/related_subjects
	#	Nicer perhaps, but no different functionally.
	def show
		@unrejected_controls = CandidateControl.related_patid(
			@study_subject.patid).unassigned.unrejected
		#@control_subjects  = @study_subject.controls
		@matching_subjects = @study_subject.matching
		#@family_subjects   = @study_subject.family
		@rejected_controls = @study_subject.rejected_controls
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", cases_path)
		end
	end

end
