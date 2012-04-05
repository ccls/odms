#	==	requires
#	*	key ( unique )
#	*	description ( > 3 chars )
class Section < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :follow_ups

	#	Returns description
	def to_s
		description
	end

end
