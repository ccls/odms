class CandidateControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required
	before_filter :valid_case_study_subject_required
	before_filter :unused_candidate_control_required

	def edit
		reasons = []
		if @study_subject.dob != @candidate.dob
			@candidate.reject_candidate = true
			reasons << "DOB does not match."
		end
		if @study_subject.sex != @candidate.sex
			@candidate.reject_candidate = true
			reasons << "Sex does not match."
		end
		@candidate.rejection_reason = reasons.join("\n") unless reasons.empty?
	end

	def update
		CandidateControl.transaction do
			if params[:candidate_control][:reject_candidate] == 'false'
				@candidate.create_study_subjects(@study_subject,'6')	#	'6' is default anyway
				warn = []
				if @candidate.study_subject.identifier.icf_master_id.blank?
					warn << "Control was not assigned an icf_master_id."
				end
				if @candidate.study_subject.mother.identifier.icf_master_id.blank?
					warn << "Mother was not assigned an icf_master_id."
				end
				flash[:warn] = warn.join('<br/>') unless warn.empty?
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
	rescue ActiveRecord::StatementInvalid => e
		flash.now[:error] = "Database error.  Check production logs and contact Jake."
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
		@study_subject = StudySubject.find_case_by_patid(@candidate.related_patid)
		if @study_subject.blank?
			access_denied("No valid case study subject found for that candidate!", cases_path)
		end
	end

	def unused_candidate_control_required
		unless @candidate.study_subject_id.blank?
			access_denied("Candidate is already used!", case_path(@study_subject.id))
		end
	end

end
