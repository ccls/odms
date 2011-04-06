class SampleKitsController < ApplicationController

	permissive

	before_filter :valid_sample_id_required,
		:only => [ :index, :new, :create ]
	before_filter :valid_id_required, 
		:only => [ :show, :edit, :update, :destroy ]

	def show
		@last_shipping_update = Package.last_updated
	end

	def new
		@sample_kit = @sample.build_sample_kit
	end

	def create
		@sample_kit = @sample.build_sample_kit(params[:sample_kit])
		@sample_kit.save!
		flash[:notice] = 'Success!'
		redirect_to subject_path(@sample_kit.sample.subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample kit"
		render :action => "new"
	end

	def update
		@sample_kit.update_attributes!(params[:sample_kit])
		redirect_to subject_path(@sample_kit.sample.subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the sample kit"
		render :action => "edit"
	end

	def destroy
		@sample_kit.destroy
		redirect_to subject_path(@sample_kit.sample.subject)
	end

protected

	def valid_sample_id_required
		if !params[:sample_id].blank? and Sample.exists?(params[:sample_id])
			@sample = Sample.find(params[:sample_id])
		else
			access_denied("Valid sample id required!", 
				subjects_path)
		end
	end

	def valid_id_required
		if !params[:id].blank? and SampleKit.exists?(params[:id])
			@sample_kit = SampleKit.find(params[:id])
		else
			access_denied("Valid sample kit id required!", 
				subjects_path)
		end
	end

end
