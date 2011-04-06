class Sample::SubjectsController < ApplicationController

	permissive

	before_filter :may_read_subjects_required, 
		:only => [:show,:index,:send_to_lab]

	before_filter :valid_id_for_hx_subject_required,
		:only => [:show]

	def index
		get_subjects
		if params[:commit] && params[:commit] == 'download'
			params[:format] = 'csv'
			headers["Content-disposition"] = "attachment; " <<
				"filename=subjects_#{Time.now.to_s(:filename)}.csv" 
			render :template => "subjects/index"
		end
	end

#	def send_to_lab
#		get_subjects
#	end

protected

	def get_subjects
		record_or_recall_sort_order
		if params[:commit] && params[:commit] == 'download'
			params[:paginate] = false
		end
		@subjects = Subject.for_hx_sample(params)
	end

end
