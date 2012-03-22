# don't know exactly
class HomexOutcome < ActiveRecord::Base

	acts_as_list
#	Don't use default_scope with acts_as_list
#	default_scope :order => :position

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :sample_outcome
	belongs_to :interview_outcome

	validates_uniqueness_of :study_subject_id, :allow_nil => true
	validates_presence_of   :sample_outcome_on,    :if => :sample_outcome_id?
	validates_presence_of   :interview_outcome_on, :if => :interview_outcome_id?
	validates_complete_date_for :interview_outcome_on, :allow_nil => true
	validates_complete_date_for :sample_outcome_on,    :allow_nil => true

	before_save :create_interview_outcome_update,
		:if => :interview_outcome_id_changed?

	before_save :create_sample_outcome_update,
		:if => :sample_outcome_id_changed?

	class NoHomeExposureEnrollment < StandardError	#	:nodoc:
	end

protected

	#	Create OperationalEvent regarding the interview outcome
	def create_interview_outcome_update
		operational_event_type = case interview_outcome 
			when InterviewOutcome['scheduled']
				OperationalEventType['scheduled']
			when InterviewOutcome['complete']
				OperationalEventType['iv_complete']
			else nil
		end
		unless operational_event_type.nil?
			if hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#				study_subject.operational_events.new(
				study_subject.operational_events.create!(
					:project_id                => Project['HomeExposures'].id,
					:operational_event_type_id => operational_event_type.id,
					:occurred_on               => interview_outcome_on
				)
#				).save!
			else
				raise NoHomeExposureEnrollment 
			end
		end
	end

	#	Create OperationalEvent regarding the sample outcome
	def create_sample_outcome_update
		operational_event_type = case sample_outcome 
			when SampleOutcome['sent']
				OperationalEventType['kit_sent']
			when SampleOutcome['received']
				OperationalEventType['sample_received']
			when SampleOutcome['complete']
				OperationalEventType['sample_complete']
			else nil
		end
		unless operational_event_type.nil?
			if hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#				study_subject.operational_events.new(
				study_subject.operational_events.create!(
					:project_id                => Project['HomeExposures'].id,
					:operational_event_type_id => operational_event_type.id,
					:occurred_on               => sample_outcome_on
				)
#				).save!
			else
				raise NoHomeExposureEnrollment 
			end
		end
	end

end
