class SampleLocationsController < ApplicationController

	before_filter :may_create_sample_locations_required,
		:only => [:new,:create]
	before_filter :may_read_sample_locations_required,
		:only => [:show,:index]
	before_filter :may_update_sample_locations_required,
		:only => [:edit,:update]
	before_filter :may_destroy_sample_locations_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@sample_locations = SampleLocation.includes(:organization)
	end

	def new
		@sample_location = SampleLocation.new(params[:sample_location])
	end

	def create
		@sample_location = SampleLocation.new(sample_location_params)
		@sample_location.save!
		flash[:notice] = 'Success!'
		redirect_to @sample_location
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample_location"
		render :action => "new"
	end 

	def update
		@sample_location.update_attributes!(sample_location_params)
		flash[:notice] = 'Success!'
		redirect_to sample_locations_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the sample_location"
		render :action => "edit"
	end

	def destroy
		@sample_location.destroy
		redirect_to sample_locations_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SampleLocation.exists?(params[:id]) )
			@sample_location = SampleLocation.find(params[:id])
		else
			access_denied("Valid id required!", sample_locations_path)
		end
	end

	def sample_location_params
		params.require(:sample_location).permit(:is_active,:organization_id)
	end

end
__END__
