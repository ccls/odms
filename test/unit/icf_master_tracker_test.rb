require 'test_helper'

class IcfMasterTrackerTest < ActiveSupport::TestCase

#		(f=CSV.open( "ICF_Master_Tracker.csv", 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
#			if line['master_id'].blank?
#				#	raise "master_id is blank" 
#				puts "master_id is blank" 
#				next
#			end
#			subjects = StudySubject.where(:icf_master_id => line['master_id'])
#
#			#	Shouldn't be possible as icf_master_id is unique in the db
#			#raise "Multiple case subjects? with icf_master_id:" <<
#			#	"#{line['master_id']}:" if subjects.length > 1
#			unless subjects.length == 1
#				#raise "No subject with icf_master_id: #{line['master_id']}:" 
#				puts "No subject with icf_master_id:#{line['master_id']}:" 
#				next
#			end
#
#			s = subjects.first
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#
#			if line['cati_complete'].blank?
#				puts "cati_complete is blank so doing nothing."
#			else
#				puts "cati_complete: #{Time.parse(line['cati_complete']).to_date}"
#				puts "Current interview_completed_on : #{e.interview_completed_on}"
#				e.interview_completed_on = Time.parse(line['cati_complete']).to_date
#				if e.changed?
#					changed << s
#					puts "-- Updated interview_completed_on : #{e.interview_completed_on}"
#					puts "-- Enrollment updated. Creating OE"
#
#					e.save!
#					s.operational_events.create!(
#						:project_id                => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['other'].id,
#						:occurred_at               => DateTime.current,
#						:description               => "interview_completed_on set to " <<
#							"cati_complete #{line['cati_complete']} from " <<
#							"ICF Master Tracker file #{mod_time}"
#					)
#
#				else
#					puts "No change so doing nothing."
#				end
#			end	#	if line['cati_complete'].blank?
#		end	#	(f=CSV.open( csv_file.path, 'rb',{


end
__END__
