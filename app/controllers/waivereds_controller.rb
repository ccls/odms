class WaiveredsController < ApplicationController

	before_filter :may_create_study_subjects_required

	def new
		@study_subject = StudySubject.new
	end

	def create
		#	deep_merge does not work correctly with a HashWithIndifferentAccess
		#	convert to hash, but MUST use string keys, not symbols as
		#		real requests do not send symbols
#	hopefully, these options will be done from within the study_subject model
		StudySubject.transaction do
			@study_subject = StudySubject.new(params[:study_subject].to_hash.deep_merge({
				'subject_type_id' => SubjectType['Case'].id,
				'identifier_attributes' => {
					'case_control_type' => 'C'
				}
			}))
			@study_subject.save!
			@study_subject.assign_icf_master_id
			@study_subject.create_mother

			warn = ''
			if @study_subject.identifier.icf_master_id.blank?
				warn << "Control was not assigned an icf_master_id."
			end
			if @study_subject.mother.identifier.icf_master_id.blank?
				warn << "\nMother was not assigned an icf_master_id."
			end
			flash[:warn] = warn unless warn.blank?
		end
		redirect_to @study_subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject creation failed"
		render :action => 'new'
	end

end
