class WaiveredsController < ApplicationController

	before_filter :may_create_subjects_required

	def new
		@subject = Subject.new
	end

	def create
		@subject = Subject.new(params[:subject])
		@subject.save!
		redirect_to @subject
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Subject creation failed"
		render :action => 'new'
	end

end
