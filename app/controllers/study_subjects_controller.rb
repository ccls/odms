class StudySubjectsController < ApplicationController

	resourceful :update_redirect => :update_redirect_path

	skip_before_filter :get_all

#	this is added in the "resourceful" method above
#	before_filter :valid_id_required, :only => :show

	before_filter :may_read_study_subjects_required, 
		:only => [:show,:index,:dashboard,:find,:followup,:reports]

#	before_filter :may_read_study_subject_required,  :only => :show

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

protected

	def update_redirect_path
		study_subject_path(@study_subject)
	end

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", study_subjects_path)
		end
	end

end
