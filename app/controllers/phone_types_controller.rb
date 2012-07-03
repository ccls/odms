class PhoneTypesController < ApplicationController

	before_filter :may_create_phone_types_required,
		:only => [:new,:create]
	before_filter :may_read_phone_types_required,
		:only => [:show,:index]
	before_filter :may_update_phone_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_phone_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@phone_types = PhoneType.scoped
	end

	def new
		@phone_type = PhoneType.new(params[:phone_type])
	end

	def create
		@phone_type = PhoneType.new(params[:phone_type])
		@phone_type.save!
		flash[:notice] = 'Success!'
		redirect_to @phone_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the phone_type"
		render :action => "new"
	end 

	def update
		@phone_type.update_attributes!(params[:phone_type])
		flash[:notice] = 'Success!'
		redirect_to phone_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the phone_type"
		render :action => "edit"
	end

	def destroy
		@phone_type.destroy
		redirect_to phone_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && PhoneType.exists?(params[:id]) )
			@phone_type = PhoneType.find(params[:id])
		else
			access_denied("Valid id required!", phone_types_path)
		end
	end

end
