class DocumentVersion < ActiveRecord::Base

	attr_accessible :document_type_id, :title, :description, :indicator, :language_id, :began_use_on, :ended_use_on #	position?

	acts_as_list
	belongs_to :document_type
	belongs_to :language
	has_many :enrollments

	validations_from_yaml_file

	#	Return title
	def to_s
		title
	end

	scope :type1, ->{ where(:document_type_id => 1) }

end
