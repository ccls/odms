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

	validates_presence_of   :project_id
	validates_presence_of   :project, :if => :project_id
	validates_uniqueness_of :project_id, :scope => [:study_subject_id], :allow_blank => true

	validates_length_of :notes, :maximum => 65000, :allow_blank => true

	validates_presence_of :ineligible_reason_id,
		:message => 'Ineligible reason is required if is_eligible is No',
		:if => :is_not_eligible?
	validates_absence_of :ineligible_reason_id,
		:message => 'Ineligible reason is not allowed unless is_eligible is No',
		:unless => :is_not_eligible?
	validates_presence_of :ineligible_reason, :if => :ineligible_reason_id

	validates_presence_of :other_ineligible_reason,
		:message => 'Other ineligible reason is required if ineligible reason is Other',
		:if => :ineligible_reason_is_other?
	validates_absence_of :other_ineligible_reason,
		:message => 'Other ineligible reason is not allowed unless is_eligible is No',
		:unless => :is_not_eligible?

	validates_presence_of :reason_not_chosen,
		:message => 'Reason not chosen is required if is_chosen is No',
		:if => :is_not_chosen?
	validates_absence_of :reason_not_chosen,
		:message => 'Reason not chosen is not allowed unless is_chosen is No',
		:unless => :is_not_chosen?

	validates_presence_of :refusal_reason_id,
		:message => "Refusal reason is required if consented is No",
		:if => :not_consented?
	validates_absence_of :refusal_reason_id,
		:message => "Refusal reason is not allowed unless consented is No",
		:unless => :not_consented?
	validates_presence_of :refusal_reason, :if => :refusal_reason_id

#	validates_presence_of :consented_on,
#		:message => 'Consented on date is required when adding consent information',
#		:if => :consented?
	validates_presence_of :consented_on,
		:message => 'Consented on date is required when adding consent information',
		:unless => :consent_unknown?
#		:if => :not_consented?
	validates_absence_of :consented_on,
		:message => "Consented on date is not allowed if consented is blank or Don't Know",
		:if => :consent_unknown?
	validates_past_date_for :consented_on, :allow_blank => true

	validates_presence_of :other_refusal_reason,
		:message => "Other refusal reason is required if refusal reason is Other",
		:if => :refusal_reason_is_other?
	validates_absence_of :other_refusal_reason,
		:message => "Other refusal reason not allowed unless consented is No",
		:unless => :not_consented?

	validates_presence_of :terminated_reason,
		:message => "Terminated reason is required if terminated participation is Yes",
		:if => :terminated_participation?
	validates_absence_of :terminated_reason,
		:message => "Terminated reason is not allowed unless terminated participation is Yes",
		:unless => :terminated_participation?

	validates_presence_of :completed_on,
		:message => "Completed on is required if is_complete is Yes",
		:if => :is_complete?
	validates_absence_of :completed_on,
		:message => "Completed on is not allowed unless is_complete is Yes",
		:unless => :is_complete?
	validates_past_date_for :completed_on, :allow_blank => true

	validates_absence_of :document_version_id,
		:message => "Document version is not allowed if consented is blank or Don't Know",
		:if => :consent_unknown?
	validates_presence_of :document_version, :if => :document_version_id
	
#	validates_complete_date_for :consented_on, :allow_nil => true
#	changed to allow_blank as will be blank coming from form
	validates_complete_date_for :consented_on, :allow_blank => true
	validates_complete_date_for :completed_on, :allow_blank => true

	validates_length_of :recruitment_priority, :other_ineligible_reason,
		:other_refusal_reason, :reason_not_chosen,
		:terminated_reason, :reason_closed,
			:maximum => 250, :allow_blank => true


	validates_inclusion_of :consented, :is_eligible,
		:is_chosen, :is_complete, :terminated_participation,
		:is_candidate,
			:in => YNDK.valid_values, :allow_nil => true

	validates_inclusion_of :use_smp_future_rsrch,
		:use_smp_future_cancer_rsrch, :use_smp_future_other_rsrch,
		:share_smp_with_others, :contact_for_related_study,
		:provide_saliva_smp, :receive_study_findings,
			:in => ADNA.valid_values, :allow_nil => true

	#	Return boolean of comparison
	#	true only if is_eligible == 2
	def is_not_eligible?
#		is_eligible.to_i == YNDK[:no]	#2
		is_eligible == YNDK[:no]	#2
	end

	#	Return boolean of comparison
	#	true only if is_chosen == 2
	def is_not_chosen?
#		is_chosen.to_i == YNDK[:no]	#2
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
#		consented.to_i == YNDK[:no]	#2
		consented == YNDK[:no]	#2
	end

	#	Return boolean of comparison
	#	true only if consented == nil or 999
	def consent_unknown?
#		[nil,999,'','999'].include?(consented)	#	not 1 or 2
		[nil,999].include?(consented)	#	not 1 or 2
	end

	#	Return boolean of comparison
	#	true only if terminated_participation == 1
	def terminated_participation?
#		terminated_participation.to_i == YNDK[:yes]	#	1
		terminated_participation == YNDK[:yes]	#	1
	end

	#	Return boolean of comparison
	#	true only if is_complete == 1
	def is_complete?
#		is_complete.to_i == YNDK[:yes]	#	1
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
			operational_event_type, occurred_on = if( is_complete == YNDK[:yes] )
				[OperationalEventType['complete'], completed_on]
			elsif( is_complete_was == YNDK[:yes] )
				[OperationalEventType['reopened'], Date.today]
			else 
				[nil, nil]
			end
			unless operational_event_type.nil?
				self.study_subject.operational_events.create!(
					:project_id                => self.project.id,
					:operational_event_type_id => operational_event_type.id,
					:occurred_on               => occurred_on
				)
			end
		end
	end

	def create_subject_consents_operational_event
		if( study_subject and ( consented == YNDK[:yes] ) and ( consented_was != YNDK[:yes] ) )
			self.study_subject.operational_events.create!(
				:project_id                => self.project.id,
				:operational_event_type_id => OperationalEventType['subjectConsents'].id,
				:occurred_on               => consented_on
			)
		end
	end

	def create_subject_declines_operational_event
		if( study_subject and ( consented == YNDK[:no] ) and ( consented_was != YNDK[:no] ) )
			self.study_subject.operational_events.create!(
				:project_id                => self.project.id,
				:operational_event_type_id => OperationalEventType['subjectDeclines'].id,
				:occurred_on               => consented_on
			)
		end
	end

end
