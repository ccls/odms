#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class Project < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	# Created for simplification of OperationalEvent.unended_project scope
	#	The 'open' method is already defined, so DON'T USE IT
	scope :unended, ->{ where( :ended_on => nil ) }

	has_many :operational_events
	has_many :enrollments
	has_many :samples
	has_many :study_subjects, :through => :enrollments

	validations_from_yaml_file

	#	only for Enrollments.by_project_key which is only used in testing
	scope :by_key, ->(key){ where(arel_table[:key].matches(key.to_s)) }

	#	Returns description
	def to_s
		description
	end

end
