# A study_subject's phone number
class PhoneNumber < ActiveRecord::Base

	acts_as_list :scope => :study_subject_id

	belongs_to :study_subject, :counter_cache => true
#	attr_protected :study_subject_id, :study_subject

	scope :current,  
		->{ where(:current_phone => YNDK[:yes]) }
	scope :historic, 
		->{ where(self.arel_table[:current_phone].not_eq(YNDK[:yes])) }
	scope :primary,   
		->{ where(:is_primary => true) }
	scope :alternate,  
		->{ where(self.arel_table[:is_primary].eq_any([nil,false])) }

	before_save :format_phone_number, :if => :phone_number_changed?

	#	Returns description
	def to_s
		phone_number
	end

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	VALID_PHONE_TYPES = %w( Home Mobile Work Unknown )

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the phone type.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def phone_types
		([self.phone_type] + VALID_PHONE_TYPES ).compact.uniq
	end

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	VALID_DATA_SOURCES = ["RAF (CCLS Rapid Ascertainment Form)", 
			"Study Consent Form", "Interview with Subject", 
			"USPS Address Service", "Other Source", "Migrated from Tracking2k database", 
			"Unknown Data Source", "Provided by Survey Research Center ('SRC')", 
			"Provided to CCLS by ICF", "Live Birth data from USC" ]

	# This method is predominantly for a form selector.
	# It will show the existing value first followed by the other valid values.
	# This will allow an existing invalid value to show on the selector,
	#   but should fail on save as it is invalid.  This way it won't
	#   silently change the data source.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def data_sources
		([self.data_source] + VALID_DATA_SOURCES ).compact.uniq
	end

	def data_source_is_other?
		data_source == 'Other Source'
	end

	validations_from_yaml_file

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Phone Number changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
	end

	#	Formats phone numer with () and -
	def format_phone_number
		unless self.phone_number.nil?
			old = self.phone_number.gsub(/\D/,'')
			new_phone = "(#{old[0..2]}) #{old[3..5]}-#{old[6..9]}"
			self.phone_number = new_phone
		end
	end

end
