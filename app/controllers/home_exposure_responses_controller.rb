class HomeExposureResponsesController < ApplicationController

	permissive

	before_filter :valid_subject_id_required
	before_filter :her_must_not_exist, :only => [:new,:create]
	before_filter :her_must_exist, :only => [:show,:destroy]
	before_filter :two_response_sets_required, :only => [:new,:create]
	before_filter :all_response_sets_completed_required, 
		:only => [:new,:create]
	before_filter :her_attributes_required, :only => :create

	def new
		@response_sets = @subject.response_sets
		@diffs = @subject.response_set_diffs
	end

	def create
		@her = @subject.create_home_exposure_response(
			params[:home_exposure_response] )
		if @her.new_record?
			flash.now[:error] = "There was a problem creating HER"
			new
			render :action => 'new'
		else
			redirect_to subject_home_exposure_response_path(@subject)
		end
	end

	def show
	end

	def destroy
		@home_exposure_response.destroy
		redirect_to subject_response_sets_path(@subject)
	end

protected

	def her_attributes_required
		if params[:home_exposure_response].nil? ||
			!params[:home_exposure_response].is_a?(Hash)
			access_denied("home exposure response attributes hash required")
		end
	end

	def her_must_exist
		if HomeExposureResponse.exists?(:study_subject_id => params[:subject_id] )
			@home_exposure_response = HomeExposureResponse.find(:first,
				:conditions => { :study_subject_id => @subject.id }
			)
		else
			access_denied("HER does not exist for this subject")
		end
	end

	def her_must_not_exist
		if HomeExposureResponse.exists?(:study_subject_id => params[:subject_id] )
			access_denied("HER already exists for this subject")
		end
	end

	def valid_subject_id_required
		if( Subject.exists?( params[:subject_id] ) )
			@subject = Subject.find( params[:subject_id] )
		else
			access_denied("Valid Subject ID required")
		end
	end

	def two_response_sets_required
		if @subject.response_sets.count > 2 ||
			@subject.response_sets.count < 2
			access_denied("Must complete 2 response sets before merging. " <<
				":#{@subject.response_sets.count}:" )
		end
	end

	def all_response_sets_completed_required
		unless @subject.response_sets.collect(&:is_complete?).all?
			access_denied("All response sets need to be completed")
		end
	end

end
