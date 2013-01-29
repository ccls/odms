#	==	requires
#	*	code ( unique )
#	*	description ( unique and > 3 chars )
class Race < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	#	Returns description
	def to_s
		description
	end

	#	Returns boolean of comparison
	#	true only if key == 'other'
	def is_other?
		key == 'other'
	end

	#	Returns boolean of comparison
	#	true only if key == 'mixed'
	def is_mixed?
		key == 'mixed'
	end

end
