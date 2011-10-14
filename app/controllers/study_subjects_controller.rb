class StudySubjectsController < ApplicationController

	before_filter :may_create_study_subjects_required,
		:only => [:new,:create]
	before_filter :may_read_study_subjects_required, 
		:only => [:show,:index,:dashboard,:find,:followup,:reports]
	before_filter :may_update_study_subjects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_study_subjects_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def find
		record_or_recall_sort_order
		@study_subjects = StudySubject.search(params)
	end

	def index
		record_or_recall_sort_order
		if params[:commit] && params[:commit] == 'download'
			params[:paginate] = false
		end
		@study_subjects = StudySubject.search(params)
		if params[:commit] && params[:commit] == 'download'
			params[:format] = 'csv'
			headers["Content-disposition"] = "attachment; " <<
				"filename=study_subjects_#{Time.now.to_s(:filename)}.csv" 
		end
	end

	def show
	end

#	def new
#		@study_subject = StudySubject.new
#	end
#
#	def destroy
#		@study_subject.destroy
#		redirect_to study_subject_path
#	end
#
#	def create
#		@study_subject = StudySubject.new(params[:study_subject])
#		@study_subject.save!
#		flash[:notice] = 'Success!'
#		redirect_to @study_subject
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem creating the study_subject"
#		render :action => "new"
#	end 

	def update
		@study_subject.update_attributes!(params[:study_subject])
		flash[:notice] = 'Success!'
		redirect_to study_subject_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the study_subject"
		render :action => "edit"
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", study_subjects_path)
		end
	end

end
