class GiftCard < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :project


	validations_from_yaml_file


#	validates_presence_of   :number
#	validates_uniqueness_of :number
#	validates_length_of     :number, :expiration, :vendor,
#		:maximum => 250, :allow_blank => true

	def to_s
		number
	end

end
