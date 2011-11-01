class ControlsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_case_id_required
	before_filter :case_study_subject_required

	def new
#
#	TODO New thing.  Find a random candidate control for the given case study subject,
#			then redirect to edit_candidate_control_path(candidate)
#			If no candidate is found, flash an error and return to case.
#		This would seem to be more restful and could use the update to update
#			the candidate control's rejected attributes.
#		After updating, redirect to the associated /cases/:id
#

		candidate = CandidateControl.find(:first,
			:order => 'RAND()',	#	mysql specific
			:conditions => [
				"related_patid = ? AND reject_candidate = false AND assigned_on IS NULL AND study_subject_id IS NULL",
				@study_subject.patid ]
		)
		if candidate
			redirect_to edit_candidate_control_path(candidate)
		else
			flash[:error] = "Sorry, but no candidate controls were found matching this subject."
			redirect_to case_path(@study_subject.id)
		end
	end

#	TODO won't need this after the above has been implemented
#	def create
##	temporary
#		redirect_to case_path(@study_subject)
#	end

#		def new
#			unless params[:patid].blank?
#	#	TODO search on subject_type == case or case_control_type == 'C' ?
#	#	This redundancy is becoming an issue.
#	#	Try to stop using StudySubject.search for simple one-off things
#		StudySubject.find_case_by_patid(params[:patid])
#				@study_subject = StudySubject.search(:patid => params[:patid], :types => 'case').first
#			end
#		end

#		def show
#	#	TODO I thought that this should match on matchingid NOT patid?
#	#	No.  Matchingid would match the subjectid, NOT patid
#			@controls = StudySubject.find(:all, :joins => :identifier, 
#				:conditions => [
#					"study_subjects.id != ? AND identifiers.patid = ?", @study_subject.id, @study_subject.patid ] 
#			)
#		end

protected

	def valid_case_id_required
		if !params[:case_id].blank? and StudySubject.exists?(params[:case_id])
			@study_subject = StudySubject.find(params[:case_id])
		else
			access_denied("Valid study_subject case_id required!", cases_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", cases_path)
		end
	end

end
