#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectPatient
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_one :patient

	delegate :admit_date, :hospital_no, :organization, :organization_id,
			:to => :patient, :allow_nil => true

	accepts_nested_attributes_for :patient

	validate :must_be_case_if_patient
	validate :patient_admit_date_is_after_dob
	validate :patient_diagnosis_date_is_after_dob

	after_save   :trigger_setting_was_under_15_at_dx,
		:if => :dob_changed?
	after_save :trigger_update_matching_study_subjects_reference_date, 
		:if => :matchingid_changed?

	def admitting_oncologist
		#	can be blank so need more than try unless I nilify admitting_oncologist if blank
		#patient.try(:admitting_oncologist) || "[no oncologist specified]"
		if patient and !patient.admitting_oncologist.blank?
			patient.admitting_oncologist
		else
			"[no oncologist specified]"
		end
	end

	##
	#	triggered from patient and self
	def update_patient_was_under_15_at_dx
		#	due to the high probability that self and patient will not
		#		yet be resolved, we have to get the associations manually.
		my_patient = Patient.find_by_study_subject_id(self.attributes['id'])
		if dob && my_patient && my_patient.admit_date &&
				dob.to_date != Date.parse('1/1/1900') &&
				my_patient.admit_date.to_date != Date.parse('1/1/1900')
			#
			#	update_all(updates, conditions = nil, options = {})
			#
			#		Updates all records with details given if they match a set of 
			#		conditions supplied, limits and order can also be supplied. 
			#		This method constructs a single SQL UPDATE statement and sends 
			#		it straight to the database. It does not instantiate the involved 
			#		models and it does not trigger Active Record callbacks. 
			#
			#	crude and probably off by a couple days
			#	would be better to compare year, month then day
#			was_under_15 = (((
#				my_patient.admit_date.to_date - dob.to_date 
#				) / 365 ) < 15 ) ? YNDK[:yes] : YNDK[:no]

			#	Seems likely to be more accurate as accounts for differing year 
			#	lengths rather than the number of days.
			#	As this is completely a computable field, I don't really
			#	like doing this.  The existence of incorrect data already
			#	is reason enough.  Nevertheless, if you're gonna do it,
			#	do it right.
#irb(main):038:0> Date.today
#=> Wed, 04 Apr 2012
#irb(main):039:0> Date.today + 15.years
#=> Sun, 04 Apr 2027
			fifteenth_birthday = dob.to_date + 15.years
			was_under_15 = ( my_patient.admit_date.to_date < fifteenth_birthday ) ? 
				YNDK[:yes] : YNDK[:no]

			Patient.update_all(
				{ :was_under_15_at_dx => was_under_15 }, 
				{ :id => my_patient.id })
		end
		#	make sure we return true as is a callback
		true
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
				matching_patient = StudySubject.where(:subjectid => mid).first.try(:patient)
				unless matching_patient.nil?
					admit_date = matching_patient.try(:admit_date)
					StudySubject.update_all(
						{:reference_date => admit_date },
						{:matchingid     => mid })
				end
			end
		end
		true
	end

protected

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
			"StudySubject:#{self.attributes['id']}"
		logger.debug "DEBUG: DOB changed from:#{dob_was}:to:#{dob}"
		update_patient_was_under_15_at_dx
	end

	def trigger_update_matching_study_subjects_reference_date
		logger.debug "DEBUG: triggering_update_matching_study_subjects_reference_date "<<
			"from StudySubject:#{self.attributes['id']}"
		logger.debug "DEBUG: matchingid changed from:#{matchingid_was}:to:#{matchingid}"
		self.update_study_subjects_reference_date_matching(matchingid_was,matchingid)
	end

end	#	class_eval
end	#	included
end	#	StudySubjectPatient
