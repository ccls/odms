class ControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_case_id_required, :only => :create
	before_filter :case_study_subject_required, :only => :create

	def new
		unless params[:q].blank?
			q = params[:q].squish
			@study_subject = if( q.length <= 4 )
				patid = sprintf("%04d",q.to_i)
				StudySubject.find_case_by_patid(patid)
			else
				StudySubject.find_case_by_icf_master_id(q)
			end
			flash.now[:error] = "No case study_subject found with given" <<
				":#{params[:q]}" unless @study_subject
		end
	end

	def create
		candidate = CandidateControl.unassigned.unrejected.related_patid(
			@study_subject.patid ).limit(1).first	#	scopes always return arrays
		if candidate
			redirect_to edit_candidate_control_path(candidate)
		else
			flash[:error] = "Sorry, but no candidate controls were found matching this subject."
			redirect_to study_subject_related_subjects_path(@study_subject.id)
		end
	end

protected

	def valid_case_id_required
		if !params[:case_id].blank? and StudySubject.exists?(params[:case_id])
			@study_subject = StudySubject.find(params[:case_id])
		else
			access_denied("Valid study_subject case_id required!", new_control_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", new_control_path)
		end
	end

end
