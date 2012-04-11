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

#	I don't think that this is used anymore. (20120411)
#
#	#	Returns description
#	def name
#		description
#	end

	#	Returns boolean of comparison
	#	true only if key == 'other'
	def is_other?
		key == 'other'
	end

end
