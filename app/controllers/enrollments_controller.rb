class EnrollmentsController < ApplicationController

#	permissive
#
#	before_filter :valid_hx_subject_id_required,
#		:only => [:new,:create,:index]
#	before_filter :valid_id_required,
#		:only => [:show,:edit,:update]
#
#	def new
#		@projects = Project.unenrolled_projects(@subject)
#		@enrollment = @subject.enrollments.build
#	end
#
#	def create
#		@enrollment = @subject.enrollments.build(params[:enrollment])
#		@enrollment.save!
#		redirect_to edit_enrollment_path(@enrollment)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		@projects = Project.unenrolled_projects(@subject)
#		flash.now[:error] = "Enrollment creation failed"
#		render :action => 'new'
#	end
#
#	def update
#		@enrollment.update_attributes!(params[:enrollment])
##		redirect_to subject_enrollments_path(@enrollment.subject)
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
#				subjects_path)
#		end
#	end

end
