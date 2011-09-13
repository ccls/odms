class BcValidationsController < ApplicationController
	before_filter :may_create_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_subject_required, :only => :show

	def index
		@cases = StudySubject.search(params.merge(:types => 'case',:order => 'studyid'))	#,:paginate => false)
	end

	def show
#	TODO I thought that this should match on matchingid NOT patid?
#	No.  Matchingid would match the subjectid, NOT patid
#		@controls = StudySubject.find(:all, :joins => :identifier, 
#			:conditions => [
#				"subjects.id != ? AND identifiers.patid = ?", @subject.id, @subject.patid ] 
#		)
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@subject = StudySubject.find(params[:id])
		else
			access_denied("Valid subject id required!", bc_validations_path)
		end
	end

	def case_subject_required
		unless @subject.is_case?
			access_denied("Valid case subject required!", bc_validations_path)
		end
	end

end
