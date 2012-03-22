#	==	requires
#	*	code ( unique )
#	*	description ( unique and > 3 chars )
class Language < ActiveRecord::Base

	acts_as_list
#	Don't use default_scope with acts_as_list
#	default_scope :order => :position

	acts_like_a_hash

	has_many :interviews
	has_many :instrument_versions

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
