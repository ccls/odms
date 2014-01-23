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

	has_many :addresses

	accepts_nested_attributes_for :addresses,
		:reject_if => proc { |attrs|
			!attrs[:address_required] &&
			( attrs[:line_1].blank? &&
				attrs[:line_2].blank? &&
				attrs[:unit].blank? &&
				attrs[:city].blank? &&
				attrs[:zip].blank? &&
				attrs[:county].blank? )
		}

	#	Returns number of addresses with 
	#	address_type.key == 'residence'
	def residence_addresses_count
		addresses.where( :address_type => 'Residence' ).count
	end

	def current_mailing_address
		addresses.current.mailing.order('created_at DESC').first	#.try(:address)
	end
	alias_method :mailing_address, :current_mailing_address

	def current_address
		addresses.current.order('created_at DESC').first	#.try(:address)
	end
	alias_method :address, :current_address

#	def current_address_at_dx
#		addresses.current.order('created_at DESC').first.try(:address_at_diagnosis)
#	end

	def address_street
		address.try(:street)
	end

	def address_unit
		address.try(:unit)
	end

	def address_city
		address.try(:city)
	end

	def address_county
		address.try(:county)
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
