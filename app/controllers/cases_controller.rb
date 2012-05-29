class CasesController < ApplicationController

	layout 'subject'

	before_filter :may_create_study_subjects_required

	#
	#	I think that this is the beginning of selecting a new control
	#
	def index
		unless params[:patid].blank?
			@study_subject = StudySubject.find_case_by_patid(params[:patid])
		end
		render :layout => 'application'
	end

	############################################################
	#
	#	This is the beginning of a new RAF entry
	#
	def new
		@hospitals = Hospital.active(:include => :organization)
		render :layout => 'application'
	end

	def create
		#	use find_by_id rather than just find so that 
		#	it returns nil rather than raise an error if not found
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

end
