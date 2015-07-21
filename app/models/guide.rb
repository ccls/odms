class Guide < ActiveRecord::Base

	validations_from_yaml_file

	def to_s
		"#{controller}##{action}"
	end

end
