#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectOperationalEvents
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :operational_events

	after_create :add_new_subject_operational_event
	after_save   :add_subject_died_operational_event

	#	All subjects are to have this operational event, so create after create.
	#	I suspect that this'll be attached to the CCLS project enrollment.
	def add_new_subject_operational_event
		self.operational_events.create!(
			:project_id                => Project['ccls'].id,
			:operational_event_type_id => OperationalEventType['newSubject'].id,
			:occurred_on               => Date.today
		)
	end

	#	Add this if the vital status changes to deceased.
	#	I suspect that this'll be attached to the CCLS project enrollment.
	def add_subject_died_operational_event
		if( ( vital_status_id == VitalStatus['deceased'].id ) && 
				( vital_status_id_was != VitalStatus['deceased'].id ) )
			self.operational_events.create!(
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['subjectDied'].id,
				:occurred_on               => Date.today
			)
		end
	end

#	operational_events.occurred_on where operational_event_type_id = 26 and enrollment_id is for any open project (where projects.ended_on is null) for study_subject_id

	def screener_complete_date_for_open_project
		oe = self.operational_events.joins(:project).where(
			'projects.ended_on IS NULL').where(
			"operational_event_type_id = ?",OperationalEventType['screener_complete'].id
			).limit(1).first
#	separated to try to make 100% coverage (20120411)
		oe.try(:occurred_on)
	end

end	#	class_eval
end	#	included
end	#	StudySubjectOperationalEvents
__END__
