#
#	The StudySubject is the heart of our little application.
#	It contains a ridiculous number of associations, validations,
#	delegations, etc.  I am trying to organize it all, but due
#	to the volume, this may be a bit challenging.  I am trying to
#	group code related to specific associations into their own
#	files in hopes of making it simpler to follow.  In addition,
#	there are matching test classes.
#
class StudySubject < ActiveRecord::Base

	class NotTwoAbstracts < StandardError; end
	class DuplicatesFound < StandardError; end

	has_many :abstracts
	has_many :addresses
	has_many :alternate_contacts
	has_one  :birth_datum
	has_many :bc_requests
	has_many :blood_spot_requests
	has_many :enrollments
	has_many :medical_record_requests
	has_many :operational_events
	has_one  :patient
	has_many :phone_numbers
	has_many :samples

	#	Be advised. The custom association keys cause the following ...
	#	race_ids will return an array of the foreign key, CODES in this case
	#	race_ids= will accept an array of the IDS, NOT CODES
	has_many :subject_races
	has_many :races, :through => :subject_races

	#	be advised. the custom association keys cause the following
	#	language_ids will return an array of the foreign key, CODES in this case
	#	language_ids= will accept an array of the IDS, NOT CODES
	has_many :subject_languages
	has_many :languages, :through => :subject_languages

	VALID_SUBJECT_TYPES = %w( Case Control Mother Father Twin )
	VALID_VITAL_STATUSES = ["Living", "Deceased", "Refused to State", "Don't Know"]
	VALID_GUARDIAN_RELATIONSHIPS = ["Subject's mother", "Subject's father", 
			"Subject's grandparent", 
			"Subject's foster parent", "Subject's twin", "Other relationship to Subject", 
			"Subject's sibling", "Subject's step parent", "Unknown relationship to subject"]

	attr_accessor :language_required

	accepts_nested_attributes_for :addresses,
		:reject_if => proc { |attrs|
			!attrs[:address_required] &&
			( attrs[:line_1].blank? &&
				attrs[:line_2].blank? &&
				attrs[:unit].blank? &&
				attrs[:city].blank? &&
				attrs[:zip].blank? &&
				attrs[:county].blank? ) }
	accepts_nested_attributes_for :enrollments
	accepts_nested_attributes_for :patient
	accepts_nested_attributes_for :phone_numbers,
		:reject_if => proc { |attrs| attrs[:phone_number].blank? }
	accepts_nested_attributes_for :subject_languages, 
		:allow_destroy => true,
		:reject_if => proc{|attributes| attributes['language_code'].blank? }
	accepts_nested_attributes_for :subject_races, 
		:allow_destroy => true,
		:reject_if => proc{|attributes| attributes['race_code'].blank? }

	delegate :admit_date, :hospital_no, :organization, :organization_id, 
		:diagnosis_date, :diagnosis, :other_diagnosis, 
		:hospital, :hospital_key, 
			:to => :patient, :allow_nil => true

	after_initialize :set_default_vital_status, :if => :new_record?
	after_initialize :set_default_phase, :if => :new_record?
	before_save :set_birth_year, :if => :dob_changed?

	before_validation :prepare_fields_for_validation
	before_create     :prepare_fields_for_creation

	# All subjects are to have a CCLS project enrollment, so create after create.
	after_create :add_ccls_enrollment

	after_create :add_new_subject_operational_event
	after_save   :add_subject_died_operational_event
	after_save :trigger_setting_was_under_15_at_dx,
		:if => :dob_changed?
	after_save :trigger_update_matching_study_subjects_reference_date, 
		:if => :matchingid_changed?

	def is_child?
		is_case_or_control?
	end

	def is_case_or_control?
		is_case? or is_control?
	end

	def is_case?
		subject_type == 'Case'
	end

	def is_control?
		subject_type == 'Control'
	end

	def is_mother?
		subject_type == 'Mother'
	end

	def is_father?
		subject_type == 'Father'
	end

	def is_twin?
		subject_type == 'Twin'
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the vital status.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def vital_statuses
		([self.vital_status] + VALID_VITAL_STATUSES ).compact.uniq
	end

	def is_living?
		vital_status == 'Living'
	end

	def is_deceased?
		vital_status == 'Deceased'
	end

	def admitting_oncologist
		self.patient.try(:admitting_oncologist).presence || "[no oncologist specified]"
	end

	##
	#	triggered from patient and self
	def update_patient_was_under_15_at_dx
		#	due to the high probability that self and patient will not
		#		yet be resolved, we have to get the associations manually.
		my_patient = Patient.find_by_study_subject_id(self.id)
		if dob && my_patient && my_patient.admit_date &&
				dob.to_date != Date.parse('1/1/1900') &&
				my_patient.admit_date.to_date != Date.parse('1/1/1900')

			fifteenth_birthday = dob.to_date + 15.years
			was_under_15 = ( my_patient.admit_date.to_date < fifteenth_birthday ) ? 
				YNDK[:yes] : YNDK[:no]

			my_patient.was_under_15_at_dx = was_under_15
			my_patient.save if my_patient.changed?
		end
	end

	##
	#	
	def update_study_subjects_reference_date_matching(*matchingids)
		logger.debug "DEBUG: In update_study_subjects_reference_date_matching(*matchingids)"
		logger.debug "DEBUG: update_study_subjects_reference_date_matching" <<
			"(#{matchingids.join(',')})"
		#	if matchingids ~ [nil,12345]
		#		identifier was either just created or matchingid added (compact as nil not needed)
		#	if matchingids ~ [12345,nil]
		#		matchingid was removed (compact as nil not needed) (should never happen)
		#	if matchingids ~ [12345,54321]
		#		matchingid was just changed (should never happen)

		#	if matchingids ~ []
		#		trigger came from Patient (admit date changed) so need to find matchingid
		matchingids.compact.push(matchingid).uniq.each do |mid|
			unless mid.blank?
				#	subjectid is unique, so can be only 1 unless nil
				matching_patient = StudySubject.with_subjectid(mid).first.try(:patient)
				unless matching_patient.nil?
					admit_date = matching_patient.try(:admit_date)

					StudySubject.with_matchingid(mid).each {|s| 
						s.reference_date = admit_date
						s.save if s.changed?
					}
				end
			end
		end
	end

	def set_birth_year
		self.birth_year = dob.try(:year).try(:to_s)
	end

	#
	#	Basically this is just a custom search expecting only the 
	#	following possible params for search / comparison ...
	#
	#		mother_maiden_name
	#		hospital_no
	#		dob
	#		sex
	#		admit_date
	#		organization_id
	#
	#		Would want to explicitly exclude self, but this check is
	#		to be done BEFORE subject creation so won't actually
	#		have an id to use to exclude itself anyway.
	#
	#		For adding controls, will need to be able to exclude case
	#		so adding :exclude_id option somehow
	#
	def self.duplicates(params={})
		conditions = [[],{}]

		if params.has_key?(:hospital_no) and !params[:hospital_no].blank?
			conditions[0] << '(hospital_no = :hospital_no)'
			conditions[1][:hospital_no] = params[:hospital_no]
		end

		#	This is effectively the only test for adding controls
		#	as the other attributes are from the patient model
		#	which is only for cases.
		if params.has_key?(:dob) and !params[:dob].blank? and
				params.has_key?(:sex) and !params[:sex].blank? and 
				params.has_key?(:mother_maiden_name)
