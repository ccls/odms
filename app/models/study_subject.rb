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

	has_and_belongs_to_many :analyses
	has_one :home_exposure_response
	has_many :birth_data
	has_many :bc_requests
	has_many :interviews
	has_many :medical_record_requests

	include StudySubjectSubjectType
	include StudySubjectVitalStatus
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
	include StudySubjectGuardianRelationship
	include StudySubjectAbstracts
	include StudySubjectNames
	include StudySubjectPhoneNumbers
	include StudySubjectIcfMasterId
	include StudySubjectSamples
	include StudySubjectSunspot

	validations_from_yaml_file

	#
	#	patid IS NOT UNIQUE as will be shared by controls
	#	childid and studyid should be
	#
	#	childid is numeric, so doesn't need to be nilified, but won't hurt
	#
	validates_uniqueness_of_with_nilification :ssn, :state_id_no,
		:state_registrar_no, :local_registrar_no, :gbid, :lab_no_wiemels, 
		:accession_no, :idno_wiemels, :childid, :studyid, :subjectid

	after_initialize :set_default_phase, :if => :new_record?
	def set_default_phase
		# ||= doesn't work with ''
		self.phase ||= 5
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

#	TODO
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

end
__END__
