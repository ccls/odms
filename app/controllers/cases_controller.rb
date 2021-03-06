class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required

	def index
		if !params[:ids].blank? and params[:ids].is_a?(Array) and !params[:ids].empty?
			@study_subjects = StudySubject.order('reference_date DESC')
				.where(:id => params[:ids])
		else
			@study_subjects = StudySubject.cases.living
				.where( :phase => 5 )
				.where('study_subjects.reference_date < ?', 30.days.ago.to_date)
				.where('study_subjects.reference_date > ?', Date.parse('1/1/2012'))
				.order('reference_date DESC')
				.joins(:enrollments)
				.merge(
					Enrollment.eligible.consented.not_assigned_for_interview
					.where(:project_id => Project['ccls'].id) )
			#http://railscasts.com/episodes/215-advanced-queries-in-rails-3?view=asciicast

			#	SELECT `study_subjects`.* FROM `study_subjects` 
			#	INNER JOIN `subject_types` 
			#		ON `subject_types`.`id` = `study_subjects`.`subject_type_id` 
			#	INNER JOIN `enrollments` 
			#		ON `enrollments`.`study_subject_id` = `study_subjects`.`id` 
			#	WHERE `subject_types`.`key` = 'Case' 
			#		AND `study_subjects`.`phase` = 5 
			#		AND `enrollments`.`is_eligible` = 1 
			#		AND `enrollments`.`consented` = 1 
			#		AND `enrollments`.`assigned_for_interview_at` IS NULL 
			#		AND `enrollments`.`project_id` = 10 
			#	ORDER BY created_at DESC
		end

		#
		#	The only reason to have this block is to change the name of the file.
		#	By default, it would just be manifest.csv everytime.
		#	If this is actually desired, remove the entire respond_to block.
		#
		#	If removed, one of the test assertions will fails as the 
		#	Content-Disposition will not be set.
		#
		respond_to do |format|
			format.html {}
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=newcases_#{Time.now.strftime('%m%d%Y')}.csv"
			}
		end
	end

	def assign_selected_for_interview
		if params[:commit].present? and params[:commit] == 'export'		#_to_csv'
			request.format = :csv
			index
			render :action => 'index'
		else
			if !params[:ids].blank? and params[:ids].is_a?(Array) and !params[:ids].empty?
				enrollments = Enrollment
					.where( :study_subject_id => params[:ids] )
					.where( :project_id => Project['ccls'].id )
					.update_all(:assigned_for_interview_at => DateTime.current)
				StudySubject.where(:id => params[:ids]).update_all(:needs_reindexed => true)
				flash[:notice] = "StudySubject id(s) #{params[:ids].join(',')} " <<
					"assigned for interview."
				@study_subjects = StudySubject.find(params[:ids])
				@and_then_download_csv = true
				render :action => 'index'
			else
				flash[:error] = "No ids given."
				redirect_to cases_path	#	(:ids => params[:ids])
			end
		end
	end

end
