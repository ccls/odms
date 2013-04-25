# don't know exactly
class HomexOutcome < ActiveRecord::Base

#	NOTE this is not used

	acts_as_list

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :sample_outcome
	belongs_to :interview_outcome

	validations_from_yaml_file

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
			if hxe = study_subject.enrollments.where(
					:project_id => Project['HomeExposures'].id).first
				study_subject.operational_events.create!(
					:project_id                => Project['HomeExposures'].id,
					:operational_event_type_id => operational_event_type.id,
					:occurred_at               => interview_outcome_on
				)
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
			if hxe = study_subject.enrollments.where(
					:project_id => Project['HomeExposures'].id).first
				study_subject.operational_events.create!(
					:project_id                => Project['HomeExposures'].id,
					:operational_event_type_id => operational_event_type.id,
					:occurred_at               => sample_outcome_on
				)
			else
				raise NoHomeExposureEnrollment 
			end
		end
	end

end
