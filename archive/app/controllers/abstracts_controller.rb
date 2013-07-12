#	Just a RESTful abstract controller, without new or create
class AbstractsController < ApplicationController
#
#	#	for 'edit' and 'show'
#	layout 'subject'
#
#	before_filter :may_create_abstracts_required,
#		:only => [:new,:create]
	before_filter :may_read_abstracts_required,
		:only => [:show,:index]
#	before_filter :may_update_abstracts_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_abstracts_required,
#		:only => :destroy
#
##	Not Yet
##	before_filter :valid_study_subject_id_required
#
#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy]

	def index
		@abstracts = Abstract.scoped
		@abstracts = @abstracts.merged if params[:merged] == 'true'
#		render :layout => 'application'
	end

#	def update
#		@abstract.update_attributes!(params[:abstract])
#		flash[:notice] = 'Success!'
#		redirect_to study_subject_abstracts_path(@study_subject)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the abstract"
#		render :action => "edit"
#	end
#
#	def destroy
#		@abstract.destroy
#		redirect_to abstracts_path
#	end
#
#protected
#
#	def valid_id_required
##		if( !params[:id].blank? && @study_subject.abstracts.exists?(params[:id]) )
##			@abstract = @study_subject.abstracts.find(params[:id])
#		if( !params[:id].blank? && Abstract.exists?(params[:id]) )
#			@abstract = Abstract.find(params[:id])
#			#	for id bar
#			@study_subject = @abstract.study_subject
#		else
#			access_denied("Valid id required!", abstracts_path)
#		end
#	end

end
