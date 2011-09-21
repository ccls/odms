class CandidateControlsController < ApplicationController
	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required
#	before_filter :valid_case_study_subject_required
	def edit
	end
	def update
#		redirect to case_path(@study_subject)
	end
protected
	def valid_id_required
		if !params[:id].blank? and CandidateControl.exists?(params[:id])
			@candidate = CandidateControl.find(params[:id])
		else
			access_denied("Valid candidate_control id required!", cases_path)
		end
	end
	def valid_case_study_subject_required
#		@study_subject = StudySubject.search(:patid => @candidate.patid, :types => 'case').first
	end
end
