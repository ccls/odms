class County < ActiveRecord::Base

	has_many :zip_codes

	validations_from_yaml_file

	def to_s
		"#{name}, #{state_abbrev}"
	end

end
