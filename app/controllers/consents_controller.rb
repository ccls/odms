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
			flash.now[:error] = "This is a mother subject. Eligibility data is only collected for child subjects. Please go to the record for the subject's child for details."
			render :action => 'show_mother'
		else
			@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
				Project['ccls'].id )
		end
	end

	def edit
		@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
			Project['ccls'].id )
	end

	def update
		@enrollment = @study_subject.enrollments.find_or_create_by_project_id(
			Project['ccls'].id )
		@enrollment.update_attributes!(params[:enrollment])
		flash[:notice] = "Enrollment successfully updated."
		redirect_to study_subject_consent_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Enrollment update failed"
		render :action => 'edit'
	end

end
