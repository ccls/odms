class Instrument < ActiveRecord::Base



	attr_protected	#	I really shouldn't do it this way




	acts_as_list
	acts_like_a_hash

	belongs_to :project
	belongs_to :interview_method
	has_many :instrument_versions

	validations_from_yaml_file

	#	Return name
	def to_s
		name
	end

end