#	since remove nullify of name fields, added comparison to ""
			conditions[0] << '(dob = :dob AND sex = :sex AND ( mother_maiden_name IS NULL OR mother_maiden_name = "" OR mother_maiden_name = :mother_maiden_name ))'
			conditions[1][:dob] = params[:dob]
			conditions[1][:sex] = params[:sex]
			#	added to_s as may be null so sql is valid and has '' rather than a blank
			conditions[1][:mother_maiden_name] = params[:mother_maiden_name].to_s	
		end
		if params.has_key?(:admit_date) and !params[:admit_date].blank? and
				params.has_key?(:organization_id) and !params[:organization_id].blank?
			conditions[0] << '(admit_date = :admit AND organization_id = :org)'
			conditions[1][:admit] = params[:admit_date]
			conditions[1][:org] = params[:organization_id]
		end

		unless conditions[0].blank?
			conditions_array = [ "(#{conditions[0].join(' OR ')})" ]
			if params.has_key?(:exclude_id)
				conditions_array[0] << " AND study_subjects.id != :exclude_id"
				conditions[1][:exclude_id] = params[:exclude_id]
			end
			conditions_array << conditions[1]
#puts conditions_array.inspect
#["((hospital_no = :hospital_no) OR (dob = :dob AND sex = :sex AND ( mother_maiden_name IS NULL OR mother_maiden_name = :mother_maiden_name )) OR (admit_date = :admit AND organization_id = :org)) AND study_subjects.id != :exclude_id", {:hospital_no=>"matchthis", :org=>31, :admit=>Wed, 16 Nov 2011, :sex=>"F", :exclude_id=>3, :mother_maiden_name=>"", :dob=>Wed, 16 Nov 2011}]

			#	have to do a LEFT JOIN, not the default INNER JOIN, here
			#			:joins => [:pii,:patient,:identifier]
			#	otherwise would only include subjects with pii, patient and identifier,
			#	which would effectively exclude controls. (maybe that's ok?. NOT OK.)
			where(conditions_array).left_join_patient

		else
			[]
		end
	end

	def duplicates(options={})
		StudySubject.duplicates({
			:mother_maiden_name => self.mother_maiden_name,
			:hospital_no => self.hospital_no,
			:dob => self.dob,
			:sex => self.sex,
			:admit_date => self.admit_date,
			:organization_id => self.organization_id }.merge(options))
