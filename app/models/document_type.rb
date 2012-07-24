class DocumentType < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :document_versions

	validations_from_yaml_file

#	validates_presence_of :title
#	validates_length_of   :title, :maximum => 250, :allow_blank => true

	def to_s
		title
	end

end
