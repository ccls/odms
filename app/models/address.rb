#	Address for a study_subject
#	Actually, this may be used for things other than subjects
class Address < ActiveRecord::Base

	has_many :interviews
	has_one :addressing
	has_one :study_subject, :through => :addressing
	belongs_to :address_type

	validate :address_type_matches_line

	validations_from_yaml_file

	# Would it be better to do this before_validation?
	before_save :format_zip, :if => :zip_changed?

	scope :needs_geocoded, ->{ where(:needs_geocoded => true) }
	scope :geocoding_failed, ->{ where(:geocoding_failed => true) }
	scope :not_geocoding_failed, ->{ where(:geocoding_failed => false) }

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

	after_save :reindex_study_subject!, :if => :changed?
	after_save :regeocode!, :if => :changed?
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Address changed so reindexing study subject"
		#	don't know why birth_datum needs persisted? check but here doesn't
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
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
			( address_type_id.to_s == '1' ))	#	1 is 'residence'
			errors.add(:address_type_id,
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
