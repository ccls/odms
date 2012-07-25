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

	belongs_to :guardian_relationship, :class_name => 'SubjectRelationship'

	#	generates guardian_relationship_is_other? method
	delegate :is_other?, :to => :guardian_relationship, 
		:allow_nil => true, :prefix => true 

#	validates_presence_of :other_guardian_relationship,
#		:message => "You must specify a relationship with 'other relationship' is selected",
#		:if => :guardian_relationship_is_other?
#
#	validates_length_of :other_guardian_relationship,
#		:maximum => 250, :allow_blank => true

end	#	class_eval
end	#	included
end	#	StudySubjectGuardianRelationship
