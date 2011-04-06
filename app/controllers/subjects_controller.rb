class SubjectsController < ApplicationController

	resourceful :update_redirect => :update_redirect_path

	skip_before_filter :get_all

	def index
		record_or_recall_sort_order
		if params[:commit] && params[:commit] == 'download'
			params[:paginate] = false
		end
		@subjects = Subject.for_hx(params)
		if params[:commit] && params[:commit] == 'download'
			params[:format] = 'csv'
			headers["Content-disposition"] = "attachment; " <<
				"filename=subjects_#{Time.now.to_s(:filename)}.csv" 
		end
	end

	def show
#		@projects = Project.all
#		@enrollments = @subject.enrollments
		#	always return an enrollment so its not nil
		#	although it may be misleading
		#	Of course, if the subject isn't enrolled, 
		#	they wouldn't be here.
		@hx_enrollment = @subject.hx_enrollment || @subject.enrollments.new
	end

protected

	def update_redirect_path
		subject_path(@subject)
	end

end