#	trying to get 100% test coverage (20120411)
	end

	def raf_duplicate_creation_attempted(attempted_subject)
		self.operational_events.create!(
			:project_id                => Project['ccls'].id,
			:operational_event_type_id => OperationalEventType['DuplicateCase'].id,
			:occurred_at               => DateTime.current,
			:description               => "a new RAF for this subject was submitted by " <<
				"#{attempted_subject.admitting_oncologist} of " <<
				"#{attempted_subject.organization} " <<
				"with hospital number: " <<
				"#{attempted_subject.hospital_no}."
		)
	end

	def race_names
		subject_races.collect(&:to_s).join(', ')
	end

	def language_names
		subject_languages.collect(&:to_s).join(', ')
	end

	def residence_addresses_count
		addresses.where( :address_type => 'Residence' ).count
	end

	def current_mailing_address
		addresses.current.mailing.order('created_at DESC').first	#.try(:address)
	end
	alias_method :mailing_address, :current_mailing_address

	def current_address
		addresses.current.order('created_at DESC').first	#.try(:address)
	end
	alias_method :address, :current_address

	def address_street
		address.try(:street)
	end

	def address_unit
		address.try(:unit)
	end

	def address_city
		address.try(:city)
	end

	def address_county
		address.try(:county)
	end

	def address_state
		address.try(:state)
	end

	def address_zip
		address.try(:zip)
	end

	def address_latitude
		address.try(:latitude)
	end

	def address_longitude
		address.try(:longitude)
	end

	def enrollment(project)		#	20150213 - created
		@enrollments_hash ||= {}
		if @enrollments_hash.has_key?(project)
			@enrollments_hash[project]
		else
			@enrollments_hash[project] = enrollments.where( project: Project[project] ).first
		end
	end

	def add_ccls_enrollment
		enrollments.find_or_create_by(project_id: Project['ccls'].id)
	end

	def ccls_enrollment
		enrollment('ccls')
	end

	#	Returns all projects for which the study_subject
	#	does not have an enrollment
	def unenrolled_projects
		#	Making it complicated ( but this will return an ActiveRelation )
		Project.joins(
			Arel::Nodes::OuterJoin.new(Enrollment.arel_table,
				Arel::Nodes::On.new(
					Project.arel_table[:id].eq(Enrollment.arel_table[:project_id]).and(
						Enrollment.arel_table[:study_subject_id].eq(self.id))
				)
			)
		).where( Enrollment.arel_table[:study_subject_id].eq(nil) )
	end

	def ineligible?
		ccls_enrollment.is_not_eligible?
	end

	def refused?
		ccls_enrollment.not_consented?
	end

	#	All subjects are to have this operational event, so create after create.
	#	I suspect that this'll be attached to the CCLS project enrollment.
	def add_new_subject_operational_event
		self.operational_events.create!(
			:project_id                => Project['ccls'].id,
			:operational_event_type_id => OperationalEventType['newSubject'].id,
			:occurred_at               => DateTime.current
		)
	end

	#	Add this if the vital status changes to deceased.
	#	I suspect that this'll be attached to the CCLS project enrollment.
	def add_subject_died_operational_event
		if( ( vital_status_changed? ) &&
				( vital_status     == 'Deceased' ) && 
				( vital_status_was != 'Deceased' ) )	
			#
			#	If it changed and is now Deceased, obviously it wasn't Deceased. 
			#	Could remove that check.
			#
			self.operational_events.create!(
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['subjectDied'].id,
				:occurred_at               => DateTime.current
			)
		end
	end

	#	operational_events.occurred_at where operational_event_type_id = 26 and 
	#	enrollment_id is for any unended project (where projects.ended_on 
	#	is null) for study_subject_id
	def screener_complete_date_for_unended_project
		oe = self.operational_events.screener_complete.unended_project.limit(1).first
		#	separated to try to make 100% coverage (20120411)
		oe.try(:occurred_on)
	end

	#	Be advised that using a join in a scope will, by default, render those
	#	found as a "ReadOnlyRecord" so attempting to write to one will fail.  This can
	#	be countered by adding a "readonly(false)" to the scope chain.  Or you
	#	can simply re-find the given subject by id.
	scope :cases,    ->{ where(:subject_type => 'Case') }
	scope :controls, ->{ where(:subject_type => 'Control') }
	scope :mothers,  ->{ where(:subject_type => 'Mother') }
	scope :children, ->{ where(:subject_type => ['Case','Control']) }
	scope :living,   ->{ where(:vital_status => 'Living') }
	scope :with_patid, ->(id){ where(:patid => sprintf("%04d",id.to_i) ) }
	scope :with_childid, ->(id){ where(:childid => id.to_i) }
	scope :with_state_registrar_no, ->(id){ where(:state_registrar_no => id.to_s.squish) }
	scope :with_icf_master_id, ->(id){ where(:icf_master_id => id.to_s.squish) }
	scope :with_studyid, ->(id){ where(:studyid => id.to_s.squish) }
	scope :with_familyid, ->(id){ where(:familyid => sprintf("%06d",id.to_i)) }
	scope :with_matchingid, ->(id){ where(:matchingid => sprintf("%06d",id.to_i)) }
	scope :with_subjectid, ->(id){ where(:subjectid => sprintf("%06d",id.to_i)) }
	scope :not_id, ->(id){ where(self.arel_table[:id].not_eq(id)) }
	scope :left_join_patient, ->{ joins(
		Arel::Nodes::OuterJoin.new(Patient.arel_table,Arel::Nodes::On.new(
			self.arel_table[:id].eq(Patient.arel_table[:study_subject_id])))) }

	#	Find the case or control subject with matching familyid except self.
	def child
		if is_child?
			self
		else
			if !familyid.blank?
				StudySubject.children.with_subjectid(familyid).first
			else
				nil
			end
		end
	end

	#	Find the subject with matching matchingid and subject_type of Case.
	def case_subject
		( matchingid.blank? ) ? nil : StudySubject.cases.with_matchingid(matchingid).first
	end

	#	Find the subject with matching familyid and subject_type of Mother.
	def mother
		( familyid.blank? ) ? nil : StudySubject.mothers.with_familyid(familyid).first
	end

	#	Find all the subjects with matching familyid except self.
	def family
		if familyid.blank?
			StudySubject.where('1=0')	#	should NEVER be true
		else
			StudySubject.with_familyid(familyid).not_id(id)
		end
	end

	#	Find all the subjects with matching matchingid except self.
	def matching
		if matchingid.blank?
			StudySubject.where('1=0')	#	should NEVER be true
		else
			StudySubject.with_matchingid(matchingid).not_id(id)
		end
	end

	#	Find all the subjects with matching patid with subject_type Control except self.
	#	If patid is nil, this sql doesn't work.  
	#			TODO Could fix, but this situation is unlikely.
	def controls
		return [] unless is_case?
		StudySubject.controls.with_patid(patid).not_id(id)
	end

	def rejected_controls
		return [] unless is_case?
		CandidateControl.where(
			:related_patid    => patid,
			:reject_candidate => true
		)
	end

	def self.find_case_by_patid(patid)
		cases.with_patid(patid).first
	end

	def self.find_case_by_icf_master_id(icf_master_id)
		cases.with_icf_master_id(icf_master_id).first
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the vital status.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def guardian_relationships
		([self.guardian_relationship] + VALID_GUARDIAN_RELATIONSHIPS ).compact.uniq
	end

	def guardian_relationship_is_other?
		guardian_relationship.to_s.match(/^Other/i)
	end

	def abstracts_the_same?
		raise StudySubject::NotTwoAbstracts unless abstracts.count == 2
		#	abstracts.inject(:is_the_same_as?) was nice
		#	but using inject is ruby >= 1.8.7
		return abstracts[0].is_the_same_as?(abstracts[1])
	end

	def abstract_diffs
		raise StudySubject::NotTwoAbstracts unless abstracts.count == 2
		#	abstracts.inject(:diff) was nice
		#	but using inject is ruby >= 1.8.7
		return abstracts[0].diff(abstracts[1])
	end

	#	20150306 - what and where is nilify_if_blank
	nilify_if_blank :first_name, :middle_name, :maiden_name, :last_name,
		:mother_first_name, :mother_middle_name, :mother_maiden_name, :mother_last_name,
		:guardian_first_name, :guardian_middle_name, :guardian_last_name,
		:father_first_name, :father_middle_name, :father_last_name

	#	TODO include maiden_name just in case is mother???
	def childs_names
		[first_name, middle_name, maiden_name, last_name ]
	end

	#	Returns string containing study_subject's first, middle and last initials
	def initials
		childs_names.delete_if(&:blank?).collect{|s|s.chars.first}.join()
	end

	#	Returns string containing study_subject's first, middle and last name
	#	Use delete_if(&:blank?) instead of compact, which only removes nils.
	def full_name
		fullname = childs_names.delete_if(&:blank?).join(' ')
		( fullname.blank? ) ? '[name not available]' : fullname
	end

	def fathers_names
		[father_first_name, father_middle_name, father_last_name ]
	end

	#	Returns string containing study_subject's father's first, middle and last name
	def fathers_name
		fathersname = fathers_names.delete_if(&:blank?).join(' ')
		( fathersname.blank? ) ? '[name not available]' : fathersname
	end

	def mothers_names
		[mother_first_name, mother_middle_name, mother_maiden_name, mother_last_name ]
	end

	#	Returns string containing study_subject's mother's first, middle and last name
	#	TODO what? no maiden name?
	def mothers_name
		mothersname = mothers_names.delete_if(&:blank?).join(' ')
		( mothersname.blank? ) ? '[name not available]' : mothersname
	end

	def guardians_names
		[guardian_first_name, guardian_middle_name, guardian_last_name ]
	end

	#	Returns string containing study_subject's guardian's first, middle and last name
	def guardians_name
		guardiansname = guardians_names.delete_if(&:blank?).join(' ')
		( guardiansname.blank? ) ? '[name not available]' : guardiansname
	end

	def current_primary_phone
		phone_numbers.current.primary.first			#	by what order?
	end
	alias_method :primary_phone, :current_primary_phone

	def current_alternate_phone
		phone_numbers.current.alternate.first			#	by what order?
	end
	alias_method :alternate_phone, :current_alternate_phone

	#	We probably don't want to auto assign icf_master_ids 
	#		as it would add icf_master_ids to the old data.
	#	Perhaps, after the old data is imported, but that
	#		will definitely break a bunch of existing tests.
	def assign_icf_master_id
		if icf_master_id.blank?
			next_icf_master_id = IcfMasterId.next_unused.first
			if next_icf_master_id
				self.update_column(:icf_master_id, next_icf_master_id.to_s)
				self.update_column(:case_icf_master_id, next_icf_master_id.to_s) if is_case?
				self.update_column(:mother_icf_master_id, next_icf_master_id.to_s) if is_mother?
				self.update_column(:needs_reindexed, true)
				next_icf_master_id.study_subject = self
				next_icf_master_id.assigned_on   = Date.current
				next_icf_master_id.save!
			end
		end
		self
	end

	def icf_master_id_to_s
		icf_master_id.presence || "[no ID assigned]"
	end

	include StudySubjectSunspot

	validations_from_yaml_file

	#
	#	patid IS NOT UNIQUE as will be shared by controls
	#	childid and studyid should be
	#
	#	childid is numeric, so doesn't need to be nilified, but won't hurt
	#
	validates_uniqueness_of_with_nilification :state_id_no,
		:state_registrar_no, :local_registrar_no, 
		:childid, :studyid, :subjectid

	#	can't really validate the has many through 
	#	this won't highlight languages
	validates :subject_languages, :presence => true, :if => :language_required
	validate :must_be_case_if_patient
	validate :patient_admit_date_is_after_dob
	validate :patient_diagnosis_date_is_after_dob

	def set_default_phase
		# ||= doesn't work with ''
		self.phase ||= 5
	end

	def set_default_vital_status
		# ||= doesn't work with ''
		self.vital_status ||= 'Living'
	end

	def to_s
		[childid,'(',studyid,full_name,')'].compact.join(' ')
	end

	#	Create (or just return) a mother subject based on subject's own data.
	def create_mother
		return self if is_mother?
		#	The mother method will effectively find and itself.
		existing_mother = mother
		if existing_mother
			existing_mother	#	return the mother
		else
			new_mother = StudySubject.new do |s|
				s.subject_type = 'Mother'
				s.vital_status = 'Living'	 #	default, nevertheless
				s.sex = 'F'
				s.hispanicity = mother_hispanicity
				s.first_name  = mother_first_name
				s.middle_name = mother_middle_name
				s.last_name   = mother_last_name
				s.maiden_name = mother_maiden_name

				#	protected attributes!
				s.matchingid = matchingid
				s.familyid   = familyid

				#	TODO - what?  what is "to do" here?
				s.case_icf_master_id = self.case_icf_master_id

			end
			new_mother.save!
			new_mother.assign_icf_master_id

			#	TODO - rather than all the syncing, this is probably the best place for this.
			self.update_column(:mother_icf_master_id, new_mother.icf_master_id)
			self.update_column(:needs_reindexed, true)

			new_mother	#	return the mother
		end
	end

	def next_control_orderno(grouping='6')
		return nil unless is_case?
		last_control = StudySubject.select('orderno').order('orderno DESC'
			).where(
				:subject_type      => 'Control',
				:case_control_type => grouping,
				:matchingid        => self.subjectid ).first
		( last_control.try(:orderno) || 0 ) + 1
	end

	def childid_to_s
		( is_mother? ) ? "#{child.try(:childid)} (mother)" : childid
	end

	def studyid_to_s
		( is_mother? ) ? "n/a" : studyid
	end

	def replicates
		if replication_id.present?
			StudySubject.where(:replication_id => replication_id)
		else
			StudySubject.none
		end
	end

