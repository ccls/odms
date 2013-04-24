#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectPhoneNumbers
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :phone_numbers

	accepts_nested_attributes_for :phone_numbers,
		:reject_if => proc { |attrs| attrs[:phone_number].blank? }

	def current_primary_phone
		phone_numbers.current.primary.first			#	by what order?
	end
	alias_method :primary_phone, :current_primary_phone

	def current_alternate_phone
		phone_numbers.current.alternate.first			#	by what order?
	end
	alias_method :alternate_phone, :current_alternate_phone

end	#	class_eval
end	#	included
end	#	StudySubjectPhoneNumbers
