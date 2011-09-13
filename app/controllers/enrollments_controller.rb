class EnrollmentsController < ApplicationController

#	permissive
#
#	before_filter :valid_hx_study_subject_id_required,
#		:only => [:new,:create,:index]
#	before_filter :valid_id_required,
#		:only => [:show,:edit,:update]
#
#	def new
#		@projects = Project.unenrolled_projects(@study_subject)
#		@enrollment = @study_subject.enrollments.build
#	end
#
#	def create
#		@enrollment = @study_subject.enrollments.build(params[:enrollment])
#		@enrollment.save!
#		redirect_to edit_enrollment_path(@enrollment)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		@projects = Project.unenrolled_projects(@study_subject)
#		flash.now[:error] = "Enrollment creation failed"
#		render :action => 'new'
#	end
#
#	def update
#		@enrollment.update_attributes!(params[:enrollment])
##		redirect_to study_subject_enrollments_path(@enrollment.study_subject)
#		redirect_to enrollment_path(@enrollment)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "Enrollment update failed"
#		render :action => 'edit'
#	end
#
#protected
#
#	def valid_id_required
#		if !params[:id].blank? and Enrollment.exists?(params[:id])
#			@enrollment = Enrollment.find(params[:id])
#		else
#			access_denied("Valid enrollment id required!", 
#				study_subjects_path)
#		end
#	end

end
