#	Rich join of Subject and Project
#	==	requires
#	*	project
class Enrollment < ActiveRecord::Base

	belongs_to :study_subject
	belongs_to :ineligible_reason
	belongs_to :refusal_reason
	belongs_to :document_version
	belongs_to :project
	belongs_to :project_outcome
	belongs_to :tracing_status
	has_many   :follow_ups

	attr_protected :study_subject_id, :study_subject

	delegate :is_other?, :to => :ineligible_reason, :allow_nil => true, :prefix => true
	delegate :is_other?, :to => :refusal_reason,    :allow_nil => true, :prefix => true

	validations_from_yaml_file

	#	Return boolean of comparison
	#	true only if is_eligible == 2
	def is_not_eligible?
		is_eligible == YNDK[:no]	#2
	end

	#	Return boolean of comparison
	#	true only if is_chosen == 2
	def is_not_chosen?
		is_chosen == YNDK[:no]	#2
	end

	#	Return boolean of comparison
	#	true only if consented == 1
#	no longer used, I believe
#	def consented?
#		consented == 1
#	end

	#	Return boolean of comparison
	#	true only if consented == 2
	def not_consented?
		consented == YNDK[:no]	#2
	end

	#	Return boolean of comparison
	#	true only if consented == nil or 999
	def consent_unknown?
		[nil,999].include?(consented)	#	not 1 or 2
	end

	#	Return boolean of comparison
	#	true only if terminated_participation == 1
	def terminated_participation?
		terminated_participation == YNDK[:yes]	#	1
	end

	#	Return boolean of comparison
	#	true only if is_complete == 1
	def is_complete?
		is_complete == YNDK[:yes]	#	1
	end

	after_save :create_enrollment_update,
		:if => :is_complete_changed?

	after_save :create_subject_consents_operational_event,
		:if => :consented_changed?

	after_save :create_subject_declines_operational_event,
		:if => :consented_changed?

	scope :consented, :conditions => { :consented => YNDK[:yes] }

protected

	def create_enrollment_update
		if study_subject
			operational_event_type, occurred_at = if( is_complete == YNDK[:yes] )
				[OperationalEventType['complete'], completed_on]
			elsif( is_complete_was == YNDK[:yes] )
				[OperationalEventType['reopened'], DateTime.now]
			else 
				[nil, nil]
			end
			unless operational_event_type.nil?
				self.study_subject.operational_events.create!(
					:project_id                => self.project.id,
					:operational_event_type_id => operational_event_type.id,
					:occurred_at               => occurred_at
				)
			end
		end
	end

	def create_subject_consents_operational_event
		if( study_subject and ( consented == YNDK[:yes] ) and ( consented_was != YNDK[:yes] ) )
			self.study_subject.operational_events.create!(
				:project_id                => self.project.id,
				:operational_event_type_id => OperationalEventType['subjectConsents'].id,
				:occurred_at               => consented_on
			)
		end
	end

	def create_subject_declines_operational_event
		if( study_subject and ( consented == YNDK[:no] ) and ( consented_was != YNDK[:no] ) )
			self.study_subject.operational_events.create!(
				:project_id                => self.project.id,
				:operational_event_type_id => OperationalEventType['subjectDeclines'].id,
				:occurred_at               => consented_on
			)
		end
	end

end
