#	==	requires
#	*	description ( unique and > 3 chars )
class RefusalReason < ActiveRecord::Base

	attr_accessible :key, :description #	position ?

	acts_as_list
	acts_like_a_hash

	has_many :enrollments

	#	Returns description
	def to_s
		description
	end

	#	Returns boolean of comparison
	#	true only if key == 'other'
	def is_other?
		key == 'other'
	end

end
