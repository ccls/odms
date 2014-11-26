#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectGuardianRelationship
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	def self.valid_guardian_relationships
		["Subject's mother", "Subject's father", "Subject's grandparent", 
			"Subject's foster parent", "Subject's twin", "Other relationship to Subject", 
			"Subject's sibling", "Subject's step parent", "Unknown relationship to subject"]
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the vital status.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def guardian_relationships
		([self.guardian_relationship] + self.class.valid_guardian_relationships ).compact.uniq
	end

	def guardian_relationship_is_other?
		guardian_relationship.to_s.match(/^Other/i)
	end


end	#	class_eval
end	#	included
end	#	StudySubjectGuardianRelationship
__END__
