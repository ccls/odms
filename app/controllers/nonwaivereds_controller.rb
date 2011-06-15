class NonwaiveredsController < ApplicationController

	before_filter :may_create_subjects_required

	def new
		@subject = Subject.new
	end

	def create
		#	deep_merge does not work correctly with a HashWithIndifferentAccess
		#	convert to hash, but MUST use string keys, not symbols as
		#		real requests do not send symbols
#	hopefully, these options will be done from within the subject model
		subject_params = params[:subject].to_hash.deep_merge({
			'subject_type_id' => SubjectType['Case'].id,
			'identifier_attributes' => {
#				'orderno' => 0,
				'case_control_type' => 'C'
			}
		})
		#	Paper form does not have consented checkbox, but our model
		#		requires it so add it if ...
		unless subject_params.dig("enrollments_attributes","0","consented_on").blank?
			subject_params["enrollments_attributes"]["0"]["consented"] = 1
		end

		#	Copy address' county and zip into patient raf_county and raf_zip [#8]
		subject_params["patient_attributes"]||={}
		subject_params["patient_attributes"]["raf_zip"] = 
			subject_params.dig("addressings_attributes","0","address_attributes","zip")

		subject_params["patient_attributes"]["raf_county"] = 
			subject_params.dig("addressings_attributes","0","address_attributes","county")

		@subject = Subject.new(subject_params)
		@subject.save!
		redirect_to @subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Subject creation failed"
		render :action => 'new'
	end

end
