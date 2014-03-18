#	==	requires
#	*	code ( unique )
#	*	description ( unique and > 3 chars )
class Language < ActiveRecord::Base



	attr_protected	#	I really shouldn't do it this way




	acts_as_list
	acts_like_a_hash

	validations_from_yaml_file

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
