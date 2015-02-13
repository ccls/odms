#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectEnrollments
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :enrollments
	accepts_nested_attributes_for :enrollments

	# All subjects are to have a CCLS project enrollment, so create after create.
	after_create :add_ccls_enrollment

	def enrollment(project)		#	20150213 - created
		@enrollments_hash ||= {}
		if @enrollments_hash.has_key?(project)
			@enrollments_hash[project]
		else
			@enrollments_hash[project] = enrollments.where( project: Project[project] ).first
		end
	end

	def add_ccls_enrollment
		enrollments.find_or_create_by(project_id: Project['ccls'].id)
	end

	def ccls_enrollment
#		enrollments.where(:project_id => Project['ccls'].id).first
#	20150213 - changed from above to below
		enrollment('ccls')

#	for some reason, this doesn't actually find the enrollment and tries to create another one.
#	this violates the uniqueness validation and causes RAF submissions to fail.  ?????
#		enrollments.find_or_create_by(project_id: Project['ccls'].id)
	end

	#	Returns all projects for which the study_subject
	#	does not have an enrollment
	def unenrolled_projects
		#	Making it complicated ( but this will return an ActiveRelation )
		Project.joins(
			Arel::Nodes::OuterJoin.new(Enrollment.arel_table,
				Arel::Nodes::On.new(
					Project.arel_table[:id].eq(Enrollment.arel_table[:project_id]).and(
						Enrollment.arel_table[:study_subject_id].eq(self.id))
				)
			)
		).where( Enrollment.arel_table[:study_subject_id].eq(nil) )
	end

	def ineligible?
		ccls_enrollment.is_not_eligible?
	end

	def refused?
		ccls_enrollment.not_consented?
	end

end	#	class_eval
end	#	included
end	#	StudySubjectEnrollments
