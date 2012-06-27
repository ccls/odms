class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required

	############################################################
	#
	#	The beginning of new control selection
	#
#	def index_original
#		unless params[:q].blank?
#			if ['patid','icf master id'].include?( params[:commit] )
#				@study_subject = if params[:commit] == 'patid'
##
##	as patids are 4 and icf master ids are 8, I could use the length 
##	of the given string to control which I search for rather
##	than the explicit button
##
#					q = params[:q]
#					patid = ( q.squish.length < 4 ) ? sprintf("%04d",q.to_i) : q.squish
#					StudySubject.find_case_by_patid(patid)
##					StudySubject.find_case_by_patid(sprintf("%04d",params[:q].to_i))
#				elsif params[:commit] == 'icf master id'
#					StudySubject.find_case_by_icf_master_id(params[:q])
#				end
#				flash.now[:error] = "No case study_subject found with given " <<
#					"#{params[:commit]||'query id'}:#{params[:q]}" unless @study_subject
#			else
#				flash.now[:error] = "Invalid and unexpected commit value:#{params[:commit]}:!"
#			end
##
##	As patid is ALWAYS 4 chars and icf master id SHOULD be 8 or 9
##	there SHOULD never be for than one if single search for on or other.
##	q = params[:q]
##	q = ( q.squish.length < 4 ) ? sprintf("%04d",q.to_i) : q.squish
##	@study_subject = StudySubject.cases.where(
##		"patid = :q or icf_master_id = :q", :q => q).limit(1).first
##
#		end
#	end

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
