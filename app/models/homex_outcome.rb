# don't know exactly
class HomexOutcome < ActiveRecord::Base

#	NOTE this is not used

	acts_as_list

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject

	VALID_INTERVIEW_OUTCOMES = ["complete", 
		"interview is incomplete", "interview has been scheduled", "pending"]

	VALID_SAMPLE_OUTCOMES = ["complete", 
		"to lab", "sample received", "kit sent", "pending"]

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the vital status.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def interview_outcomes
		([self.interview_outcome] + VALID_INTERVIEW_OUTCOMES ).compact.uniq
	end
	def sample_outcomes
		([self.sample_outcome] + VALID_SAMPLE_OUTCOMES ).compact.uniq
	end

	validations_from_yaml_file

	before_save :create_interview_outcome_update,
		:if => :interview_outcome_changed?

	before_save :create_sample_outcome_update,
		:if => :sample_outcome_changed?

	class NoHomeExposureEnrollment < StandardError	#	:nodoc:
	end

protected

	#	Create OperationalEvent regarding the interview outcome
	def create_interview_outcome_update
		operational_event_type = case interview_outcome 
			when 'interview has been scheduled'
				OperationalEventType['scheduled']
			when 'complete'
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
			when 'kit sent'
				OperationalEventType['kit_sent']
			when 'sample received'
				OperationalEventType['sample_received']
			when 'complete'
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
