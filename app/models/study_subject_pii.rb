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

#	:with => /
#		\A([-a-z0-9!\#$%&'*+\/=?^_`{|}~]+\.)*
#		[-a-z0-9!\#$%&'*+\/=?^_`{|}~]+
#		@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
#	using Regexp.new instead so that I can split it on several lines
#	The trailing 'true' makes it case insensitive

	validates_format_of :email,
	  :with => Regexp.new(
			'\A([-a-z0-9!\#$%&\'*+\/=?^_`{|}~]+\.)*' <<
			'[-a-z0-9!\#$%&\'*+\/=?^_`{|}~]+' <<
			'@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z', true), 
		:allow_blank => true

protected

	def birth_country_is_united_states?
		birth_country == 'United States'
	end

end	#	class_eval
end	#	included
end	#	StudySubjectPii
