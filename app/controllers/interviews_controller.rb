class InterviewsController < ApplicationController

	permissive

	before_filter :valid_hx_subject_id_required,
		:only => [:new,:create,:index]
	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

#		def new
#			@interview = @subject.identifier.interviews.new
#		end
#	
#		def create
#			@interview = @subject.identifier.interviews.new(params[:interview])
#			@interview.save!
#			redirect_to interview_path(@interview)
#		rescue ActiveRecord::RecordInvalid
#			flash.now[:error] = "Interview creation failed."
#			render :action => 'new'
#		end

	def update
		@interview.update_attributes!(params[:interview])
		redirect_to interview_path(@interview)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Interview update failed."
		render :action => 'edit'
	end

#	def index
#		@interviews = @subject.identifier.interviews
#	end

	def destroy
		@interview.destroy
		redirect_to subjects_path
	end

protected

	def valid_id_required
		if !params[:id].blank? and Interview.exists?(params[:id])
			@interview = Interview.find(params[:id])
			@subject = @interview.identifier.try(:subject)
		else
			access_denied("Valid interview id required!", 
				subjects_path)
		end
	end

end
