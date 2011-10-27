class BcValidationsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_study_subject_required, :only => :show

	def index
#	TODO stop using StudySubject.search
#	I really don't think that this ever really searches so this is OVERKILL
#	This is really just a paginates, case study subject list ordered by studyid.
#		Search options aren't ever passed.
#		@cases = StudySubject.search(params.merge(:types => 'case',:order => 'studyid'))
		@cases = StudySubject.paginate(
			:include => [:pii,:identifier],
			:order => 'identifiers.patid',
			:joins => [
				'LEFT JOIN identifiers ON study_subjects.id = identifiers.study_subject_id'
			],
			:conditions => ['study_subjects.subject_type_id = ?',
				SubjectType['Case'].id],
			:per_page => params[:per_page]||25,
			:page     => params[:page]||1
		)
	end

	def show
		@controls = CandidateControl.all(
			:conditions => { :related_patid => @study_subject.patid }
		)
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", bc_validations_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", bc_validations_path)
		end
	end

end
