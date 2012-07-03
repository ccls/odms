class InstrumentTypesController < ApplicationController

	before_filter :may_create_instrument_types_required,
		:only => [:new,:create]
	before_filter :may_read_instrument_types_required,
		:only => [:show,:index]
	before_filter :may_update_instrument_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_instrument_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@instrument_types = InstrumentType.scoped
	end

	def new
		@instrument_type = InstrumentType.new(params[:instrument_type])
	end

	def create
		@instrument_type = InstrumentType.new(params[:instrument_type])
		@instrument_type.save!
		flash[:notice] = 'Success!'
		redirect_to @instrument_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the instrument_type"
		render :action => "new"
	end 

	def update
		@instrument_type.update_attributes!(params[:instrument_type])
		flash[:notice] = 'Success!'
		redirect_to instrument_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the instrument_type"
		render :action => "edit"
	end

	def destroy
		@instrument_type.destroy
		redirect_to instrument_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && InstrumentType.exists?(params[:id]) )
			@instrument_type = InstrumentType.find(params[:id])
		else
			access_denied("Valid id required!", instrument_types_path)
		end
	end

end
