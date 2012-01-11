class CasesController < ApplicationController

	layout 'subject'

	before_filter :may_create_study_subjects_required
#	before_filter :valid_id_required, :only => :show
#	before_filter :case_study_subject_required, :only => :show

	def index
		unless params[:patid].blank?
			@study_subject = StudySubject.find_case_by_patid(params[:patid])
		end
		render :layout => 'application'
	end

#	def show
#		if !@study_subject.is_case?
#			render :action => 'not_case' 
#		else
#			#@control_subjects  = @study_subject.controls
#			@matching_subjects = @study_subject.matching
#			#@family_subjects   = @study_subject.family
#			@rejected_controls = @study_subject.rejected_controls
#		end
#	end

	def new
		@hospitals = Hospital.all
		render :layout => 'application'
	end

	def create
		#	use find_by_id rather than just find so that 
		#	if returns nil rather than raise an error if not found
		if params[:hospital_id] and
			( hospital = Hospital.find_by_id( params[:hospital_id] ) )

			new_params = { :study_subject => {
				:patient_attributes => {
					:organization_id => hospital.organization_id
			} } }
			if hospital.has_irb_waiver
				redirect_to new_waivered_path(new_params)
			else
				redirect_to new_nonwaivered_path(new_params)
			end
		else
			flash[:error] = 'Please select an organization'
			redirect_to new_case_path
		end
	end

protected

#	def valid_id_required
#		if !params[:id].blank? and StudySubject.exists?(params[:id])
#			@study_subject = StudySubject.find(params[:id])
#		else
#			access_denied("Valid study_subject id required!", cases_path)
#		end
#	end

#	def case_study_subject_required
#		unless @study_subject.is_case?
#			access_denied("Valid case study_subject required!", #	cases_path)
#				study_subject_path(@study_subject) )
#		end
#	end

end
