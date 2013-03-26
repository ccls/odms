class ContextsController < ApplicationController
#
#	before_filter :may_create_contexts_required,
#		:only => [:new,:create]
#	before_filter :may_read_contexts_required,
#		:only => [:show,:index]
#	before_filter :may_update_contexts_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_contexts_required,
#		:only => :destroy
#
#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy]
#
#	def index
#		@contexts = Context.scoped
#	end
#
#	def new
#		@context = Context.new(params[:context])
#	end
#
#	def create
#		@context = Context.new(params[:context])
#		@context.save!
#		flash[:notice] = 'Success!'
#		redirect_to @context
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem creating the context"
#		render :action => "new"
#	end 
#
#	def update
#		@context.update_attributes!(params[:context])
#		flash[:notice] = 'Success!'
#		redirect_to contexts_path
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the context"
#		render :action => "edit"
#	end
#
#	def destroy
#		@context.destroy
#		redirect_to contexts_path
#	end
#
#protected
#
#	def valid_id_required
#		if( !params[:id].blank? && Context.exists?(params[:id]) )
#			@context = Context.find(params[:id])
#		else
#			access_denied("Valid id required!", contexts_path)
#		end
#	end
#
end
