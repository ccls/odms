#	Rich join of Subject and Address
class Address < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true
	attr_protected :study_subject_id, :study_subject

#	has_many :interviews	#	interviews.address_id


	#	flag used in study_subject's nested attributes for address
	#		to not reject if address fields are blank.
	attr_accessor :address_required

	attr_accessor :subject_moved

	scope :current,  
		->{ where(:current_address => YNDK[:yes]) }
	scope :historic, 
		->{ where(self.arel_table[:current_address].not_eq(YNDK[:yes])) }
	scope :needs_geocoded, ->{ where(:needs_geocoded => true) }
	scope :geocoding_failed, ->{ where(:geocoding_failed => true) }
	scope :not_geocoding_failed, ->{ where(:geocoding_failed => false) }
	scope :mailing, ->{ where(:address_type => 'Mailing') }


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

	after_save :create_subject_moved_event, :if => :subject_moved

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

	validate :address_type_matches_line

	# Would it be better to do this before_validation?
	before_save :format_zip, :if => :zip_changed?


	#	Returns a string with the city, state and zip
	def csz
		"#{self.city}, #{self.state} #{self.zip}"
	end

	def street
		[line_1,line_2].delete_if(&:blank?).join(', ')
	end

	def full
		"#{street}, #{csz}"
	end

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	VALID_ADDRESS_TYPES = %w( Residence Mailing Business Other Unknown )

	# This method is predominantly for a form selector.
	# It will show the existing value first followed by the other valid values.
	# This will allow an existing invalid value to show on the selector,
	#   but should fail on save as it is invalid.  This way it won't
	#   silently change the address type.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def address_types
		([self.address_type] + VALID_ADDRESS_TYPES ).compact.uniq
	end

	validations_from_yaml_file

	after_save :regeocode!, :if => :changed?

protected

	def reindex_study_subject!
		logger.debug "Address changed so reindexing study subject"
		#	don't know why birth_datum needs persisted? check but here doesn't
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
	end

	#	this will actually create an event on creation as well
	#	if attributes match
	def create_subject_moved_event
		if ['1','true'].include?(subject_moved) &&
				current_address == YNDK[:no] &&
				current_address_was != YNDK[:no] &&
				address_type == 'Residence'
			study_subject.operational_events.create!(
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['subject_moved'].id,
				:occurred_at               => DateTime.current
			)
		end
	end

	def regeocode!
		#	This too to trigger geocoding!
		update_column(:needs_geocoded, true)
		#	And this to ensure that if it previously failed, try geocoding it again
		update_column(:geocoding_failed, false)
	end

	#	Determine if the address is a PO Box and then
	#	require that the address type NOT be a residence.
	def address_type_matches_line
		#	It is inevitable that this will match too much
		#	Pobox Street?
		if(( line_1 =~ /p.*o.*box/i ) &&
			( address_type == 'Residence' ))
			errors.add(:address_type,
				"Address type must not be residence with PO Box") 
		end
	end

	#	Simply squish the zip removing leading and trailing spaces.
	#	zip MUST be a string or this won't work. Will always be
	#	a string when sent from a form.
	def format_zip
		#	zip was nil during import and skipping validations
		self.zip.squish! unless zip.nil?
		#	convert to 12345-1234
		if !self.zip.nil? and self.zip.length > 5
			old = self.zip.gsub(/\D/,'')
			self.zip = "#{old[0..4]}-#{old[5..8]}"
		end
	end

end
