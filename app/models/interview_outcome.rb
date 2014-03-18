# don't know exactly
class InterviewOutcome < ActiveRecord::Base

	attr_accessible :key, :description #	position ?

	acts_as_list
	acts_like_a_hash

	has_many :homex_outcomes

	#	Returns description
	def to_s
		description
	end

end
