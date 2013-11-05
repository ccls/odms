class DiagnosesController < ApplicationController

	before_filter :may_create_diagnoses_required,
		:only => [:new,:create]
	before_filter :may_read_diagnoses_required,
		:only => [:show,:index]
	before_filter :may_update_diagnoses_required,
		:only => [:edit,:update]
	before_filter :may_destroy_diagnoses_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@diagnoses = Diagnosis.scoped
	end

	def new
		@diagnosis = Diagnosis.new(params[:diagnosis])
	end

	def create
		@diagnosis = Diagnosis.new(params[:diagnosis])
		@diagnosis.save!
		flash[:notice] = 'Success!'
		redirect_to @diagnosis
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the diagnosis"
		render :action => "new"
	end 

	def update
		@diagnosis.update_attributes!(params[:diagnosis])
		flash[:notice] = 'Success!'
		redirect_to diagnoses_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the diagnosis"
		render :action => "edit"
	end

	def destroy
		@diagnosis.destroy
		redirect_to diagnoses_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Diagnosis.exists?(params[:id]) )
			@diagnosis = Diagnosis.find(params[:id])
		else
			access_denied("Valid id required!", diagnoses_path)
		end
	end

end
