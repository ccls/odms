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

	belongs_to :subject_type
	belongs_to :vital_status

	has_and_belongs_to_many :analyses
	has_many :gift_cards
	has_many :phone_numbers
	has_many :samples
	has_one :home_exposure_response
	has_many :bc_requests
	has_many :interviews
	belongs_to :guardian_relationship, :class_name => 'SubjectRelationship'
	has_many :abstracts

	include StudySubjectPatient
	include StudySubjectPii
	include StudySubjectIdentifier
	include StudySubjectDuplicates
	include StudySubjectRaces
	include StudySubjectLanguages
	include StudySubjectAddresses

	#	Declaration order matters. 
	#	OperationalEvents are through Enrollments.
	include StudySubjectEnrollments
	include StudySubjectOperationalEvents

	include StudySubjectHomexOutcome
	include StudySubjectFinders

	#	generates guardian_relationship_is_other? method
	delegate :is_other?, :to => :guardian_relationship, 
		:allow_nil => true, :prefix => true 

	accepts_nested_attributes_for :phone_numbers,
		:reject_if => proc { |attrs| attrs[:phone_number].blank? }
	accepts_nested_attributes_for :gift_cards

##################################################
#
#	Begin validations
#
	validates_presence_of :subject_type_id
	validates_presence_of :subject_type, :if => :subject_type_id

	validates_presence_of  :sex,
		:message => "Sex has not been chosen"
	validates_inclusion_of :sex, :in => %w( M F DK ), :allow_blank => true
#	validates_inclusion_of :sex, :in => valid_sex_values, :allow_blank => true
	validates_inclusion_of :do_not_contact, :in => [ true, false ]

	validates_complete_date_for :reference_date, :allow_nil => true

	validates_presence_of :dob, :unless => :is_mother?
	validates_complete_date_for :dob, :allow_blank => true
	validates_past_date_for     :dob, :allow_blank => true

	validates_complete_date_for :died_on, :allow_blank => true
	validates_uniqueness_of     :email, :icf_master_id, :state_id_no, 
:childid, :studyid,
		:state_registrar_no, :local_registrar_no, :gbid, :lab_no_wiemels, 
		:accession_no, :idno_wiemels, :studyid, :subjectid, :allow_nil => true
