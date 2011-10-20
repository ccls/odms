class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_study_subject_required, :only => :show

	def index
		unless params[:patid].blank?
			@study_subject = StudySubject.search(:patid => params[:patid], :types => 'case').first
		end
	end

	def show
#
#	These should be methods in the model
#
		@control_subjects = StudySubject.find(:all, 
			:joins => :identifier, 
			:conditions => [
				"study_subjects.id != ? AND identifiers.patid = ?", 
				@study_subject.id, @study_subject.patid ] 
		)
		@matching_subjects = StudySubject.find(:all,
			:joins => :identifier,
			:conditions => [
				"study_subjects.id != ? AND identifiers.matchingid = ?", 
				@study_subject.id, @study_subject.identifier.matchingid ] 
		)
		@family_subjects = StudySubject.find(:all,
			:joins => :identifier,
			:conditions => [
				"study_subjects.id != ? AND identifiers.familyid = ?", 
				@study_subject.id, @study_subject.identifier.familyid ] 
		)
		@rejected_controls = CandidateControl.find(:all,
			:conditions => {
				:related_patid    => @study_subject.patid,
				:reject_candidate => true
			}
		)
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
