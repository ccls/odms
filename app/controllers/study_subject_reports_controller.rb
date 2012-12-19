class StudySubjectReportsController < ApplicationController

	before_filter :may_edit_required

	def control_assignment
		@study_subjects = StudySubject.controls
			.where( :phase => 5 )
			.order('created_at DESC')
			.joins(:enrollments)
			.merge(Enrollment.not_assigned_for_interview.where(:project_id => Project['ccls'].id))

#	SELECT `study_subjects`.* FROM `study_subjects` INNER JOIN `subject_types` ON `subject_types`.`id` = `study_subjects`.`subject_type_id` INNER JOIN `enrollments` ON `enrollments`.`study_subject_id` = `study_subjects`.`id` WHERE `subject_types`.`key` = 'Control' AND `study_subjects`.`phase` = 5 AND `enrollments`.`assigned_for_interview_at` IS NULL AND `enrollments`.`project_id` = 10 ORDER BY created_at DESC

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

end
