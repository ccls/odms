class FollowUpTypesController < ApplicationController
#
#	before_filter :may_create_follow_up_types_required,
#		:only => [:new,:create]
#	before_filter :may_read_follow_up_types_required,
#		:only => [:show,:index]
#	before_filter :may_update_follow_up_types_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_follow_up_types_required,
#		:only => :destroy
#
#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy]
#
#	def index
#		@follow_up_types = FollowUpType.scoped
#	end
#
#	def new
#		@follow_up_type = FollowUpType.new(params[:follow_up_type])
#	end
#
#	def create
#		@follow_up_type = FollowUpType.new(params[:follow_up_type])
#		@follow_up_type.save!
#		flash[:notice] = 'Success!'
#		redirect_to @follow_up_type
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem creating the follow_up_type"
#		render :action => "new"
#	end 
#
#	def update
#		@follow_up_type.update_attributes!(params[:follow_up_type])
#		flash[:notice] = 'Success!'
#		redirect_to follow_up_types_path
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the follow_up_type"
#		render :action => "edit"
#	end
#
#	def destroy
#		@follow_up_type.destroy
#		redirect_to follow_up_types_path
#	end
#
#protected
#
#	def valid_id_required
#		if( !params[:id].blank? && FollowUpType.exists?(params[:id]) )
#			@follow_up_type = FollowUpType.find(params[:id])
#		else
#			access_denied("Valid id required!", follow_up_types_path)
#		end
#	end
#
end
