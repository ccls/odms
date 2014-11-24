#	Rich join of Subject and Project
#	==	requires
#	*	project
class Enrollment < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true
	belongs_to :ineligible_reason
	belongs_to :refusal_reason
	belongs_to :document_version
	belongs_to :project

	attr_protected :study_subject_id, :study_subject

	delegate :is_other?, :to => :ineligible_reason, :allow_nil => true, :prefix => true
	delegate :is_other?, :to => :refusal_reason,    :allow_nil => true, :prefix => true

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
	def consented?
		consented == YNDK[:yes]	#1
	end

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

	scope :consented, ->{ where( :consented   => YNDK[:yes] ) }
	scope :eligible,  ->{ where( :is_eligible => YNDK[:yes] ) }

	scope :assigned_for_interview,  
		->{ where(self.arel_table[:assigned_for_interview_at].not_eq(nil)) }

	scope :not_assigned_for_interview,  ->{ where(:assigned_for_interview_at => nil) }

	scope :interview_completed,  ->{ where(self.arel_table[:interview_completed_on].not_eq(nil)) }

	scope :by_project_key, ->(key){ joins(:project).merge(Project.by_key(key.to_s)) }

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	def self.valid_tracing_statuses
		["Subject Tracing In Progress", "Subject Found", "Unable To Locate", "Unknown Tracing Status"]
	end

	def self.valid_project_outcomes
		["complete", "closed prior to completion", "open (pending)"]
	end
	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the tracing status.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def tracing_statuses
		([self.tracing_status] + self.class.valid_tracing_statuses ).compact.uniq
	end
	#	it is my personal opinion that project_outcome should be on 
	#	project and not enrollment. it makes no sense to be here.
	def project_outcomes
		([self.project_outcome] + self.class.valid_project_outcomes ).compact.uniq
	end

	validations_from_yaml_file

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Enrollment changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
	end

	def create_enrollment_update
		if study_subject
			operational_event_type, occurred_at = if( is_complete == YNDK[:yes] )
				[OperationalEventType['complete'], completed_on]
			elsif( is_complete_was == YNDK[:yes] )
				[OperationalEventType['reopened'], DateTime.current]
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