#
#	patid IS NOT UNIQUE as will be shared by controls
#	childid and studyid should be
#

	validates_format_of :email,
	  :with => /\A([-a-z0-9!\#$%&'*+\/=?^_`{|}~]+\.)*[-a-z0-9!\#$%&'*+\/=?^_`{|}~]+@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
		:allow_blank => true

	validates_presence_of :other_guardian_relationship,
		:message => "You must specify a relationship with 'other relationship' is selected",
		:if => :guardian_relationship_is_other?

	validates_presence_of :birth_city,  :if => :birth_country_is_united_states?
	validates_presence_of :birth_state, :if => :birth_country_is_united_states?

	validates_length_of :case_control_type, :is => 1, :allow_nil => true

	validates_length_of     :ssn, :maximum => 250, :allow_nil => true
	validates_uniqueness_of :ssn, :allow_nil => true
	validates_format_of     :ssn, :with => /\A\d{3}-\d{2}-\d{4}\z/,
		:message => "SSN should be formatted ###-##-####", :allow_nil => true

 	validates_length_of :birth_year, 
			:maximum => 4, :allow_blank => true
	validates_length_of :newid, 
			:maximum => 6, :allow_blank => true
	validates_length_of :icf_master_id, 
			:maximum => 9, :allow_blank => true
	validates_length_of :childidwho, :idno_wiemels, 
 		:generational_suffix, :father_generational_suffix, 
			:maximum => 10, :allow_blank => true
	validates_length_of :lab_no_wiemels, :accession_no, 
			:maximum => 25, :allow_blank => true
	validates_length_of :gbid, 
			:maximum => 26, :allow_blank => true
	validates_length_of :first_name, :last_name, 
		:middle_name, :maiden_name, :other_guardian_relationship,
		:father_first_name, :father_middle_name, :father_last_name,
		:mother_first_name, :mother_middle_name, :mother_maiden_name, :mother_last_name,
		:guardian_first_name, :guardian_middle_name, :guardian_last_name,
		:other_mother_race, :other_father_race,
		:birth_city, :birth_state, :birth_country,
		:state_id_no, :state_registrar_no, :local_registrar_no,
		:lab_no, :related_childid, :related_case_childid,
			:maximum => 250, :allow_blank => true

	validates_inclusion_of :mom_is_biomom, :dad_is_biodad,
			:in => YNDK.valid_values, :allow_nil => true
#
#	End validations
#
##################################################

	after_initialize :set_defaults, :if => :new_record?
	def set_defaults
		# ||= doesn't work with ''
		self.vital_status_id ||= VitalStatus['living'].id
#		self.vital_status ||= VitalStatus['living']
	end

	def to_s
		[childid,'(',studyid,full_name,')'].compact.join(' ')
	end

	#	Returns boolean of comparison
	#	true only if type is Case
	def is_case?
		subject_type_id == StudySubject.subject_type_case_id
	end

	#	Returns boolean of comparison
	#	true only if type is Control
	def is_control?
		subject_type_id == StudySubject.subject_type_control_id
	end

	#	Returns boolean of comparison
	#	true only if type is Mother
	def is_mother?
		subject_type_id == StudySubject.subject_type_mother_id
	end

	#	Create (or just return) a mother subject based on subject's own data.
	def create_mother
		return self if is_mother?
		#	The mother method will effectively find and itself.
		existing_mother = mother
		if existing_mother
			existing_mother
		else
			new_mother = StudySubject.new do |s|
				s.subject_type_id = StudySubject.subject_type_mother_id
				s.vital_status_id = VitalStatus['living'].id	 #	default
				s.sex = 'F'
				s.hispanicity_id = mother_hispanicity_id
				s.first_name  = mother_first_name
				s.middle_name = mother_middle_name
				s.last_name   = mother_last_name
				s.maiden_name = mother_maiden_name

				#	protected attributes!
				s.matchingid = matchingid
				s.familyid   = familyid
			end
			new_mother.save!
			new_mother.assign_icf_master_id
			new_mother
		end
	end

	#	We probably don't want to auto assign icf_master_ids 
	#		as it would add icf_master_ids to the old data.
	#	Perhaps, after the old data is imported, but that
	#		will definitely break a bunch of existing tests.
	def assign_icf_master_id
		if icf_master_id.blank?
			next_icf_master_id = IcfMasterId.next_unused.first
			if next_icf_master_id
				self.update_attribute(:icf_master_id, next_icf_master_id.to_s)
				next_icf_master_id.study_subject = self
				next_icf_master_id.assigned_on   = Date.today
				next_icf_master_id.save!
			end
		end
		self
	end

	def next_control_orderno(grouping='6')
		return nil unless is_case?
		last_control = StudySubject.select('orderno').order('orderno DESC'
			).where(
				:subject_type_id   => StudySubject.subject_type_control_id,
				:case_control_type => grouping,
				:matchingid        => self.subjectid
			).first
		( last_control.try(:orderno) || 0 ) + 1
	end

	def icf_master_id_to_s
		( icf_master_id.blank? ) ?  "[no ID assigned]" : icf_master_id
	end

	def childid_to_s
		( is_mother? ) ? "#{child.try(:childid)} (mother)" : childid
	end

	def studyid_to_s
		( is_mother? ) ? "n/a" : studyid
	end

	def abstracts_the_same?
		raise StudySubject::NotTwoAbstracts unless abstracts_count == 2
		#	abstracts.inject(:is_the_same_as?) was nice
		#	but using inject is ruby >= 1.8.7
		return abstracts[0].is_the_same_as?(abstracts[1])
	end

	def abstract_diffs
		raise StudySubject::NotTwoAbstracts unless abstracts_count == 2
		#	abstracts.inject(:diff) was nice
		#	but using inject is ruby >= 1.8.7
		return abstracts[0].diff(abstracts[1])
	end

protected

	def birth_country_is_united_states?
		birth_country == 'United States'
	end

	#	Use these to stop the constant checking.
	def self.subject_type_mother_id
		@@subject_type_mother_id ||= SubjectType['Mother'].id
	end
	def self.subject_type_control_id
		@@subject_type_control_id ||= SubjectType['Control'].id
	end
	def self.subject_type_case_id
		@@subject_type_case_id ||= SubjectType['Case'].id
	end

end
__END__
