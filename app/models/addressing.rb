#	Rich join of Subject and Address
class Addressing < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject

	belongs_to :address
	belongs_to :data_source

#	belongs_to :verified_by, :foreign_key => 'verified_by_uid',
#		:class_name => 'User', :primary_key => 'uid'

	delegate :is_other?, :to => :data_source, :allow_nil => true, :prefix => true
	delegate :address_type, :address_type_id,:street,
		:line_1,:line_2,:unit,:city,:state,:zip,:csz,:county,
			:to => :address, :allow_nil => true

	attr_accessor :current_user

	#	flag used in study_subject's nested attributes for addressing
	#		to not reject if address fields are blank.
	attr_accessor :address_required

	validations_from_yaml_file

	scope :current,  where('current_address IS NOT NULL AND current_address != 2')
	scope :historic, where('current_address IS NULL OR current_address = 2')

#	can't do this as getting the address type fails in testing as db is cleared
#	scope :mailing, joins(:address).where("addresses.address_type_id = #{AddressType['mailing'].id}")
	scope :mailing, joins(:address => :address_type).where("address_types.key = 'mailing'")

	#	Don't do the rejections here.
	accepts_nested_attributes_for :address

	attr_accessor :subject_moved

	after_save :create_subject_moved_event, :if => :subject_moved

	before_save :set_verifier, 
		:if => :is_verified?, 
		:unless => :is_verified_was

	before_save :nullify_verifier, 
		:unless => :is_verified?,
		:if => :is_verified_was

	#	Returns boolean of comparison of is_valid == 2 or 999
	#	Rails SHOULD convert incoming string params to integer.
	def is_not_valid?
		[2,999].include?(is_valid)
	end

protected

	#	Set verified date and user if given
	def set_verifier
		self.verified_on = Date.today	#	Time.now
		self.verified_by_uid = current_user.try(:uid)||''
	end

	#	Unset verified date and user
	def nullify_verifier
		self.verified_on = nil
		self.verified_by_uid = nil
	end

	#	this will actually create an event on creation as well
	#	if attributes match
	def create_subject_moved_event
		if ['1','true'].include?(subject_moved) &&
				current_address == YNDK[:no] &&
				current_address_was != YNDK[:no] &&
				address.address_type_id == AddressType['residence'].id
			study_subject.operational_events.create!(
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['subject_moved'].id,
				:occurred_at               => DateTime.now
			)
		end
	end

end
__END__
