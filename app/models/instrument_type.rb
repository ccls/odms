#	==	requires
#	*	description ( unique and > 3 chars )
#	*	project
class InstrumentType < ActiveRecord::Base

	attr_accessible :project_id, :key, :description #	position?

	acts_as_list
	acts_like_a_hash

	belongs_to :project
	has_many :instrument_versions

	validations_from_yaml_file

	#	Returns description
	def to_s
		description
	end

end
