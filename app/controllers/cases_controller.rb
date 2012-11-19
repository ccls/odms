#class CasesController < ApplicationController
class CasesController < RafController

	before_filter :may_create_study_subjects_required,
		:only => [:new,:create,:show,:index]
#		:only => [:new,:create]
#	before_filter :may_read_study_subjects_required,
#		:only => [:show,:index]
	before_filter :may_update_study_subjects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_study_subjects_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:edit,:update,:show,:destroy]
	before_filter :case_study_subject_required,
		:only => [:edit,:update,:show,:destroy]

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
		@hospitals = Hospital.active.includes(:organization)
			.order('organizations.name ASC')


		@study_subject = StudySubject.new



	end

#	def create
#		#	use find by id rather than just find so that 
#		#	it returns nil rather than raise an error if not found
#		if params[:hospital_id] and
#			( hospital = Hospital.where( :id => params[:hospital_id] ).first )
#
#			new_params = { :study_subject => {
#				:patient_attributes => {
#					:organization_id => hospital.organization_id
#			} } }
#			if hospital.has_irb_waiver
#				redirect_to new_waivered_path(new_params)
#			else
#				redirect_to new_nonwaivered_path(new_params)
#			end
#		else
#			flash[:error] = 'Please select an organization'
#			redirect_to new_case_path
#		end
#	end

#
#	If the RAF/Waivered/Nonwaivered thing goes away,
#	move all of the RafController code into this controller.
#

	def create
#		@study_subject = StudySubject.new(params[:study_subject])
#		@study_subject.save!

		@hospitals = Hospital.active.includes(:organization)
			.order('organizations.name ASC')
		study_subject_params = params[:study_subject].dup.to_hash
		common_raf_create(study_subject_params)

#		flash[:notice] = 'Success!'
#		redirect_to case_path(@study_subject)
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		@hospitals = Hospital.active.includes(:organization)
#			.order('organizations.name ASC')
#		flash.now[:error] = "There was a problem creating the study_subject"
#		render :action => "new"
	end

	def edit
		@hospitals  = [@study_subject.organization.try(:hospital)].compact
		@hospitals += Hospital.active.includes(:organization)
			.order('organizations.name ASC')
		render :layout => 'subject'
	end
#
#	move the hospital logic into view one merge complete
#
	def update
		#	set defaults for addresses WITHOUT EXISTING IDs
		params[:study_subject]['addressings_attributes'].each_pair do |k,v|
			unless params[:study_subject]['addressings_attributes'][k].has_key?('id')
				params[:study_subject]['addressings_attributes'][k] = 
					#	must use deep_merge as contains address_attributes
					default_raf_addressing_attributes.deep_merge(
						params[:study_subject]['addressings_attributes'][k])
				allow_blank_address_line_1_for(
					params[:study_subject]['addressings_attributes'][k]['address_attributes'])
			end
		end

		#	set defaults for phone numbers WITHOUT EXISTING IDs
		params[:study_subject]['phone_numbers_attributes'].each_pair do |k,v|
			unless params[:study_subject]['phone_numbers_attributes'][k].has_key?('id')
				params[:study_subject]['phone_numbers_attributes'][k] = 
					default_raf_phone_number_attributes.merge(
						params[:study_subject]['phone_numbers_attributes'][k])
			end
		end

		@study_subject.update_attributes!(params[:study_subject])

		flash[:notice] = "Subject successfully updated, I think. ;)"
		redirect_to case_path(@study_subject)
	rescue
		@hospitals  = [@study_subject.organization.try(:hospital)].compact
		@hospitals += Hospital.active.includes(:organization)
			.order('organizations.name ASC')
		flash.now[:error] = "There was a problem updating the study_subject"
		render :action => 'edit', :layout => 'subject'
	end

	def show
		render :layout => 'subject'
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", root_path)
		end
	end

	def case_study_subject_required
		unless @study_subject.is_case?
			access_denied("Valid case study_subject required!", @study_subject)
		end
	end

end
