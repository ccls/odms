#	==	requires
#	*	code ( unique )
#	*	description ( unique and > 3 chars )
class Language < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	validates_presence_of   :code, :allow_blank => false
	validates_uniqueness_of :code

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
