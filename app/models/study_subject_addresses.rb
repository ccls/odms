#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectAddresses
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :addressings
	has_many :addresses, :through => :addressings

	accepts_nested_attributes_for :addressings,
		:reject_if => proc { |attrs|
			!attrs[:address_required] &&
			( attrs[:address_attributes].blank? || (
				attrs[:address_attributes][:line_1].blank? &&
				attrs[:address_attributes][:line_2].blank? &&
				attrs[:address_attributes][:unit].blank? &&
				attrs[:address_attributes][:city].blank? &&
				attrs[:address_attributes][:zip].blank? &&
				attrs[:address_attributes][:county].blank? ) )
		}

	#	Returns number of addresses with 
	#	address_type.key == 'residence'
	def residence_addresses_count
		addresses.where( :address_type_id => AddressType['residence'].id ).count
	end

	def current_mailing_address
		addressings.current.mailing.order('created_at DESC').first.try(:address)
	end
	alias_method :mailing_address, :current_mailing_address

	def current_address
		addressings.current.order('created_at DESC').first.try(:address)
	end
	alias_method :address, :current_address

	#
	#	Can I delegate these?
	#	Yes, but for some reason the SQL query for addressing executes twice?
	#
	#	delegate :street, :to => :address, :allow_nil => true, :prefix => true
	#	delegate :unit, :to => :address, :allow_nil => true, :prefix => true

	def address_street
		address.try(:street)
	end

	def address_unit
		address.try(:unit)
	end

	def address_city
		address.try(:city)
	end

	def address_state
		address.try(:state)
	end

	def address_zip
		address.try(:zip)
	end

	def address_latitude
		address.try(:latitude)
	end

	def address_longitude
		address.try(:longitude)
	end

end	#	class_eval
end	#	included
end	#	StudySubjectAddresses
