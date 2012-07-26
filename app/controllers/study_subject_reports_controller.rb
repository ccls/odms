class StudySubjectReportsController < ApplicationController

#	INSERT BEFORE FILTERS!

	before_filter :may_edit_required

	def control_assignment
		@study_subjects = StudySubject.controls
			.where( :phase => 5 )
			.order('created_at DESC')

		#
		#	The only reason to have this block is to change the name of the file.
		#	By default, it would just be manifest.csv everytime.
		#	If this is actually desired, remove the entire respond_to block.
		#
		#	If removed, one of the test assertions will fails as the 
		#	Content-Disposition will not be set.
		#
		respond_to do |format|
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=newcontrols_#{Time.now.strftime('%m%d%Y')}.csv"
			}
		end
	end

	def case_assignment
		@study_subjects = StudySubject.cases
			.where( :phase => 5 )
			.order('created_at DESC')
			.joins(:enrollments)
			.merge(Enrollment.eligible.consented.where(:project_id => Project['ccls'].id))
#http://railscasts.com/episodes/215-advanced-queries-in-rails-3?view=asciicast

		#
		#	The only reason to have this block is to change the name of the file.
		#	By default, it would just be manifest.csv everytime.
		#	If this is actually desired, remove the entire respond_to block.
		#
		#	If removed, one of the test assertions will fails as the 
		#	Content-Disposition will not be set.
		#
		respond_to do |format|
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=newcases_#{Time.now.strftime('%m%d%Y')}.csv"
			}
		end
	end

end
