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

#	belongs_to :guardian_relationship, :class_name => 'SubjectRelationship'
#
#	#	generates guardian_relationship_is_other? method
#	delegate :is_other?, :to => :guardian_relationship, 
#		:allow_nil => true, :prefix => true 

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


irb(main):001:0> StudySubject.group(:guardian_relationship_id).count
  Project Load (0.3ms)  SELECT `projects`.* FROM `projects`   ORDER BY `projects`.`position` ASC
   (37.9ms)  SELECT COUNT(*) AS count_all, guardian_relationship_id AS guardian_relationship_id FROM `study_subjects`  GROUP BY guardian_relationship_id
=> {nil=>24563, 4=>2, 7=>1, 999=>2}

used grandparent, other and unknown


StudySubject.where(:guardian_relationship_id => 4).update_all(:guardian_relationship => "Subject's grandparent")
StudySubject.where(:guardian_relationship_id => 7).update_all(:guardian_relationship => "Other relationship to Subject")
StudySubject.where(:guardian_relationship_id => 999).update_all(:guardian_relationship => "Unknown relationship to subject")





unknown:
  id: 999
  key: unknown
  description: Unknown relationship to subject
mother:
  id: 2
  key: mother
  description: Subject's mother
father:
  id: 3
  key: father
  description: Subject's father
grandparent:
  id: 4
  key: grandparent
  description: Subject's grandparent
foster:
  id: 5
  key: foster
  description:  Subject's foster parent
twin:
  id: 6
  key: twin
  description:  Subject's twin
other:
  id: 7
  key: other
  description:  Other relationship to Subject
sibling:
  id: 8
  key: sibling
  description: Subject's sibling
stepparent:
  id: 9
  key: stepparent
  description: Subject's step parent
