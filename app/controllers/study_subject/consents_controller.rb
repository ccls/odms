class StudySubject::ConsentsController < StudySubjectController

	before_filter :may_create_consents_required,
		:only => [:new,:create]
	before_filter :may_read_consents_required,
		:only => [:show,:index]
	before_filter :may_update_consents_required,
		:only => [:edit,:update]
	before_filter :may_destroy_consents_required,
		:only => :destroy

	def show
		if @study_subject.is_mother?
			render :action => 'show_mother'
		else
			@enrollment = @study_subject.enrollments.find_or_create_by(project_id: Project['ccls'].id )
		end
	end

	def edit
		@enrollment = @study_subject.enrollments.find_or_create_by(project_id: Project['ccls'].id )
	end

# {
#		"study_subject"=>{"subject_languages_attributes"=>{"0"=>{"language_code"=>""}, "1"=>{"language_code"=>"2"}, "2"=>{"language_code"=>"3", "other_language"=>""}}}, 
#	"commit"=>"Save", "authenticity_token"=>"hV63or8GyPH+1cUC9p85v811ghzTaVMnYB8V6fgzbzI=", 
#	"enrollment"=>{"contact_for_related_study"=>"", "other_refusal_reason"=>"", "other_ineligible_reason"=>"", "share_smp_with_others"=>"", "ineligible_reason_id"=>"", "provide_saliva_smp"=>"", "use_smp_future_other_rsrch"=>"", "is_eligible"=>"", "use_smp_future_cancer_rsrch"=>"", "use_smp_future_rsrch"=>"", "consented_on"=>"", "consented"=>"", "document_version_id"=>"", "receive_study_findings"=>"", "refusal_reason_id"=>""}, 
#	"patient"=>{"was_previously_treated"=>"1", "was_under_15_at_dx"=>"2", "was_ca_resident_at_diagnosis"=>"999"}, 
#	"study_subject_id"=>"2"}

	def update
		#
		#	20150324 - Why isn't this just normal nested attributes style?
		#			Perhaps some security prior to strong params?
		#
		ActiveRecord::Base.transaction do
			@enrollment = @study_subject.enrollments.find_or_create_by(
				project_id: Project['ccls'].id )
			@enrollment.attributes = enrollment_params
			@study_subject.subject_languages_attributes = params.dig('study_subject','subject_languages_attributes')||{}
#	TODO what if case subject has no patient model??  Should never happen.
#	TODO what if isn't case subject?  Should also never happen.
			if @study_subject.is_case? and !@study_subject.patient.nil?
				@study_subject.patient.attributes = patient_params
			end
#raise ActiveRecord::RecordNotSaved.new(@enrollment)
			@enrollment.save!
			if @study_subject.is_case? and !@study_subject.patient.nil?
				@study_subject.patient.save!
			end
			@study_subject.save!
			#	TODO add patient update (currently debating proper values for those here)
		end
		flash[:notice] = "Enrollment successfully updated."
		redirect_to study_subject_consent_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Enrollment update failed"
		render :action => 'edit'
	end

	def enrollment_params
		params.require(:enrollment).permit( :vaccine_authorization_received_at,
			:is_eligible, :ineligible_reason_id, :other_ineligible_reason, :consented,
			:refusal_reason_id, :other_refusal_reason, :consented_on,
			:use_smp_future_rsrch, :use_smp_future_cancer_rsrch, :use_smp_future_other_rsrch,
			:share_smp_with_others, :contact_for_related_study,
			:provide_saliva_smp, :receive_study_findings)
	end

	def patient_params
		params.require(:patient).permit(
			:was_previously_treated, :was_ca_resident_at_diagnosis)
			#:admit_date, :hospital_no, :organization_id, :diagnosis,
	end

#	def subject_language_params
#		params.require(:study_subject).permit({:subject_languages_attributes => [:language_code,:other_language]})[:subject_languages_attributes]
#	end

end
