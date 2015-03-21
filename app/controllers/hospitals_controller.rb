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
		@hospital = Hospital.new(params[:hospital])	#	don't "REQUIRE" here
	end

	def create
		@hospital = Hospital.new(hospital_params)
		@hospital.save!
		flash[:notice] = 'Success!'
		redirect_to @hospital
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the hospital"
		render :action => "new"
	end 

	def update
		@hospital.update_attributes!(hospital_params)
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

	def hospital_params
		params.require(:hospital).permit(:is_active,:has_irb_waiver,:organization_id)
	end

end
