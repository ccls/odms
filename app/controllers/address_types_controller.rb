class AddressTypesController < ApplicationController

	before_filter :may_create_address_types_required,
		:only => [:new,:create]
	before_filter :may_read_address_types_required,
		:only => [:show,:index]
	before_filter :may_update_address_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_address_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@address_types = AddressType.all
	end

	def new
		@address_type = AddressType.new(params[:address_type])
	end

	def create
		@address_type = AddressType.new(params[:address_type])
		@address_type.save!
		flash[:notice] = 'Success!'
		redirect_to @address_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the address_type"
		render :action => "new"
	end 

	def update
		@address_type.update_attributes!(params[:address_type])
		flash[:notice] = 'Success!'
		redirect_to address_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the address_type"
		render :action => "edit"
	end

	def destroy
		@address_type.destroy
		redirect_to address_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && AddressType.exists?(params[:id]) )
			@address_type = AddressType.find(params[:id])
		else
			access_denied("Valid id required!", address_types_path)
		end
	end

end
