require 'ostruct'
#
#	Non-ActiveRecord class created primarily for adding testability to rake task.
#
class IcfMasterTracker < OpenStruct

	def initialize(*args)
		super
		self.changed = nil	#[]
#
#	perhaps add study_subject
#		and use changes hash instead of changed?
#
		self.verbose ||= false
		process
	end

	def process
		if master_id.blank?
			self.status = "master_id is blank" 
			puts "master_id is blank" if verbose
			return #			next
		end
		subjects = StudySubject.where(:icf_master_id => master_id)

		#	Shouldn't be possible as icf_master_id is unique in the db
		#raise "Multiple case subjects? with icf_master_id:" <<
		#	"#{master_id}:" if subjects.length > 1
		unless subjects.length == 1
			self.status = "No subject with icf_master_id: #{master_id}:" 
			puts "No subject with icf_master_id:#{master_id}:" if verbose
			return 	#	next
		end

		s = subjects.first
		e = s.enrollments.where(:project_id => Project['ccls'].id).first

		if cati_complete.blank?
			self.status = "cati_complete is blank so doing nothing."
			puts "cati_complete is blank so doing nothing." if verbose
		else
			puts "cati_complete: #{Time.parse(cati_complete).to_date}" if verbose
			puts "Current interview_completed_on : #{e.interview_completed_on}" if verbose
			e.interview_completed_on = Time.parse(cati_complete).to_date
			if e.changed?
#				changed << s
				changed = s
				puts "-- Updated interview_completed_on : #{e.interview_completed_on}" if verbose
				puts "-- Enrollment updated. Creating OE" if verbose

				e.save!
				s.operational_events.create!(
					:project_id                => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['other'].id,
					:occurred_at               => DateTime.current,
					:description               => "interview_completed_on set to " <<
						"cati_complete #{cati_complete} from " <<
						"ICF Master Tracker file #{mod_time}"
				)
				self.status = "interview_completed_on set to: #{e.interview_completed_on}"
			else
				puts "No change so doing nothing." if verbose
				self.status = "No change so doing nothing."
			end
		end	#	if cati_complete.blank?
	end

end
__END__
