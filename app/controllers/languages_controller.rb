class LanguagesController < ApplicationController

	before_filter :may_create_languages_required,
		:only => [:new,:create]
	before_filter :may_read_languages_required,
		:only => [:show,:index]
	before_filter :may_update_languages_required,
		:only => [:edit,:update]
	before_filter :may_destroy_languages_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@languages = Language.all
	end

	def new
		@language = Language.new
	end

	def create
		@language = Language.new(params[:language])
		@language.save!
		flash[:notice] = 'Success!'
		redirect_to @language
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating " <<
			"the language"
		render :action => "new"
	end 

	def update
		@language.update_attributes!(params[:language])
		flash[:notice] = 'Success!'
		redirect_to languages_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating " <<
			"the language"
		render :action => "edit"
	end

	def destroy
		@language.destroy
		redirect_to languages_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Language.exists?(params[:id]) )
			@language = Language.find(params[:id])
		else
			access_denied("Valid id required!", languages_path)
		end
	end

end
