#
#	Non-ActiveRecord class created primarily for adding testability to rake task.
#
class IcfMasterTracker < OpenStruct

	attr_accessor :changed

	def initialize(*args)
		super
		process
	end

	def process
		if master_id.blank?
			#	raise "master_id is blank" 
			log << "master_id is blank" 
			return #			next
		end
		subjects = StudySubject.where(:icf_master_id => master_id)

		#	Shouldn't be possible as icf_master_id is unique in the db
		#raise "Multiple case subjects? with icf_master_id:" <<
		#	"#{master_id}:" if subjects.length > 1
		unless subjects.length == 1
			#raise "No subject with icf_master_id: #{master_id}:" 
			log << "No subject with icf_master_id:#{master_id}:" 
			return 	#	next
		end

		s = subjects.first
		e = s.enrollments.where(:project_id => Project['ccls'].id).first

		if cati_complete.blank?
			log << "cati_complete is blank so doing nothing."
		else
			log << "cati_complete: #{Time.parse(cati_complete).to_date}"
			log << "Current interview_completed_on : #{e.interview_completed_on}"
			e.interview_completed_on = Time.parse(cati_complete).to_date
			if e.changed?
				self.changed << s
				log << "-- Updated interview_completed_on : #{e.interview_completed_on}"
				log << "-- Enrollment updated. Creating OE"

				e.save!
				s.operational_events.create!(
					:project_id                => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['other'].id,
					:occurred_at               => DateTime.current,
					:description               => "interview_completed_on set to " <<
						"cati_complete #{cati_complete} from " <<
						"ICF Master Tracker file #{mod_time}"
				)
			else
				log << "No change so doing nothing."
			end
		end	#	if cati_complete.blank?
	end

end
__END__