protected

	def birth_country_is_united_states?
		birth_country == 'United States'
	end

	def prepare_fields_for_validation

		self.sex.to_s.upcase!

		self.case_control_type = ( ( case_control_type.blank? 
			) ? nil : case_control_type.to_s.upcase )

		patid.try(:gsub!,/\D/,'')
		self.patid = sprintf("%04d",patid.to_i) unless patid.blank?

		matchingid.try(:gsub!,/\D/,'')
#	TODO add more tests for this (try with valid? method)
#puts "Matchingid before before validation:#{matchingid}"
		self.matchingid = sprintf("%06d",matchingid.to_i) unless matchingid.blank?
	end

	#	made separate method so can be stubbed
	def get_next_childid
		StudySubject.maximum(:childid).to_i + 1
	end

	#	made separate method so can be stubbed
	def get_next_patid
		StudySubject.maximum(:patid).to_i + 1
#
#	What happens if/when this goes over 4 digits? 
#	The database field is only 4 chars.
#
	end

	#	fields made from fields that WON'T change go here
	def prepare_fields_for_creation
		#	don't assign if given or is mother (childid is currently protected)
		self.childid = get_next_childid if !is_mother? and childid.blank?

		#	don't assign if given or is not case (patid is currently protected)
		self.patid = sprintf("%04d",get_next_patid.to_i) if is_case? and patid.blank?

