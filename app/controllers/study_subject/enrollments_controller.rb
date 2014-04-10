class StudySubject::EnrollmentsController < StudySubjectController

	before_filter :may_create_enrollments_required,
		:only => [:new,:create]
	before_filter :may_read_enrollments_required,
		:only => [:show,:index]
	before_filter :may_update_enrollments_required,
		:only => [:edit,:update]
	before_filter :may_destroy_enrollments_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def index
		render :action => 'index_mother' if @study_subject.is_mother?
	end

	def new
		@projects = @study_subject.unenrolled_projects
		@enrollment = @study_subject.enrollments.build
	end

	def create
		@enrollment = @study_subject.enrollments.build(params[:enrollment])
		@enrollment.save!
#	TODO what?  no flash of success?
		redirect_to edit_study_subject_enrollment_path(@study_subject,@enrollment)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		@projects = @study_subject.unenrolled_projects
		flash.now[:error] = "Enrollment creation failed"
		render :action => 'new'
	end

	def update
		@enrollment.update_attributes!(params[:enrollment])
#		redirect_to study_subject_enrollments_path(@enrollment.study_subject)
#	TODO what?  no flash of success?
		redirect_to study_subject_enrollment_path(@study_subject,@enrollment)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Enrollment update failed"
		render :action => 'edit'
	end

	def destroy
		@enrollment.destroy
		flash[:notice] = "Enrollment destroyed"
		redirect_to study_subject_enrollments_path(@study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and @study_subject.enrollments.exists?(params[:id])
			@enrollment = @study_subject.enrollments.find(params[:id])
		else
			access_denied("Valid enrollment id required!", study_subjects_path)
		end
	end

end
