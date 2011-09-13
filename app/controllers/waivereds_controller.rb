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
		@study_subject = StudySubject.new(params[:study_subject].to_hash.deep_merge({
			'subject_type_id' => SubjectType['Case'].id,
			'identifier_attributes' => {
#				'orderno' => 0,
				'case_control_type' => 'C'
			}
		}))
		@study_subject.save!
		redirect_to @study_subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject creation failed"
		render :action => 'new'
	end

end
