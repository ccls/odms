class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_study_subject_required, :only => :show

	def index
		unless params[:patid].blank?
			@study_subject = StudySubject.find_case_by_patid(params[:patid])
		end
	end

	def show
#		@control_subjects  = @study_subject.controls
		@matching_subjects = @study_subject.matching
#		@family_subjects   = @study_subject.family
		@rejected_controls = @study_subject.rejected_controls
	end

	def new
		@hospitals = Hospital.all
	end

	def create
		#	This is just too nested
		if params[:study_subject] and
			params[:study_subject][:patient_attributes] and
			params[:study_subject][:patient_attributes][:organization_id]

			#	I am hoping that the organization_id is unique
			hospital = Hospital.find_by_organization_id(
				params[:study_subject][:patient_attributes][:organization_id] )
			if hospital
				if hospital.has_irb_waiver
					redirect_to new_waivered_path(:study_subject => params[:study_subject])
				else
					redirect_to new_nonwaivered_path(:study_subject => params[:study_subject])
				end
			else
				flash[:error] = 'Please select a valid organization'
#	redirect or render??
				redirect_to new_case_path
			end
		else
			flash[:error] = 'Please select an organization'
#	redirect or render??
			redirect_to new_case_path
		end
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
