#	==	requires
#	*	description (unique and > 3 chars)
class IneligibleReason < ActiveRecord::Base

	acts_as_list
	default_scope :order => :position

	acts_like_a_hash

	has_many :enrollments

	validates_length_of     :ineligible_context, 
		:maximum => 250, :allow_blank => true

	#	Returns description
	def to_s
		description
	end

	#	Returns boolean of comparison
	#	true only if key == 'other'
	def is_other?
		key == 'other'
	end

end
