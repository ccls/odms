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
#	TODO I thought that this should match on matchingid NOT patid?
#	No.  Matchingid would match the subjectid, NOT patid
		@controls = StudySubject.find(:all, :joins => :identifier, 
			:conditions => [
				"study_subjects.id != ? AND identifiers.patid = ?", @study_subject.id, @study_subject.patid ] 
		)
	end

	def new
	end

#	def create
#		case params[:commit]
#			when 'waivered'
#				redirect_to new_waivered_path
#			when 'nonwaivered'
#				redirect_to new_nonwaivered_path
#			else
#				flash[:error] = "Commit must be waivered or nonwaivered, not #{params[:commit]}"
#				redirect_to root_path
#		end
#	end

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
			access_denied("Valid case study_subject required!", cases_path)
		end
	end

end
