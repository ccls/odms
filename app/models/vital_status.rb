#	don't know exactly
class VitalStatus < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :study_subjects

	#	Returns description
	def to_s
		description
	end

end
