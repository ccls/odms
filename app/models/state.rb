# Currently just US states + DC
class State < ActiveRecord::Base

	acts_as_list

	validations_from_yaml_file

	# Returns an array of state abbreviations.
	def self.abbreviations
		@@abbreviations ||= all.collect(&:code)
	end

end
