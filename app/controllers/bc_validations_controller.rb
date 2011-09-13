class BcValidationsController < ApplicationController
	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_study_subject_required, :only => :show

	def index
		@cases = StudySubject.search(params.merge(:types => 'case',:order => 'studyid'))	#,:paginate => false)
	end

	def show
#	TODO I thought that this should match on matchingid NOT patid?
#	No.  Matchingid would match the subjectid, NOT patid
#		@controls = StudySubject.find(:all, :joins => :identifier, 
#			:conditions => [
#				"study_subjects.id != ? AND identifiers.patid = ?", @study_subject.id, @study_subject.patid ] 
#		)
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
