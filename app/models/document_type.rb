class DocumentType < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :document_versions

	validations_from_yaml_file

	def to_s
		title
	end

end
