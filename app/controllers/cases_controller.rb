class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required

	############################################################
	#
	#	The beginning of new control selection
	#
	def index
		unless params[:q].blank?
			q = params[:q].squish
			@study_subject = if( q.length <= 4 )
				patid = sprintf("%04d",q.to_i)
				StudySubject.find_case_by_patid(patid)
			else
				StudySubject.find_case_by_icf_master_id(q)
			end
			flash.now[:error] = "No case study_subject found with given" <<
				":#{params[:q]}" unless @study_subject
		end
	end

	############################################################
	#
	#	This is the beginning of a new RAF entry
	#
	def new
		@hospitals = Hospital.active(:include => :organization)
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
