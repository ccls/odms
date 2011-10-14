class NonwaiveredsController < ApplicationController

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
			study_subject_params = params[:study_subject].to_hash.deep_merge({
				'subject_type_id' => SubjectType['Case'].id,
				'identifier_attributes' => {
	#				'orderno' => 0,
					'case_control_type' => 'C'
				}
			})
			#	Paper form does not have consented checkbox, but our model
			#		requires it so add it if ...
			unless study_subject_params.dig("enrollments_attributes","0","consented_on").blank?
				study_subject_params["enrollments_attributes"]["0"]["consented"] = 1
			end
	
			#	Copy address' county and zip into patient raf_county and raf_zip [#8]
			study_subject_params["patient_attributes"]||={}
			study_subject_params["patient_attributes"]["raf_zip"] = 
				study_subject_params.dig("addressings_attributes","0",
					"address_attributes","zip")
	
			study_subject_params["patient_attributes"]["raf_county"] = 
				study_subject_params.dig("addressings_attributes","0",
					"address_attributes","county")
	
			@study_subject = StudySubject.new(study_subject_params)
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
