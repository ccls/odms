#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectPii
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	validates_uniqueness_of_with_nilification :email

protected

	def birth_country_is_united_states?
		birth_country == 'United States'
	end

end	#	class_eval
end	#	included
end	#	StudySubjectPii
