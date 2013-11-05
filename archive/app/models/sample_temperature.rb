class SampleTemperature < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :samples

	def to_s
		description
	end

end
