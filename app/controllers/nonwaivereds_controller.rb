class NonwaiveredsController < ApplicationController

	before_filter :may_create_study_subjects_required

	def new
		@hospitals = Hospital.nonwaivered(:include => :organization)
		@study_subject = StudySubject.new(params[:study_subject])
	end

	def create
		@hospitals = Hospital.nonwaivered(:include => :organization)
		StudySubject.transaction do
			#
			#	Add defaults that are not on the forms.
			#	This is ugly, but they are required, so either here or 
			#	hidden in the view.  If put in view, then need to be explicitly
			#	set in tests as well.
			#	deep_merge does not work correctly with a HashWithIndifferentAccess
			#	convert to hash, but MUST use string keys, not symbols as
			#		real requests do not send symbols
			#
			study_subject_params = params[:study_subject].dup.to_hash.deep_merge({
				'subject_type_id' => SubjectType['Case'].id,
				'identifier_attributes' => {
					'case_control_type' => 'C'
				},
				'enrollments_attributes' => {
					'0' => { "project_id"=> Project['ccls'].id }
				},
				'addressings_attributes' => {
					'0' => { "current_address"=>"1",
						'address_attributes' => { 
							'address_type_id' => AddressType['residence'].id
						} 
					}
				},
				'phone_numbers_attributes' => {
					'0' => { 'phone_type_id' => PhoneType['home'].id },
					'1' => { 'phone_type_id' => PhoneType['home'].id }
				}
			})
			#	Paper form does not have consented checkbox, but our model
			#		requires it so add it if ...
			unless study_subject_params.dig("enrollments_attributes","0","consented_on").blank?
				study_subject_params["enrollments_attributes"]["0"]["consented"] = 1
			end
	
			#	Copy address' county and zip into patient raf_county and raf_zip [#8]
			# patient_attributes should never actually be blank except in testing.
			study_subject_params["patient_attributes"]||={}
			study_subject_params["patient_attributes"]["raf_zip"] = 
				study_subject_params.dig("addressings_attributes","0",
					"address_attributes","zip")
	
			study_subject_params["patient_attributes"]["raf_county"] = 
				study_subject_params.dig("addressings_attributes","0",
					"address_attributes","county")
	
			@study_subject = StudySubject.new(study_subject_params)

			#	explicitly validate before searching for duplicates
			raise ActiveRecord::RecordInvalid.new(@study_subject) unless @study_subject.valid?



			@duplicates = @study_subject.duplicates
#
#	TODO 	here is where I should check to see if the user has
#				done anything with the suggested duplicates.
#
			raise StudySubject::DuplicatesFound unless @duplicates.empty?



			@study_subject.save!
			@study_subject.assign_icf_master_id
			@study_subject.create_mother

			warn = []
			if @study_subject.identifier.icf_master_id.blank?
				warn << "Control was not assigned an icf_master_id."
			end
			if @study_subject.mother.identifier.icf_master_id.blank?
				warn << "Mother was not assigned an icf_master_id."
			end
			flash[:warn] = warn.join('<br/>') unless warn.empty?
		end
		redirect_to @study_subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject creation failed"
		render :action => 'new'
	rescue ActiveRecord::StatementInvalid => e
		flash.now[:error] = "Database error.  Check production logs and contact Jake."
		render :action => 'new'
	rescue StudySubject::DuplicatesFound
		flash.now[:error] = "Possible Duplicate(s) Found."
		render :action => 'new'
	end

end
