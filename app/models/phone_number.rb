# A study_subject's phone number
class PhoneNumber < ActiveRecord::Base

	acts_as_list :scope => :study_subject_id

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :phone_type
	belongs_to :data_source

#	belongs_to :verified_by, :foreign_key => 'verified_by_uid',
#		:class_name => 'User', :primary_key => 'uid'

	delegate :is_other?, :to => :data_source, :allow_nil => true, :prefix => true

	validations_from_yaml_file

	#	Want to ensure contains 10 digits.
	#	I'm kinda surprised that this regex works.
	validates_format_of   :phone_number, :with => /\A(\D*\d\D*){10}\z/,
		:allow_blank => true

#	The table names isn't absolutely necessary, but if used in a join
#	the field name could be ambiguous and would fail.
	scope :current,  
		where( 'phone_numbers.current_phone IS NOT NULL AND phone_numbers.current_phone != 2' )
	scope :historic, 
		where( 'phone_numbers.current_phone IS NULL OR phone_numbers.current_phone = 2' )
	scope :primary,   
		where(:is_primary => true)
	scope :alternate, 
		where('phone_numbers.is_primary IS NULL OR phone_numbers.is_primary = false')

	before_save :format_phone_number, :if => :phone_number_changed?

#	before_save :set_verifier, 
#		:if => :is_verified?, 
#		:unless => :is_verified_was
#
#	before_save :nullify_verifier, 
#		:unless => :is_verified?,
#		:if => :is_verified_was

	attr_accessor :current_user

	#	Returns description
	def to_s
		phone_number
	end

#	#	Returns boolean of comparison
#	#	true only if is_valid == 2 or 999
#	#	Beware of strings from forms
#	#	Rails SHOULD convert incoming string params to integer.
#	def is_not_valid?
#		[2,999].include?(is_valid)
#	end

protected

#	#	Set verified date and user if given
#	def set_verifier
#		self.verified_on = Date.today	#	Time.now
#		self.verified_by_uid = current_user.try(:uid)||''
#	end
#
#	#	Unset verified date and user
#	def nullify_verifier
#		self.verified_on = nil
#		self.verified_by_uid = nil
#	end

	#	Formats phone numer with () and -
	def format_phone_number
		unless self.phone_number.nil?
			old = self.phone_number.gsub(/\D/,'')
			new_phone = "(#{old[0..2]}) #{old[3..5]}-#{old[6..9]}"
			self.phone_number = new_phone
		end
	end

end
