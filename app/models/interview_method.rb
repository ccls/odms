# don't know exactly
class InterviewMethod < ActiveRecord::Base



	attr_protected	#	I really shouldn't do it this way




	acts_as_list
	acts_like_a_hash

	has_many :interviews
	has_many :instruments

	#	Returns description
	def to_s
		description
	end

end
