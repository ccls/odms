class RafsController < ApplicationController

	class Under15InconsistencyFound < StandardError; end

	before_filter :may_create_study_subjects_required,
		:only => [:new,:create,:show]
	before_filter :may_update_study_subjects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_study_subjects_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:edit,:update,:show,:destroy]
	before_filter :case_study_subject_required,
		:only => [:edit,:update,:show,:destroy]


	def new
		@study_subject = StudySubject.new
	end

	def create

		params[:study_subject][:addresses_attributes] ||= {}
		params[:study_subject][:addresses_attributes]['0'] ||= {}
		allow_blank_address_line_1_for(
			params[:study_subject][:addresses_attributes]['0'])

		mark_as_eligible(params[:study_subject])
		@study_subject = StudySubject.new(study_subject_params)

		warn = []

		check_was_under_15(@study_subject)

		#	protected attributes
		@study_subject.subject_type   = 'Case'
		@study_subject.case_control_type = 'C'

		#	explicitly validate before searching for duplicates
		raise ActiveRecord::RecordInvalid.new(@study_subject) unless @study_subject.valid?

		#	regular create submit	#	tests DO NOT SEND params[:commit] = 'Submit'
		if params[:commit].blank? or params[:commit] == 'New Case'
			@duplicates = @study_subject.duplicates
			raise StudySubject::DuplicatesFound unless @duplicates.empty?
		end

		if params[:commit] == 'Match Found'
			@duplicates = @study_subject.duplicates
			if params[:duplicate_id] and
					( duplicate = StudySubject.find_by_id(params[:duplicate_id]) ) and
					@duplicates.include?(duplicate)
				duplicate.raf_duplicate_creation_attempted(@study_subject)
				flash[:notice] = "Operational Event created marking this attempted entry."
				redirect_to duplicate
			else
				#
				#	Match Found, but no duplicate_id or subject with the id
				#
				warn << "No valid duplicate_id given"
				raise StudySubject::DuplicatesFound unless @duplicates.empty?
			end

		#	params[:commit].blank? or params[:commit] == 'New Case' 
		#		or params[:commit] == 'No Match'
		else 
			#	No duplicates found or if there were, not matches.
			#	Transactions are only for marking a rollback point.
			#	The raised error will still kick all the way out.
			StudySubject.transaction do
				@study_subject.save!
				@study_subject.assign_icf_master_id
				@study_subject.create_mother
			end

			if @study_subject.icf_master_id.blank?
				warn << "Case was not assigned an icf_master_id."
			end
			if @study_subject.mother.try(:icf_master_id).blank?
				warn << "Mother was not assigned an icf_master_id."
			end
			flash[:warn] = warn.join('<br/>') unless warn.empty?
			redirect_to @study_subject
			Notification.raf_submitted(@study_subject).deliver
		end
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject creation failed"
		render :action => 'new'
	rescue ActiveRecord::StatementInvalid => e
		flash.now[:error] = "Database error.  Check production logs and contact Jake."
		render :action => 'new'
	rescue StudySubject::DuplicatesFound
		flash.now[:error] = "Possible Duplicate(s) Found."
		flash.now[:warn] = warn.join('<br/>') unless warn.empty?
		render :action => 'new'
	rescue Under15InconsistencyFound
		flash.now[:error] = "Under 15 Inconsistency Found."
		flash.now[:warn]  = "Under 15 selection does not match computed value."
		render :action => 'new'
	end

	def edit
	end

	def update

		params[:study_subject] ||= {}
		params[:study_subject][:addresses_attributes] ||= {}
		params[:study_subject][:addresses_attributes]['0'] ||= {}
		allow_blank_address_line_1_for(
			params[:study_subject][:addresses_attributes]['0'])

		mark_as_eligible(params[:study_subject])
		@study_subject.assign_attributes(study_subject_params)
		check_was_under_15(@study_subject)
		@study_subject.save!
		flash[:notice] = "Subject successfully updated."
		redirect_to raf_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject updation failed"
		render :action => 'edit'
	rescue Under15InconsistencyFound
		flash.now[:error] = "Under 15 Inconsistency Found."
		flash.now[:warn]  = "Under 15 selection does not match computed value."
		render :action => 'edit'
	end

	def show
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

	#	CAUTION: params come from forms as strings
	#	In testing, don't have to pass the patient and language stuff
	#		so will kinda incorrectly be marked as eligible. (not in production though)
	#	or the enrollments stuff
	def mark_as_eligible(default={})
		is_eligible = YNDK[:yes]
		ineligible_reasons = []

		#	in reality, it will as it will be on the form
		#	in testing, it may not for the tests that don't care
		if default.has_key?('enrollments_attributes') and
			default['enrollments_attributes'].is_a?(Hash) and
			default['enrollments_attributes'].has_key?('0') and
			default['enrollments_attributes']['0'].is_a?(Hash)

			if( default['patient_attributes'].is_a?(Hash) and
				default['patient_attributes'][
					'was_under_15_at_dx'].to_s == YNDK[:no].to_s )
				is_eligible = YNDK[:no]
				ineligible_reasons << "Was not under 15 at diagnosis."
			end
			if( default['patient_attributes'].is_a?(Hash) and
				default['patient_attributes'][
					'was_previously_treated'].to_s == YNDK[:yes].to_s )
				is_eligible = YNDK[:no]
				ineligible_reasons << "Was previously treated."
			end
			if( default['patient_attributes'].is_a?(Hash) and
				default['patient_attributes'][
					'was_ca_resident_at_diagnosis'].to_s == YNDK[:no].to_s )
				is_eligible = YNDK[:no]
				ineligible_reasons << "Was not CA resident at diagnosis."
			end
			if( default['subject_languages_attributes'].is_a?(Hash) and
					default['subject_languages_attributes']['0'].is_a?(Hash) and
					default['subject_languages_attributes']['0']['language_code'].to_s.blank? and
					default['subject_languages_attributes']['1'].is_a?(Hash) and
					default['subject_languages_attributes']['1']['language_code'].to_s.blank? )