#	should move this from pre validation to here for ALL subjects.
#		patid.try(:gsub!,/\D/,'')
#		self.patid = sprintf("%04d",patid.to_i) unless patid.blank?

		#	don't assign if given or is not case (orderno is currently protected)
		self.orderno = 0 if is_case? and orderno.blank?

		#	don't assign if given or is mother (studyid is currently protected)
		#	or if can't make complete studyid
		if !is_mother? and studyid.blank? and
				!patid.blank? and !case_control_type.blank? and !orderno.blank?
			self.studyid = "#{patid}-#{case_control_type}-#{orderno}" 
		end

		#	perhaps put in an after_save with an update_attribute(s)
		#	and simply generate a new one until all is well
		#	don't assign if given (subjectid is currently protected)
		self.subjectid = generate_subjectid if subjectid.blank?

		#	cases and controls: their own subjectID is also their familyID.
		#	mothers: their child's subjectID is their familyID. That is, 
		#					a mother and her child have identical familyIDs.
		#	don't assign if given (familyid is currently protected)
		self.familyid  = subjectid if !is_mother? and familyid.blank?

		#	cases (patients): matchingID is the study_subject's own subjectID
		#	controls: matchingID is subjectID of the associated case 
		#		(like PatID in this respect).
		#	mothers: matchingID is subjectID of their own child's associated case. 
		#			That is, a mother's matchingID is the same as their child's. This 
		#			will become clearer when I provide specs for mother study_subject creation.
