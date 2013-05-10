class UnitsController < ApplicationController
#
#	before_filter :may_create_units_required,
#		:only => [:new,:create]
#	before_filter :may_read_units_required,
#		:only => [:show,:index]
#	before_filter :may_update_units_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_units_required,
#		:only => :destroy
#
#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy]
#
#	def index
#		@units = Unit.scoped
#	end
#
#	def new
#		@unit = Unit.new(params[:unit])
#	end
#
#	def create
#		@unit = Unit.new(params[:unit])
#		@unit.save!
#		flash[:notice] = 'Success!'
#		redirect_to @unit
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem creating the unit"
#		render :action => "new"
#	end 
#
#	def update
#		@unit.update_attributes!(params[:unit])
#		flash[:notice] = 'Success!'
#		redirect_to units_path
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the unit"
#		render :action => "edit"
#	end
#
#	def destroy
#		@unit.destroy
#		redirect_to units_path
#	end
#
#protected
#
#	def valid_id_required
#		if( !params[:id].blank? && Unit.exists?(params[:id]) )
#			@unit = Unit.find(params[:id])
#		else
#			access_denied("Valid id required!", units_path)
#		end
#	end
#
end
