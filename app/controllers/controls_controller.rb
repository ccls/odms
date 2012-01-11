class ControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_case_id_required
	before_filter :case_study_subject_required

	def new
		candidate = CandidateControl.find(:first,
			:conditions => [
				"related_patid = ? AND reject_candidate = false AND assigned_on IS NULL AND study_subject_id IS NULL",
				@study_subject.patid ]
		)
		if candidate
			redirect_to edit_candidate_control_path(candidate)
		else
			flash[:error] = "Sorry, but no candidate controls were found matching this subject."
#			redirect_to case_path(@study_subject.id)
			redirect_to related_subject_path(@study_subject.id)
		end
	end

protected

	def valid_case_id_required
		if !params[:case_id].blank? and StudySubject.exists?(params[:case_id])
			@study_subject = StudySubject.find(params[:case_id])
		else
			access_denied("Valid study_subject case_id required!", cases_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", cases_path)
		end
	end

end
