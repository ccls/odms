class NonwaiveredsController < ApplicationController

	before_filter :may_create_subjects_required

	def new
		@subject = Subject.new
	end

	def create
#	deep_merge does not work correctly with a HashWithIndifferentAccess
#	convert to hash, but MUST use string keys, not symbols as
#		real request do not send symbols

		subject_params = params[:subject].to_hash.deep_merge({
			'subject_type_id' => SubjectType['Case'].id,
			'identifier_attributes' => {
				'orderno' => 0,
				'case_control_type' => 'C'
			}
		})
		unless subject_params.dig("enrollments_attributes","0","consented_on").blank?
			subject_params["enrollments_attributes"]["0"]["consented"] = 1
		end
		@subject = Subject.new(subject_params)
		@subject.save!
		redirect_to @subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Subject creation failed"
		render :action => 'new'
	end

end
