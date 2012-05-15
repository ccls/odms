class CandidateControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required
	before_filter :valid_case_study_subject_required
	before_filter :unused_candidate_control_required

	def edit
		prereject_candidate
	end

	def update
		warn = []
		#	by presetting them, we keep them should we bounce back to edit
		@candidate.reject_candidate = params[:candidate_control][:reject_candidate]
		@candidate.rejection_reason = params[:candidate_control][:rejection_reason]
		CandidateControl.transaction do
			unless @candidate.reject_candidate
				#	regular create submit	#	tests DO NOT SEND params[:commit] = 'Submit'
				#	this form's submit button is 'continue' NOT 'Submit'
				if params[:commit].blank? or params[:commit] == 'continue'
					@duplicates = StudySubject.duplicates(
						:sex => @candidate.sex,
						:dob => @candidate.dob,
						:mother_maiden_name => @candidate.mother_maiden_name,
						:exclude_id => @study_subject.id)
					raise StudySubject::DuplicatesFound unless @duplicates.empty?
				end	#	if params[:commit].blank? or params[:commit] == 'Submit'

				if params[:commit] == 'Match Found'
					@duplicates = StudySubject.duplicates(
						:sex => @candidate.sex,
						:dob => @candidate.dob,
						:mother_maiden_name => @candidate.mother_maiden_name,
						:exclude_id => @study_subject.id)

					if params[:duplicate_id] and
							( duplicate = StudySubject.find_by_id(params[:duplicate_id]) ) and
							@duplicates.include?(duplicate)
						@candidate.reject_candidate = true
						@candidate.rejection_reason = "ineligible control - "
						if duplicate.is_case?
							@candidate.rejection_reason << "child is already a case subject."
						else	#	is a control
							@candidate.rejection_reason << "control already exists in system."
						end
					else
						#
						#	Match Found, but no duplicate_id or subject with the id
						#
						warn << "No valid duplicate_id given"
						raise StudySubject::DuplicatesFound unless @duplicates.empty?
					end

				#	params[:commit].blank? or params[:commit] == 'Submit' 
				#		or params[:commit] == 'No Match'
				else
					#	No duplicates found or if there were, not matches.
					#	Transactions are only for marking a rollback point.
					#	The raised error will still kick all the way out.
					@candidate.create_study_subjects(@study_subject,'6')	#	'6' is default anyway
					if @candidate.study_subject.icf_master_id.blank?
						warn << "Control was not assigned an icf_master_id."
					end
					if @candidate.study_subject.mother.icf_master_id.blank?
						warn << "Mother was not assigned an icf_master_id."
					end
					flash[:warn] = warn.join('<br/>') unless warn.empty?
				end	#	else of if params[:commit] == 'Match Found'
			end	#	if params[:candidate_control][:reject_candidate] == 'false'

			@candidate.save!
		end	#	CandidateControl.transaction do
		redirect_to study_subject_related_subjects_path(@study_subject)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Candidate control update failed."
		render :action => 'edit'
	rescue ActiveRecord::StatementInvalid => e
		flash.now[:error] = "Database error.  Check production logs and contact Jake."
		render :action => 'edit'
	rescue StudySubject::DuplicatesFound
		flash.now[:error] = "Possible Duplicate(s) Found."
		flash.now[:warn] = warn.join('<br/>') unless warn.empty?
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
#
#		@study_subject = StudySubject.find_case_by_patid(@candidate.related_patid)
#test_should_put_update_with_superuser_login_and_accept_candidate(CandidateControlsControllerTest):
#ActiveRecord::ReadOnlyRecord: ActiveRecord::ReadOnlyRecord
#    app/models/candidate_control.rb:80:in `create_study_subjects'
#    app/models/candidate_control.rb:38:in `create_study_subjects'
#    app/controllers/candidate_controls_controller.rb:61:in `update'
#
#	Apparently some scopes, 'joins' seems likely, can set readonly.  Don't know why,
#		but explicitly setting readonly to false stops the error.
#
		@study_subject = StudySubject.cases.with_patid(@candidate.related_patid).readonly(false).first

		if @study_subject.blank?
			access_denied("No valid case study subject found for that candidate!", cases_path)
		end
	end

	def unused_candidate_control_required
		unless @candidate.study_subject_id.blank?
			access_denied("Candidate is already used!", 
				study_subject_related_subjects_path(@study_subject.id))
		end
	end

	def prereject_candidate
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

end
