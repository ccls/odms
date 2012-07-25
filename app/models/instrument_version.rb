#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
#	*	interview_type_id
class InstrumentVersion < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	belongs_to :language
	belongs_to :instrument_type
	belongs_to :instrument
	has_many :interviews

	validations_from_yaml_file

	#	Returns description
	def to_s
		description
	end

end
