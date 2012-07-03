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
		@sample_location = SampleLocation.new(params[:sample_location])
		@sample_location.save!
		flash[:notice] = 'Success!'
		redirect_to @sample_location
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample_location"
		render :action => "new"
	end 

	def update
		@sample_location.update_attributes!(params[:sample_location])
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

end
__END__
  # GET /sample_locations
  # GET /sample_locations.json
  def index
    @sample_locations = SampleLocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sample_locations }
    end
  end

  # GET /sample_locations/1
  # GET /sample_locations/1.json
  def show
    @sample_location = SampleLocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sample_location }
    end
  end

  # GET /sample_locations/new
  # GET /sample_locations/new.json
  def new
    @sample_location = SampleLocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sample_location }
    end
  end

  # GET /sample_locations/1/edit
  def edit
    @sample_location = SampleLocation.find(params[:id])
  end

  # POST /sample_locations
  # POST /sample_locations.json
  def create
    @sample_location = SampleLocation.new(params[:sample_location])

    respond_to do |format|
      if @sample_location.save
        format.html { redirect_to @sample_location, notice: 'Sample location was successfully created.' }
        format.json { render json: @sample_location, status: :created, location: @sample_location }
      else
        format.html { render action: "new" }
        format.json { render json: @sample_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sample_locations/1
  # PUT /sample_locations/1.json
  def update
    @sample_location = SampleLocation.find(params[:id])

    respond_to do |format|
      if @sample_location.update_attributes(params[:sample_location])
        format.html { redirect_to @sample_location, notice: 'Sample location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sample_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sample_locations/1
  # DELETE /sample_locations/1.json
  def destroy
    @sample_location = SampleLocation.find(params[:id])
    @sample_location.destroy

    respond_to do |format|
      format.html { redirect_to sample_locations_url }
      format.json { head :no_content }
    end
  end
end