#
#	NOTE I don't like this.  Should collect all the language codes
#		and see if it actually includes English or Spanish rather than
#		assuming, even though it is programmed this way
#
				is_eligible = YNDK[:no]
				ineligible_reasons << "Language does not include English or Spanish."
			end
	
			default['enrollments_attributes']['0']['is_eligible'] = is_eligible
			if( is_eligible == YNDK[:no] )
				default['enrollments_attributes']['0'][
					'ineligible_reason_id'] = IneligibleReason['other'].id
				default['enrollments_attributes']['0'][
					'other_ineligible_reason'] = ineligible_reasons.join("\n")
			else	#	must blank these out if now eligible
				default['enrollments_attributes']['0'][
					'ineligible_reason_id'] = nil
				default['enrollments_attributes']['0'][
					'other_ineligible_reason'] = nil
			end
		end
	end

	def allow_blank_address_line_1_for(address)
		if address['line_1'].blank? and
				!address['city'].blank? and
				!address['state'].blank? and
				!address['zip'].blank?
			#	On validation failure, this will be visible on the re-rendered view.
			address['line_1'] = '[no address provided]'
		end
	end

	def check_was_under_15(study_subject)
		if( !study_subject.dob.blank? and
				!study_subject.patient.nil? and
				!study_subject.patient.was_under_15_at_dx.blank? and
				!study_subject.patient.admit_date.blank? )
			fifteenth_birthday = study_subject.dob.to_date + 15.years
			calc_was_under_15 = ( 
				study_subject.patient.admit_date.to_date < fifteenth_birthday ) ? 
					YNDK[:yes] : YNDK[:no]
			#	this will also be triggered if the dates are reverse (admit before dob)
			if calc_was_under_15 != study_subject.patient.was_under_15_at_dx
				raise Under15InconsistencyFound
			end
		end
	end

	def study_subject_params
		params.require( :study_subject ).permit(
			:first_name, :middle_name, :last_name, :dob, :sex,
			:mother_first_name, :mother_middle_name, :mother_last_name, :mother_maiden_name,
			:father_first_name, :father_middle_name, :father_last_name,
			:guardian_first_name, :guardian_middle_name, :guardian_last_name,
			:guardian_relationship, :other_guardian_relationship, {
			:phone_numbers_attributes => [
				:id,:phone_number,:phone_type,:data_source,:is_primary,:current_phone],
			:addresses_attributes => [
				:id,:line_1,:unit,:city,:state,:zip,:data_source,:county,
				:current_address,:address_at_diagnosis,:address_type],
			:enrollments_attributes => [
				:id,:project_id,:consented,:consented_on,:refused_by_family,
				:refused_by_physician,:other_refusal_reason,:refusal_reason_id,
				:is_eligible,:ineligible_reason_id,:other_ineligible_reason],
			:patient_attributes => [
				:id,:organization_id,:admitting_oncologist,:hospital_no,:admit_date,
				:diagnosis,:other_diagnosis,:raf_county,:raf_zip,:was_under_15_at_dx,
				:was_previously_treated,:was_ca_resident_at_diagnosis],
			:subject_languages_attributes => [ :id,:language_code,:other_language]
		} )
	end

end
