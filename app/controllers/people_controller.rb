class PeopleController < ApplicationController

#	resourceful

#	FYI. Now that I've explicitly added the code here, it may not be 100% covered by testing.

	before_filter :may_create_people_required,
		:only => [:new,:create]
	before_filter :may_read_people_required,
		:only => [:show,:index]
	before_filter :may_update_people_required,
		:only => [:edit,:update]
	before_filter :may_destroy_people_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@people = Person.all
	end

	def new
		@person = Person.new
	end

	def create
		@person = Person.new(params[:person])
		@person.save!
		flash[:notice] = 'Success!'
		redirect_to @person
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating " <<
			"the person"
		render :action => "new"
	end 

	def update
		@person.update_attributes!(params[:person])
		flash[:notice] = 'Success!'
		redirect_to people_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating " <<
			"the person"
		render :action => "edit"
	end

	def destroy
		@person.destroy
		redirect_to people_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Person.exists?(params[:id]) )
			@person = Person.find(params[:id])
		else
			access_denied("Valid id required!", people_path)
		end
	end

end
