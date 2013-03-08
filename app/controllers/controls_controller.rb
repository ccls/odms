class ControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_case_id_required, :only => :create
	before_filter :case_study_subject_required, :only => :create


	def index
		@study_subjects = StudySubject.controls
			.where( :phase => 5 )
			.order('reference_date DESC')
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
			format.html {}
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=newcontrols_#{Time.now.strftime('%m%d%Y')}.csv"
			}
		end
	end

	def new
		unless params[:q].blank?
			q = params[:q].squish
			@study_subject = if( q.length <= 4 )
				patid = sprintf("%04d",q.to_i)
				StudySubject.find_case_by_patid(patid)
			else
				StudySubject.find_case_by_icf_master_id(q)
			end
			flash.now[:error] = "No case study_subject found with given" <<
				":#{params[:q]}" unless @study_subject
		end

#	irb(main):061:0> StudySubject.cases.joins(:addresses).group('study_subjects.id').count('addresses.id').to_sql
#   (41.7ms)  SELECT COUNT(addresses.id) AS count_addresses_id, study_subjects.id AS study_subjects_id FROM `study_subjects` INNER JOIN `subject_types` ON `subject_types`.`id` = `study_subjects`.`subject_type_id` INNER JOIN `addressings` ON `addressings`.`study_subject_id` = `study_subjects`.`id` INNER JOIN `addresses` ON `addresses`.`id` = `addressings`.`address_id` WHERE `subject_types`.`key` = 'Case' GROUP BY study_subjects.id

		@study_subjects = StudySubject.cases
			.where( :phase => 5 )
			.joins(:enrollments)
			.joins("LEFT JOIN study_subjects AS controls ON study_subjects.patid = controls.patid AND controls.subject_type_id = #{SubjectType[:control].id}")
			.select('study_subjects.*, count(controls.id) as controls_count')
			.group('study_subjects.id')
			.merge(Enrollment.interview_completed.where(:project_id => Project['ccls'].id))
			.having('controls_count = 0')
	end

	def create
		candidate = CandidateControl.unassigned.unrejected.related_patid(
			@study_subject.patid ).limit(1).first	#	scopes always return arrays
		if candidate
			redirect_to edit_candidate_control_path(candidate)
		else
			flash[:error] = "Sorry, but no candidate controls were found matching this subject."
			redirect_to study_subject_related_subjects_path(@study_subject.id)
		end
	end

protected

	def valid_case_id_required
		if !params[:case_id].blank? and StudySubject.exists?(params[:case_id])
			@study_subject = StudySubject.find(params[:case_id])
		else
			access_denied("Valid study_subject case_id required!", new_control_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", new_control_path)
		end
	end

end
