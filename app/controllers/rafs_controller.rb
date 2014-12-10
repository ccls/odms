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
		#
		#	Add defaults that are not on the forms.
		#	This is ugly, but they are required, so either here or 
		#	hidden in the view.  If put in view, then need to be explicitly
		#	set in tests as well.
		#	deep_merge does not work correctly with a HashWithIndifferentAccess
		#	convert to hash, but MUST use string keys, not symbols as
		#		real requests do not send symbols
		#
#
#	hashes are passed as references and so are modified and don't need explicitly updated
#
		study_subject_params = params[:study_subject].to_hash.deep_merge({
			'enrollments_attributes' => { '0' => { "project_id"=> Project['ccls'].id } }
		})
		add_default_raf_address_attributes(study_subject_params)
		add_default_raf_phone_number_attributes(study_subject_params)

		mark_as_eligible(study_subject_params)
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
#			if @study_subject.mother.icf_master_id.blank?
#
#	If mother is nil, we've got other problems
#
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
		study_subject_params = ( params[:study_subject] || Hash.new ).to_hash
		add_default_raf_address_attributes(study_subject_params)
		add_default_raf_phone_number_attributes(study_subject_params)
		mark_as_eligible(study_subject_params)
		@study_subject.assign_attributes(study_subject_params)
		check_was_under_15(@study_subject)
		@study_subject.save!
		flash[:notice] = "Subject successfully updated."
		redirect_to raf_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "StudySubject updation failed"
		render :action => 'edit'
#	rescue ActiveRecord::StatementInvalid => e
#		UNLIKELY TO HAPPEN ON UPDATE
#		flash.now[:error] = "Database error.  Check production logs and contact Jake."
#		render :action => 'edit'
#	rescue StudySubject::DuplicatesFound
#		NOT CHECKED ON UPDATE
#		flash.now[:error] = "Possible Duplicate(s) Found."
#		flash.now[:warn] = warn.join('<br/>') unless warn.empty?
#		render :action => 'edit'
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

	def default_raf_phone_number_attributes
		{ 'current_phone' => YNDK[:yes],
			'data_source'   => 'RAF (CCLS Rapid Ascertainment Form)',
			'phone_type'    => 'Home' }
	end

	def add_default_raf_phone_number_attributes(study_subject_params)
		#	set defaults for phone numbers WITHOUT EXISTING IDs
		study_subject_params['phone_numbers_attributes'].each_pair do |k,v|
			unless study_subject_params['phone_numbers_attributes'][k].has_key?('id')
				study_subject_params['phone_numbers_attributes'][k] = 
					default_raf_phone_number_attributes.merge(
						study_subject_params['phone_numbers_attributes'][k])
			end
		end if study_subject_params.has_key?('phone_numbers_attributes')
	end

	def default_raf_address_attributes
		{ 'address_at_diagnosis' => YNDK[:yes],
			'current_address' => YNDK[:yes],
			'data_source'     => 'RAF (CCLS Rapid Ascertainment Form)',
			'address_type'    => 'Residence'
		}
	end

	def add_default_raf_address_attributes(study_subject_params)
		#	set defaults for addresses WITHOUT EXISTING IDs
		study_subject_params['addresses_attributes'].each_pair do |k,v|
			unless study_subject_params['addresses_attributes'][k].has_key?('id')
				study_subject_params['addresses_attributes'][k] = 
					#	must use deep_merge as contains address_attributes
					default_raf_address_attributes.deep_merge(
						study_subject_params['addresses_attributes'][k])
				allow_blank_address_line_1_for(
					study_subject_params['addresses_attributes'][k])
			end
		end if study_subject_params.has_key?('addresses_attributes')
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

end
