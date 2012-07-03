class SubjectTypesController < ApplicationController

	before_filter :may_create_subject_types_required,
		:only => [:new,:create]
	before_filter :may_read_subject_types_required,
		:only => [:show,:index]
	before_filter :may_update_subject_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_subject_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@subject_types = SubjectType.scoped
	end

	def new
		@subject_type = SubjectType.new(params[:subject_type])
	end

	def create
		@subject_type = SubjectType.new(params[:subject_type])
		@subject_type.save!
		flash[:notice] = 'Success!'
		redirect_to @subject_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the subject_type"
		render :action => "new"
	end 

	def update
		@subject_type.update_attributes!(params[:subject_type])
		flash[:notice] = 'Success!'
		redirect_to subject_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the subject_type"
		render :action => "edit"
	end

	def destroy
		@subject_type.destroy
		redirect_to subject_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SubjectType.exists?(params[:id]) )
			@subject_type = SubjectType.find(params[:id])
		else
			access_denied("Valid id required!", subject_types_path)
		end
	end

end
