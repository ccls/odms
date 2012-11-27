class CasesController < ApplicationController
#class CasesController < RafController

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
		params[:study_subject] ||= HashWithIndifferentAccess.new
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
		end if params[:study_subject].has_key?('addressings_attributes')

		#	set defaults for phone numbers WITHOUT EXISTING IDs
		params[:study_subject]['phone_numbers_attributes'].each_pair do |k,v|
			unless params[:study_subject]['phone_numbers_attributes'][k].has_key?('id')
				params[:study_subject]['phone_numbers_attributes'][k] = 
					default_raf_phone_number_attributes.merge(
						params[:study_subject]['phone_numbers_attributes'][k])
			end
		end if params[:study_subject].has_key?('phone_numbers_attributes')

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

#end
#class RafController < ApplicationController
#
#	before_filter :may_create_study_subjects_required

#
#	Created this non-directly-used controller simply to share the 
#	following with Waivered and Nonwaivered Controllers
#

	class Under15InconsistencyFound < StandardError; end

#protected




	def common_raf_update(incoming_params)
#
#	Now, on this new RAF update, some things may be created as they were
#	not yet known at the time of creation.  Phone numbers and addresses are
#	the most likely.  Should set the defaults for them ONLY IF THEY DON'T HAVE IDs ALREADY.
#
#	The CCLS enrollment should be created on or after subject create
#	so setting project_id on update is unnecessary.
#
	end





	def common_raf_create(incoming_params)
		#
		#	Add defaults that are not on the forms.
		#	This is ugly, but they are required, so either here or 
		#	hidden in the view.  If put in view, then need to be explicitly
		#	set in tests as well.
		#	deep_merge does not work correctly with a HashWithIndifferentAccess
		#	convert to hash, but MUST use string keys, not symbols as
		#		real requests do not send symbols
		#
		study_subject_params = incoming_params.deep_merge({
			'enrollments_attributes' => { '0' => { "project_id"=> Project['ccls'].id } },
			'addressings_attributes' => { '0' => default_raf_addressing_attributes },
			'phone_numbers_attributes' => {
				'0' => default_raf_phone_number_attributes,
#				'0' => default_raf_phone_number_attributes.merge(
#					'is_primary' => true ),
				'1' => default_raf_phone_number_attributes
			}
		})

		allow_blank_address_line_1(study_subject_params)
		mark_as_eligible(study_subject_params)
		@study_subject = StudySubject.new(study_subject_params)

		warn = []

		check_was_under_15(@study_subject)

		#	protected attributes
		@study_subject.subject_type_id   = SubjectType['Case'].id	
		@study_subject.case_control_type = 'C'

		#	explicitly validate before searching for duplicates
		raise ActiveRecord::RecordInvalid.new(@study_subject) unless @study_subject.valid?

		#	regular create submit	#	tests DO NOT SEND params[:commit] = 'Submit'
#		if params[:commit].blank? or params[:commit] == 'Submit'
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

		#	params[:commit].blank? or params[:commit] == 'Submit' 
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
#	rescue StudySubject::InconsistencyFound
	rescue Under15InconsistencyFound
		flash.now[:error] = "Under 15 Inconsistency Found."
		flash.now[:warn]  = "Under 15 selection does not match computed value."
		render :action => 'new'
	end

	def default_raf_phone_number_attributes
		{ 'current_user'   => current_user,
			'current_phone'  => YNDK[:yes],
			'is_valid'       => YNDK[:yes],
			'is_verified'    => true,
			'how_verified'   => 'provided on RAF',
			'data_source_id' => DataSource['raf'].id,
			'phone_type_id'  => PhoneType['home'].id }
	end

	def default_raf_addressing_attributes
		{	'current_user'    => current_user,
			'address_at_diagnosis' => YNDK[:yes],
			'current_address' => YNDK[:yes],
			'is_verified'     => true,
			'how_verified'    => 'provided on RAF',
			'is_valid'        => YNDK[:yes],
			'data_source_id'  => DataSource['raf'].id,
			'address_attributes' => { 
				'address_type_id'  => AddressType['residence'].id
		} }
	end

	#	CAUTION: params come from forms as strings
	def mark_as_eligible(default={})
		is_eligible = YNDK[:yes]
		ineligible_reasons = []

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
				default['subject_languages_attributes']['0']['language_id'].to_s.blank? and
				default['subject_languages_attributes']['1'].is_a?(Hash) and
				default['subject_languages_attributes']['1']['language_id'].to_s.blank? )
			is_eligible = YNDK[:no]
			ineligible_reasons << "Language does not include English or Spanish."
		end

		default['enrollments_attributes']['0']['is_eligible'] = is_eligible
		if( is_eligible == YNDK[:no] )
			default['enrollments_attributes']['0'][
				'ineligible_reason_id'] = IneligibleReason['other'].id
			default['enrollments_attributes']['0'][
				'other_ineligible_reason'] = ineligible_reasons.join("\n")
		end
	end

	def allow_blank_address_line_1(default={})
		#	as 'default' is a hash, 'address' is now just a pointer to part of it.
		address = default['addressings_attributes']['0']['address_attributes']
		allow_blank_address_line_1_for(address)
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
#				@warn << "Under 15 selection does not match computed value."
#				raise StudySubject::InconsistencyFound
				raise Under15InconsistencyFound
			end
		end
	end

end
