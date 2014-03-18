class SubjectRelationshipsController < ApplicationController

	before_filter :may_create_subject_relationships_required,
		:only => [:new,:create]
	before_filter :may_read_subject_relationships_required,
		:only => [:show,:index]
	before_filter :may_update_subject_relationships_required,
		:only => [:edit,:update]
	before_filter :may_destroy_subject_relationships_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@subject_relationships = SubjectRelationship.all
	end

	def new
		@subject_relationship = SubjectRelationship.new(params[:subject_relationship])
	end

	def create
		@subject_relationship = SubjectRelationship.new(params[:subject_relationship])
		@subject_relationship.save!
		flash[:notice] = 'Success!'
		redirect_to @subject_relationship
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the subject_relationship"
		render :action => "new"
	end 

	def update
		@subject_relationship.update_attributes!(params[:subject_relationship])
		flash[:notice] = 'Success!'
		redirect_to subject_relationships_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the subject_relationship"
		render :action => "edit"
	end

	def destroy
		@subject_relationship.destroy
		redirect_to subject_relationships_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SubjectRelationship.exists?(params[:id]) )
			@subject_relationship = SubjectRelationship.find(params[:id])
		else
			access_denied("Valid id required!", subject_relationships_path)
		end
	end

end
