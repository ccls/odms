class OrganizationsController < ApplicationController

	before_filter :may_create_organizations_required,
		:only => [:new,:create]
	before_filter :may_read_organizations_required,
		:only => [:show,:index]
	before_filter :may_update_organizations_required,
		:only => [:edit,:update]
	before_filter :may_destroy_organizations_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@organizations = Organization.all
	end

	def new
		@organization = Organization.new(params[:organization])
	end

	def create
		@organization = Organization.new(organization_params)
		@organization.save!
		flash[:notice] = 'Success!'
		redirect_to @organization
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the organization"
		render :action => "new"
	end 

	def update
		@organization.update_attributes!(organization_params)
		flash[:notice] = 'Success!'
		redirect_to organizations_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the organization"
		render :action => "edit"
	end

	def destroy
		@organization.destroy
		redirect_to organizations_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Organization.exists?(params[:id]) )
			@organization = Organization.find(params[:id])
		else
			access_denied("Valid id required!", organizations_path)
		end
	end

	def organization_params
		params.require(:organization).permit(:key,:name)
	end

end
