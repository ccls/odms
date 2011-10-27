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
#
#	can't use this modification until release of ccls_engine 3.9.5
#
				@candidate.create_study_subjects(@study_subject)	#,'6')	#	'6' is default anyway
				warn = ''
				if @candidate.study_subject.identifier.icf_master_id.blank?
					warn << "Control was not assigned an icf_master_id."
				end
				if @candidate.study_subject.mother.identifier.icf_master_id.blank?
					warn << "\nMother was not assigned an icf_master_id."
				end
				flash[:warn] = warn unless warn.blank?
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
#	TODO stop using StudySubject.search
		@study_subject = StudySubject.find_case_by_patid(@candidate.related_patid)
#		@study_subject = StudySubject.search(
#			:patid => @candidate.related_patid, 
#			:types => 'case').first
#		unless @study_subject
		if @study_subject.blank?
			access_denied("No valid case study subject found for that candidate!", cases_path)
		end
	end

end
