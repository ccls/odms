class SamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]
	before_filter :may_read_samples_required,
		:only => [:show,:index,:dashboard,:find,:followup,:reports]
	before_filter :may_update_samples_required,
		:only => [:edit,:update]
	before_filter :may_destroy_samples_required,
		:only => :destroy

	before_filter :valid_study_subject_id_desired,
		:only => [:new]
	before_filter :valid_study_subject_id_required,
		:only => [:create,:index]
#		:except => [:dashboard,:find,:followup,:reports,:edit,:update,:show,:destroy]

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def index
		@samples = @study_subject.samples
		render :layout => 'subject'
	end

	def show
		render :layout => 'subject'
	end

	def new
		if @study_subject
			@sample = @study_subject.samples.new
			render :layout => 'subject'
		else
			if params[:studyid] or params[:icf_master_id]
				@study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
					params[:studyid]||nil, params[:icf_master_id]||nil )
			end
			render :action => "new_for_subject"
		end
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])
		@sample.save!
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample creation failed."
		render :action => 'new', :layout => 'subject'
	end

	def edit
		render :layout => 'subject'
	end

	def update
		@sample.update_attributes!(params[:sample])
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample update failed."
		render :action => 'edit', :layout => 'subject'
	end

	def destroy
		@sample.destroy
		redirect_to study_subject_path(@study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and Sample.exists?(params[:id])
			@sample = Sample.find(params[:id])
			@study_subject = @sample.study_subject
##	in dev on brg, above fails so being more explicit, the below works
#			@study_subject = StudySubject.find(@sample.study_subject_id)
		else
			access_denied("Valid sample id required!", study_subjects_path)
		end
	end

	def valid_study_subject_id_desired
		if !params[:study_subject_id].blank? 
			if StudySubject.exists?(params[:study_subject_id])
				@study_subject = StudySubject.find(params[:study_subject_id])
			else
				access_denied("Valid study_subject id required!", study_subjects_path)
			end
		end
	end

end
