class InstrumentsController < ApplicationController

	before_filter :may_create_instruments_required,
		:only => [:new,:create]
	before_filter :may_read_instruments_required,
		:only => [:show,:index]
	before_filter :may_update_instruments_required,
		:only => [:edit,:update]
	before_filter :may_destroy_instruments_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@instruments = Instrument.scoped
	end

	def new
		@instrument = Instrument.new(params[:instrument])
	end

	def create
		@instrument = Instrument.new(params[:instrument])
		@instrument.save!
		flash[:notice] = 'Success!'
		redirect_to @instrument
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the instrument"
		render :action => "new"
	end 

	def update
		@instrument.update_attributes!(params[:instrument])
		flash[:notice] = 'Success!'
		redirect_to instruments_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the instrument"
		render :action => "edit"
	end

	def destroy
		@instrument.destroy
		redirect_to instruments_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Instrument.exists?(params[:id]) )
			@instrument = Instrument.find(params[:id])
		else
			access_denied("Valid id required!", instruments_path)
		end
	end

end
