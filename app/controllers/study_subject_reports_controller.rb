class StudySubjectReportsController < ApplicationController


#	INSERT BEFORE FILTERS!

	before_filter :may_administrate_required

	def control_assignment
		@controls = StudySubject.controls.order('created_at DESC').limit(5)

		#
		#	The only reason to have this block is to change the name of the file.
		#	By default, it would just be manifest.csv everytime.
		#	If this is actually desired, remove the entire respond_to block.
		#
#		respond_to do |format|
#			format.csv { 
#				headers["Content-Disposition"] = "attachment; " <<
#					"filename=control_assignment_#{Time.now.to_s(:filename)}.csv"
#			}
#		end
	end

end
