#	==	requires
#	*	address_id
#	*	interviewer_id
#	*	study_subject_id
class Interview < ActiveRecord::Base

#	NOTE this is not used

	belongs_to :study_subject, :counter_cache => true
	attr_protected( :study_subject_id, :study_subject )

	##
	#	why is this here?	Homex for assigning interview outcome
	accepts_nested_attributes_for :study_subject

#	belongs_to :address
	belongs_to :interviewer, :class_name => 'Person'
	belongs_to :instrument_version
	belongs_to :interview_method
	belongs_to :language

	def self.valid_subject_relationships
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
	def subject_relationships
		([self.subject_relationship] + self.class.valid_subject_relationships ).compact.uniq
	end

	def subject_relationship_is_other?
		subject_relationship.to_s.match(/^Other/i)
	end

	validations_from_yaml_file

	#	Returns string containing respondent's first and last name
	def respondent_full_name
		[respondent_first_name, respondent_last_name].compact.join(' ')
	end

protected

	#	used in validations (although thought this was handled in method missing?
	def subject_relationship_blank?
		subject_relationship.blank?
	end

end
__END__
