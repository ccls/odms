class CandidateControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required
	before_filter :valid_case_study_subject_required

	def edit
#	TODO add potential check for reasons to reject control
#		if any found ...
#		@candidate.reject_candidate = true
#		@candidate.rejection_reason = "the reason why we think the control should be rejected."
	end

	def update
		CandidateControl.transaction do
			if params[:candidate_control][:reject_candidate] == 'false'
				@candidate.create_study_subjects(@study_subject)
				warning = ''
				if @candidate.study_subject.identifier.icf_master_id.blank?
					warning << "Control was not assigned an icf_master_id."
				end
				if @candidate.study_subject.mother.identifier.icf_master_id.blank?
					warning << "\nMother was not assigned an icf_master_id."
				end
				flash[:warning] = warning unless warning.blank?
			end
			# don't do it this way as opens ALL the attrs for change
			#	@candidate.update_attributes()	
			@candidate.reject_candidate = params[:candidate_control][:reject_candidate]
			@candidate.rejection_reason = params[:candidate_control][:rejection_reason]
			@candidate.save!
		end
		redirect_to case_path(@study_subject)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Candidate control update failed."
		render :action => 'edit'
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
		@study_subject = StudySubject.search(
			:patid => @candidate.related_patid, 
			:types => 'case').first
		unless @study_subject
			access_denied("No valid case study subject found for that candidate!", cases_path)
		end
	end

end
