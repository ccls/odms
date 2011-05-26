class WaiveredsController < ApplicationController

	before_filter :may_create_subjects_required

	def new
		@subject = Subject.new
	end

	def create
#	deep_merge does not work correctly with a HashWithIndifferentAccess
#	convert to hash, but MUST use string keys, not symbols as
#		real request do not send symbols
		@subject = Subject.new(params[:subject].to_hash.deep_merge({
			'subject_type_id' => SubjectType['Case'].id,
			'identifier_attributes' => {
				'orderno' => 0,
				'case_control_type' => 'C'
			}
		}))
		@subject.save!
		redirect_to @subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Subject creation failed"
		render :action => 'new'
	end

end
