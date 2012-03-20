#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module PatientValidations
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

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
		:message => "should be 12345 or 12345-1234",
		:allow_blank => true

	validates_inclusion_of :was_under_15_at_dx, :was_previously_treated,
		:was_ca_resident_at_diagnosis,
			:in => YNDK.valid_values, :allow_nil => true

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
			errors.add(:admit_date, "is before study_subject's dob.") 
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
			errors.add(:diagnosis_date, "is before study_subject's dob.") 
		end
	end

	##
	#	Both are patient dates so this doesn't need in subject!
	#	custom validation and custom message
	def treatment_began_on_is_after_diagnosis_date
		if !treatment_began_on.blank? && 
			!diagnosis_date.blank? && 
			treatment_began_on < diagnosis_date
#			errors.add(:treatment_began_on, "is before diagnosis_date.") 
#	TODO Rails 3 difference breaks my custom error messages without
#				field name prefix in message!!!!
#			errors.add(:treatment_began_on, ActiveRecord::Error.new(
#				self, :base, :blank, { 
#					:message => "Date treatment began must be on or after the diagnosis date." } ) )
			errors.add(:treatment_began_on, 
				"Date treatment began must be on or after the diagnosis date." )
		end
	end

	##
	#	This validation does not work when using nested attributes as 
	#	the study_subject has not been resolved yet, unless this is an update.
	#	This results in a similar validation in Subject.
	def subject_is_case
		if study_subject and !study_subject.is_case?
			errors.add(:study_subject,"must be case to have patient info")
		end
	end

end	#	class_eval
end	#	included
end	#	PatientValidations
