# Patient related study_subject info.
class Patient < ActiveRecord::Base

	belongs_to :study_subject
	belongs_to :organization
	belongs_to :diagnosis

	delegate :is_other?, :to => :diagnosis, :allow_nil => true, :prefix => true

	attr_protected( :study_subject_id, :study_subject )

	before_save :format_hospital_no, :if => :hospital_no_changed?

	validate :admit_date_is_on_or_after_dob
	validate :diagnosis_date_is_on_or_after_dob
	validate :treatment_began_on_is_on_or_after_diagnosis_date
	validate :treatment_began_on_is_on_or_after_admit_date
	validate :subject_is_case

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	def self.valid_diagnoses
		["ALL", "AML", "other diagnosis", "missing data (e.g. legacy nulls)", "unknown diagnosis"]
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the phone type.
	def diagnoses
		[self.diagnosis] + ( self.class.valid_diagnoses - [self.diagnosis])
	end

#	def diagnosis_is_other?
#		diagnosis == 'other diagnosis'
#	end

	validations_from_yaml_file

	#	Would it be better to do this before_validation?
	before_save :format_raf_zip, :if => :raf_zip_changed?

	after_save :trigger_update_matching_study_subjects_reference_date,
		:if => :admit_date_changed?

	after_save :trigger_setting_was_under_15_at_dx

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Patient changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
	end

	##
	#	This validation does not work when using nested attributes as 
	#	the study_subject has not been resolved yet, unless this is an update.
	#	This results in a similar validation in Subject.
	def admit_date_is_on_or_after_dob
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
	def diagnosis_date_is_on_or_after_dob
		if !diagnosis_date.blank? && 
				!study_subject.blank? && 
				!study_subject.dob.blank? && 
				diagnosis_date < study_subject.dob
			errors.add(:diagnosis_date, "Diagnosis date is before study_subject's dob.") 
		end
	end

	##
	#	Both are patient dates so this doesn't need duplicated in subject!
	#	custom validation and custom message
	def treatment_began_on_is_on_or_after_diagnosis_date
		if !treatment_began_on.blank? && 
				!diagnosis_date.blank? && 
				treatment_began_on < diagnosis_date
			errors.add(:treatment_began_on, 
				"Date treatment began must be on or after the diagnosis date" )
		end
	end

	##
	#	Both are patient dates so this doesn't need duplicated in subject!
	#	custom validation and custom message
	def treatment_began_on_is_on_or_after_admit_date
		if !treatment_began_on.blank? && 
				!admit_date.blank? && 
				treatment_began_on < admit_date
			errors.add(:treatment_began_on, 
				"Date treatment began must be on or after the admit date" )
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

	def format_hospital_no
		# just remove the non-alphanumerics
		self.hospital_no = self.hospital_no.gsub(/\W/,'')
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
		if admit_date_changed? or was_under_15_at_dx_changed?
			logger.debug "DEBUG: calling update_patient_was_under_15_at_dx from " <<
				"Patient:#{self.id}"
			logger.debug "DEBUG: Admit date changed from:" <<
				"#{admit_date_was}:to:#{admit_date}"
			logger.debug "DEBUG: was_under_15_at_dx changed from:" <<
				"#{was_under_15_at_dx_was}:to:#{was_under_15_at_dx}"
			if study_subject
				logger.debug "DEBUG: study_subject:#{study_subject.id}"
				study_subject.update_patient_was_under_15_at_dx
			else
				#	This should never happen, except in testing. 
				#	(subjectless_patient Factory)
				logger.warn "WARNING: Patient(#{self.id}) is missing study_subject"
			end
		end
	end
#
#	logger levels are ... debug, info, warn, error, and fatal.
#
	def trigger_update_matching_study_subjects_reference_date
		logger.debug "DEBUG: calling update_study_subjects_reference_date_matching from " <<
			"Patient:#{self.id}"
		logger.debug "DEBUG: Admit date changed from:#{admit_date_was}:to:#{admit_date}"
		if study_subject
			logger.debug "DEBUG: study_subject:#{study_subject.id}"
			# study_subject.update_matching_study_subjects_reference_date
			study_subject.update_study_subjects_reference_date_matching
		else
			#	This should never happen, except in testing.
			logger.warn "WARNING: Patient(#{self.id}) is missing study_subject"
		end
	end

end
