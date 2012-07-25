class GiftCard < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :project

	validations_from_yaml_file

	def to_s
		number
	end

end
