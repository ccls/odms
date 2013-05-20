#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class Project < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	# Created for simplification of OperationalEvent.open_project scope
	scope :open, where( :ended_on => nil )

	has_many :operational_events
	has_many :instrument_types
	has_many :enrollments
	has_many :samples
#	has_many :gift_cards
	has_many :study_subjects, :through => :enrollments
	has_many :instruments

	validations_from_yaml_file

##	TODO perhaps move this into study_subject where is clearly belongs, but will need a RIGHT JOIN or something?
#	#	Returns all projects for which the study_subject
#	#	does not have an enrollment
#	def self.unenrolled_projects(study_subject)
#		#	broke up to try to make 100% coverage (20120411)
#		projects = Project.joins("LEFT JOIN enrollments ON " <<
#				"projects.id = enrollments.project_id AND " <<
#				"enrollments.study_subject_id = #{study_subject.id}" )
#		#	everything is NULL actually, but check study_subject_id
#		projects = projects.where("enrollments.study_subject_id IS NULL")
#	end

	#	only for Enrollments.by_project_key which is only used in testing
	def self.by_key(key)
		where(arel_table[:key].matches(key.to_s))
	end

	#	Returns description
	def to_s
		description
	end

end
