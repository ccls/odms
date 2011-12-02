class ConsentsController < ApplicationController

	layout 'subject'

#	before_filter :may_create_consents_required,
#		:only => [:new,:create]
	before_filter :may_read_consents_required,
		:only => [:show,:index]
	before_filter :may_update_consents_required,
		:only => [:edit,:update]
#	before_filter :may_destroy_consents_required,
#		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:show,:edit,:update]
#		:only => [:new,:create,:index]

	def show
		if @study_subject.subject_type == SubjectType['Mother']
#			flash.now[:error] = "This is a mother subject. Eligibility data is only collected for child subjects. Please go to the record for the subject's child for details."
			render :action => 'show_mother'
		else
			@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
				Project['ccls'].id )
		end
	end

	def edit
		@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
			Project['ccls'].id )
		@patient = @study_subject.patient
	end

# {
#		"study_subject"=>{"subject_languages_attributes"=>{"0"=>{"language_id"=>""}, "1"=>{"language_id"=>"2"}, "2"=>{"language_id"=>"3", "other"=>""}}}, 
#	"commit"=>"Save", "authenticity_token"=>"hV63or8GyPH+1cUC9p85v811ghzTaVMnYB8V6fgzbzI=", 
#	"enrollment"=>{"contact_for_related_study"=>"", "other_refusal_reason"=>"", "ineligible_reason_specify"=>"", "share_smp_with_others"=>"", "ineligible_reason_id"=>"", "provide_saliva_smp"=>"", "use_smp_future_other_rsrch"=>"", "is_eligible"=>"", "use_smp_future_cancer_rsrch"=>"", "use_smp_future_rsrch"=>"", "consented_on"=>"", "consented"=>"", "document_version_id"=>"", "receive_study_findings"=>"", "refusal_reason_id"=>""}, 
#	"patient"=>{"was_previously_treated"=>"1", "was_under_15_at_dx"=>"2", "was_ca_resident_at_diagnosis"=>"999"}, 
#	"study_subject_id"=>"2"}

#	add unit test to see if I can just
#	study_subject.update_attribute!(:subject_language_attributes => { ... })

	def update
#	will need wrapped in a transaction from here ...
		@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
			Project['ccls'].id )
		@enrollment.update_attributes!(params[:enrollment])
#	TODO add patient update (currently debating proper values for those here)
#	TODO add languages update (just the languages, not the subject)
#	... to here.
		flash[:notice] = "Enrollment successfully updated."
		redirect_to study_subject_consent_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Enrollment update failed"
		render :action => 'edit'
	end

end
