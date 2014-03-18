class Instrument < ActiveRecord::Base

	attr_accessible :project_id, :results_table_id, :key, :name, :description, :interview_method_id, 
		:began_use_on, :ended_use_on #	position?

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
