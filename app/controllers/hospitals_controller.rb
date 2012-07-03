class HospitalsController < ApplicationController

	before_filter :may_create_hospitals_required,
		:only => [:new,:create]
	before_filter :may_read_hospitals_required,
		:only => [:show,:index]
	before_filter :may_update_hospitals_required,
		:only => [:edit,:update]
	before_filter :may_destroy_hospitals_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@hospitals = Hospital.includes(:organization)
	end

	def new
		@hospital = Hospital.new(params[:hospital])
	end

	def create
		@hospital = Hospital.new(params[:hospital])
		@hospital.save!
		flash[:notice] = 'Success!'
		redirect_to @hospital
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the hospital"
		render :action => "new"
	end 

	def update
		@hospital.update_attributes!(params[:hospital])
		flash[:notice] = 'Success!'
		redirect_to hospitals_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the hospital"
		render :action => "edit"
	end

	def destroy
		@hospital.destroy
		redirect_to hospitals_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Hospital.exists?(params[:id]) )
			@hospital = Hospital.find(params[:id])
		else
			access_denied("Valid id required!", hospitals_path)
		end
	end

end
