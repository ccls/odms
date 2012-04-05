#	Rich join of Subject and Address
class Addressing < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject

	belongs_to :address
	belongs_to :data_source

	#	TODO test this.  Also may not need current_user now.
#	This works in the console and such, but ActiveScaffold tries
#	to use it in a join, but it is in a different database so fails.
#	May be able to make it work in AS, but need to fiddle.
#	belongs_to :verified_by, :foreign_key => 'verified_by_uid',
#		:class_name => 'User', :primary_key => 'uid'

	delegate :is_other?, :to => :data_source, :allow_nil => true, :prefix => true
	delegate :address_type, :address_type_id,
		:line_1,:line_2,:unit,:city,:state,:zip,:csz,:county,
			:to => :address, :allow_nil => true

	attr_accessor :current_user

	#	flag used in study_subject's nested attributes for addressing
	#		to not reject if address fields are blank.
	attr_accessor :address_required

	validates_length_of   :why_invalid, :how_verified, 
		:maximum => 250, :allow_blank => true
	validates_presence_of :why_invalid,  :if => :is_not_valid?
	validates_presence_of :how_verified, :if => :is_verified?

	validates_complete_date_for :valid_from, :valid_to,
		:allow_blank => true

	validates_presence_of :other_data_source, :if => :data_source_is_other?

	validates_inclusion_of :current_address, :is_valid, :address_at_diagnosis,
			:in => YNDK.valid_values, :allow_nil => true

	scope :current,  where('current_address IS NOT NULL AND current_address != 2')
	scope :historic, where('current_address IS NULL OR current_address = 2')

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
#		[2,999].include?(is_valid.to_i)
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
				:occurred_on               => Date.today
			)
		end
	end

end
__END__

#	after_create :check_state_for_eligibilty

#	def check_state_for_eligibilty
#		if( state != 'CA' && study_subject && 
#			( hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id) ) &&
#			address_type_id == AddressType['residence'].id )
#
#			#	This is an after_save so using 1 NOT 0
#			ineligible_reason = if( study_subject.residence_addresses_count == 1 )
#				IneligibleReason['newnonCA']
#			else
#				IneligibleReason['moved']
#			end
#
#			hxe.update_attributes(
#				:is_eligible => YNDK[:no],
#				:ineligible_reason_id => ineligible_reason.id
#			)
#
#			oet = OperationalEventType['ineligible']
#			if( oet.blank? )
#				errors.add(:base,"OperationalEventType['ineligible'] not found")
#				#	I'm surprised that I need this raise?
#				raise ActiveRecord::RecordNotSaved
#			end
#
#			study_subject.operational_events.create!(
#				:project_id                => Project['HomeExposures'].id,
#				:operational_event_type_id => oet.id,
#				:occurred_on               => Date.today,
#				:description               => ineligible_reason.to_s
#			)
#		end
#	end

