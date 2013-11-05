class SampleTemperaturesController < ApplicationController

	before_filter :may_create_sample_temperatures_required,
		:only => [:new,:create]
	before_filter :may_read_sample_temperatures_required,
		:only => [:show,:index]
	before_filter :may_update_sample_temperatures_required,
		:only => [:edit,:update]
	before_filter :may_destroy_sample_temperatures_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@sample_temperatures = SampleTemperature.scoped
	end

	def new
		@sample_temperature = SampleTemperature.new(params[:sample_temperature])
	end

	def create
		@sample_temperature = SampleTemperature.new(params[:sample_temperature])
		@sample_temperature.save!
		flash[:notice] = 'Success!'
		redirect_to @sample_temperature
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample_temperature"
		render :action => "new"
	end 

	def update
		@sample_temperature.update_attributes!(params[:sample_temperature])
		flash[:notice] = 'Success!'
		redirect_to sample_temperatures_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the sample_temperature"
		render :action => "edit"
	end

	def destroy
		@sample_temperature.destroy
		redirect_to sample_temperatures_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SampleTemperature.exists?(params[:id]) )
			@sample_temperature = SampleTemperature.find(params[:id])
		else
			access_denied("Valid id required!", sample_temperatures_path)
		end
	end

end
