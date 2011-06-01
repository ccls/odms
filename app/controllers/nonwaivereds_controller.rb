class NonwaiveredsController < ApplicationController

	before_filter :may_create_subjects_required

	def new
		@subject = Subject.new
	end

	def create
#	deep_merge does not work correctly with a HashWithIndifferentAccess
#	convert to hash, but MUST use string keys, not symbols as
#		real request do not send symbols

#	TODO	#66
#
#	If a consent date has been supplied, 
#		set consented equal to true, yes, 1 or whatever is right for the data type.
#
#	If no consent date has been supplied, 
#		leave the consented field null too. 
#
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
