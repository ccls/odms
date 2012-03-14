class IneligibleReasonsController < ApplicationController

	before_filter :may_create_ineligible_reasons_required,
		:only => [:new,:create]
	before_filter :may_read_ineligible_reasons_required,
		:only => [:show,:index]
	before_filter :may_update_ineligible_reasons_required,
		:only => [:edit,:update]
	before_filter :may_destroy_ineligible_reasons_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@ineligible_reasons = IneligibleReason.all
	end

	def new
		@ineligible_reason = IneligibleReason.new
	end

	def create
		@ineligible_reason = IneligibleReason.new(params[:ineligible_reason])
		@ineligible_reason.save!
		flash[:notice] = 'Success!'
		redirect_to @ineligible_reason
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating " <<
			"the ineligible_reason"
		render :action => "new"
	end 

	def update
		@ineligible_reason.update_attributes!(params[:ineligible_reason])
		flash[:notice] = 'Success!'
		redirect_to ineligible_reasons_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating " <<
			"the ineligible_reason"
		render :action => "edit"
	end

	def destroy
		@ineligible_reason.destroy
		redirect_to ineligible_reasons_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && IneligibleReason.exists?(params[:id]) )
			@ineligible_reason = IneligibleReason.find(params[:id])
		else
			access_denied("Valid id required!", ineligible_reasons_path)
		end
	end

end