#	matchingid is manually set in some tests.  will need to setup for stubbing this.
		#	don't assign if given (matchingid is currently NOT protected)
		self.matchingid = subjectid if is_case? and matchingid.blank?
	end

	#	made separate method so can stub it in testing
	#	This only guarantees uniqueness before creation,
	#		but not at creation. This is NOT scalable.
	#	Fortunately, we won't be creating tons of study_subjects
	#		at the same time so this should not be an issue,
	#		however, when it fails, it will be confusing.	#	TODO
	#	How to rescue from ActiveRecord::RecordInvalid here?
	#		or would it be RecordNotSaved?
#
#	Perhaps treat subjectid like icf_master_id?
#	Create a table with all of the possible 
#		subjectid ... (1..999999)
#		study_subject_id
#		assigned_on
#	Then select a random unassigned one?
#	Would this be faster?
#
	def generate_subjectid
		subjectids = ( (1..999999).to_a - StudySubject.select('subjectid'
			).collect(&:subjectid).collect(&:to_i) )
		sprintf("%06d",subjectids[rand(subjectids.length)].to_i)
	end

	#	This is a duplication of a patient validation that won't
	#	work if using nested attributes.  Don't like doing this.
	def patient_admit_date_is_after_dob
		if !patient.nil? && !patient.admit_date.blank? && 
				!dob.blank? && patient.admit_date < dob &&
				dob.to_date != Date.parse('1/1/1900') &&
				patient.admit_date.to_date != Date.parse('1/1/1900')
			errors.add('patient:admit_date', "Admit date is before study_subject's dob") 
		end
	end

	#	This is a duplication of a patient validation that won't
	#	work if using nested attributes.  Don't like doing this.
	def patient_diagnosis_date_is_after_dob
		if !patient.nil? && !patient.diagnosis_date.blank? && 
				!dob.blank? && patient.diagnosis_date < dob
			errors.add('patient:diagnosis_date', "Diagnosis date is before study_subject's dob") 
		end
	end

	def must_be_case_if_patient
		if !patient.nil? and !is_case?
			errors.add(:patient ,"Study subject must be case to have patient info")
		end
	end

	#
	# logger levels are ... debug, info, warn, error, and fatal.
	#
	def trigger_setting_was_under_15_at_dx
		logger.debug "DEBUG: calling update_patient_was_under_15_at_dx from "<<
			"StudySubject:#{self.id}"
		logger.debug "DEBUG: DOB changed from:#{dob_was}:to:#{dob}"
		update_patient_was_under_15_at_dx
	end

	def trigger_update_matching_study_subjects_reference_date
		logger.debug "DEBUG: triggering_update_matching_study_subjects_reference_date "<<
			"from StudySubject:#{self.id}"
		logger.debug "DEBUG: matchingid changed from:#{matchingid_was}:to:#{matchingid}"
		self.update_study_subjects_reference_date_matching(matchingid_was,matchingid)
	end

end
__END__
