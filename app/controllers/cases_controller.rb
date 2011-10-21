class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_study_subject_required, :only => :show

	def index
		unless params[:patid].blank?
			@study_subject = StudySubject.search(
				:patid => params[:patid], 
				:types => 'case'
			).first
		end
	end

	def show
		@control_subjects  = @study_subject.controls
		@matching_subjects = @study_subject.matching
		@family_subjects   = @study_subject.family
		@rejected_controls = @study_subject.rejected_controls
	end

	def new
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", cases_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", #	cases_path)
				study_subject_path(@study_subject) )
		end
	end

end
