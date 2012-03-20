# The type of phone number (home,work,mobile,etc.)
class PhoneType < ActiveRecord::Base

	acts_as_list
#	Don't use default_scope with acts_as_list
#	default_scope :order => :position

	acts_like_a_hash
	has_many :phone_numbers

	#	Returns key
	def to_s
		key
	end

end
