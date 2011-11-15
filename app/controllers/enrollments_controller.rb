class EnrollmentsController < ApplicationController

	before_filter :may_create_enrollments_required,
		:only => [:new,:create]
	before_filter :may_read_enrollments_required,
		:only => [:show,:index]
	before_filter :may_update_enrollments_required,
		:only => [:edit,:update]
	before_filter :may_destroy_enrollments_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:new,:create,:index]
	before_filter :valid_id_required,
		:only => [:show,:edit,:update]

	def index
		if @study_subject.subject_type == SubjectType['Mother']
			flash.now[:error] = "This is a mother subject. Enrollment data is only collected for child subjects. Please go to the record for the subject's child for details."
			render :action => 'index_mother'
		end
	end

	def new
		@projects = Project.unenrolled_projects(@study_subject)
		@enrollment = @study_subject.enrollments.build
	end

	def create
		@enrollment = @study_subject.enrollments.build(params[:enrollment])
		@enrollment.save!
#	TODO what?  no flash of success?
		redirect_to edit_enrollment_path(@enrollment)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		@projects = Project.unenrolled_projects(@study_subject)
		flash.now[:error] = "Enrollment creation failed"
		render :action => 'new'
	end

	def update
		@enrollment.update_attributes!(params[:enrollment])
#		redirect_to study_subject_enrollments_path(@enrollment.study_subject)
#	TODO what?  no flash of success?
		redirect_to enrollment_path(@enrollment)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Enrollment update failed"
		render :action => 'edit'
	end

protected

	def valid_id_required
		if !params[:id].blank? and Enrollment.exists?(params[:id])
			@enrollment = Enrollment.find(params[:id])
		else
			access_denied("Valid enrollment id required!", 
				study_subjects_path)
		end
	end

end
