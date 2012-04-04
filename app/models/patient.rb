# Patient related study_subject info.
class Patient < ActiveRecord::Base

	belongs_to :study_subject
	belongs_to :organization
	belongs_to :diagnosis

	delegate :is_other?, :to => :diagnosis, :allow_nil => true, :prefix => true

	attr_protected( :study_subject_id, :study_subject )

	validates_presence_of :admit_date, :organization_id, :diagnosis_id, :hospital_no
	validates_presence_of :other_diagnosis, :if => :diagnosis_is_other?

	validates_length_of   :hospital_no, :maximum => 25, :allow_blank => true
	validates_uniqueness_of :hospital_no, :scope => :organization_id
	validates_past_date_for :admit_date, :diagnosis_date, :treatment_began_on
	validate :admit_date_is_after_dob
	validate :diagnosis_date_is_after_dob
	validate :treatment_began_on_is_after_diagnosis_date
	validate :subject_is_case
#	changed from allow_nil to allow_blank
	validates_complete_date_for :admit_date,         :allow_blank => true
	validates_complete_date_for :diagnosis_date,     :allow_blank => true
	validates_complete_date_for :treatment_began_on, :allow_blank => true

	validates_length_of :raf_zip, :maximum => 10, :allow_blank => true

	validates_format_of :raf_zip,
		:with => /\A\s*\d{5}(-)?(\d{4})?\s*\z/,
		:message => "RAF zip should be formatted 12345 or 12345-1234",
		:allow_blank => true

	validates_inclusion_of :was_under_15_at_dx, :was_previously_treated,
		:was_ca_resident_at_diagnosis,
			:in => YNDK.valid_values, :allow_nil => true

	#	Would it be better to do this before_validation?
	before_save :format_raf_zip, :if => :raf_zip_changed?

	after_save :trigger_update_matching_study_subjects_reference_date,
		:if => :admit_date_changed?

	after_save :trigger_setting_was_under_15_at_dx,
		:if => :admit_date_changed?

protected

	##
	#	This validation does not work when using nested attributes as 
	#	the study_subject has not been resolved yet, unless this is an update.
	#	This results in a similar validation in Subject.
	def admit_date_is_after_dob
		if !admit_date.blank? && 
				!study_subject.blank? && 
				!study_subject.dob.blank? && 
				study_subject.dob.to_date != Date.parse('1/1/1900') &&
				admit_date < study_subject.dob &&
				admit_date.to_date != Date.parse('1/1/1900')
			errors.add(:admit_date, "Admit date is before study_subject's dob.") 
		end
	end

	##
	#	This validation does not work when using nested attributes as 
	#	the study_subject has not been resolved yet, unless this is an update.
	#	This results in a similar validation in Subject.
	def diagnosis_date_is_after_dob
		if !diagnosis_date.blank? && 
				!study_subject.blank? && 
				!study_subject.dob.blank? && 
				diagnosis_date < study_subject.dob
			errors.add(:diagnosis_date, "Diagnosis date is before study_subject's dob.") 
		end
	end

	##
	#	Both are patient dates so this doesn't need in subject!
	#	custom validation and custom message
	def treatment_began_on_is_after_diagnosis_date
		if !treatment_began_on.blank? && 
				!diagnosis_date.blank? && 
				treatment_began_on < diagnosis_date
			errors.add(:treatment_began_on, 
				"Date treatment began must be on or after the diagnosis date" )
		end
	end

	##
	#	This validation does not work when using nested attributes as 
	#	the study_subject has not been resolved yet, unless this is an update.
	#	This results in a similar validation in Subject.
	def subject_is_case
		if study_subject and !study_subject.is_case?
			errors.add(:study_subject,"Study subject must be case to have patient info")
		end
	end

	#	Simply squish the zip removing leading and trailing spaces.
	def format_raf_zip
		#	zip was nil during import and skipping validations
		self.raf_zip.squish! unless raf_zip.nil?
		# convert to 12345-1234
		if !self.raf_zip.nil? and self.raf_zip.length > 5
			old = self.raf_zip.gsub(/\D/,'')
			self.raf_zip = "#{old[0..4]}-#{old[5..8]}"
		end
	end

	def trigger_setting_was_under_15_at_dx
		logger.debug "DEBUG: calling update_patient_was_under_15_at_dx from Patient:#{self.attributes['id']}"
		logger.debug "DEBUG: Admit date changed from:#{admit_date_was}:to:#{admit_date}"
		if study_subject
			logger.debug "DEBUG: study_subject:#{study_subject.id}"
			study_subject.update_patient_was_under_15_at_dx
		else
			#	This should never happen, except in testing.
			logger.warn "WARNING: Patient(#{self.attributes['id']}) is missing study_subject"
		end
	end
#
#	logger levels are ... debug, info, warn, error, and fatal.
#
	def trigger_update_matching_study_subjects_reference_date
		logger.debug "DEBUG: calling update_study_subjects_reference_date_matching from Patient:#{self.attributes['id']}"
		logger.debug "DEBUG: Admit date changed from:#{admit_date_was}:to:#{admit_date}"
		if study_subject
			logger.debug "DEBUG: study_subject:#{study_subject.id}"
			# study_subject.update_matching_study_subjects_reference_date
			study_subject.update_study_subjects_reference_date_matching
		else
			#	This should never happen, except in testing.
			logger.warn "WARNING: Patient(#{self.attributes['id']}) is missing study_subject"
		end
	end

end
