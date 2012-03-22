#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class Project < ActiveRecord::Base

	acts_as_list
#	Don't use default_scope with acts_as_list
#	default_scope :order => :position

	acts_like_a_hash

	has_many :operational_events
	has_many :instrument_types
	has_many :enrollments
	has_many :samples
	has_many :gift_cards
	has_many :study_subjects, :through => :enrollments
	has_many :instruments

	validates_complete_date_for :began_on, :allow_nil => true
	validates_complete_date_for :ended_on, :allow_nil => true
	validates_length_of :eligibility_criteria, :maximum => 65000, :allow_blank => true

#	TODO perhaps move this into study_subject where is clearly belongs, but will need a RIGHT JOIN or something?
	#	Returns all projects for which the study_subject
	#	does not have an enrollment
	def self.unenrolled_projects(study_subject)
		Project.all(
			:joins => "LEFT JOIN enrollments ON " <<
				"projects.id = enrollments.project_id AND " <<
				"enrollments.study_subject_id = #{study_subject.id}",
			:conditions => [ "enrollments.study_subject_id IS NULL" ])
	end

	#	Returns description
	def to_s
		description
	end

end
