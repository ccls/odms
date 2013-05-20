#	The type of address (home,work,residence,pobox,etc.)
class AddressType < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash
	has_many :addresses

	#	Created for simplification of Addressing.mailing scope
	scope :mailing, where(:key => 'mailing')

	#	Returns the key
	def to_s
		self.key
	end

end
