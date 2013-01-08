require 'csv'
namespace :automate do

#	desc "Read CSV file and set Subject's CCLS enrollment#interview_completed_on"
#
	task :updates_from_icf_master_tracker => :environment do
		puts;puts;puts
		puts "In automate:update_from_icf_master_tracker"

		puts "About to scp -p Icf master tracker"

		system("scp -p jakewendt@dev.sph.berkeley.edu:/Volumes/BUF-Fileshare/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_master_trackers/ICF_Master_Tracker.csv ./")

		unless File.exists?("ICF_Master_Tracker.csv")

			puts "scp seems to have failed as csv file is not found."
			Notification.plain(
				"ICF Master Tracker not found after copy attempted." <<
				" Skipping.",{
					:subject => "Failed ICF Master Tracker copy" }
			).deliver

			exit
		end

		archive_dir = "ICF_Master_Trackers"
		FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
		mod_time = File.mtime("ICF_Master_Tracker.csv").strftime("%Y%m%d")
		if File.exists?("#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")
			puts "File is not new.  Not doing anything."
			Notification.plain(
				"ICF Master Tracker has the same modification time as a previously" <<
				" processed file.  Skipping.",{
					:subject => "Duplicate ICF Master Tracker" }
			).deliver
		else
			puts "Processing ..."

			changed = []


#
#	TODO Insert a check to ensure that the file has the expected columns
#


			(f=CSV.open( "ICF_Master_Tracker.csv", 'rb',{
					:headers => true })).each do |line|
				puts
				puts "Processing line :#{f.lineno}:"
				puts line

	#	master_id,master_id_mother,language,record_owner,record_status,record_status_date,date_received,last_attempt,last_disposition,curr_phone,record_sent_for_matching,record_received_from_matching,sent_pre_incentive,released_to_cati,confirmed_cati_contact,refused,deceased_notification,is_eligible,ineligible_reason,confirmation_packet_sent,cati_protocol_exhausted,new_phone_released_to_cati,plea_notification_sent,case_returned_for_new_info,case_returned_from_berkeley,cati_complete,kit_mother_sent,kit_infant_sent,kit_child_sent,kid_adolescent_sent,kit_mother_refused_code,kit_child_refused_code,no_response_to_plea,response_received_from_plea,sent_to_in_person_followup,kit_mother_received,kit_child_received,thank_you_sent,physician_request_sent,physician_response_received,vaccine_auth_received,recollect

				if line['master_id'].blank?
					#	raise "master_id is blank" 
					puts "master_id is blank" 
					next
				end
				subjects = StudySubject.where(:icf_master_id => line['master_id'])

				#	Shouldn't be possible as icf_master_id is unique in the db
				#raise "Multiple case subjects? with icf_master_id:" <<
				#	"#{line['master_id']}:" if subjects.length > 1
				unless subjects.length == 1
					#raise "No subject with icf_master_id: #{line['master_id']}:" 
					puts "No subject with icf_master_id:#{line['master_id']}:" 
					next
				end

				s = subjects.first
				e = s.enrollments.where(:project_id => Project['ccls'].id).first

				if line['cati_complete'].blank?
					puts "cati_complete is blank so doing nothing."
				else
					puts "cati_complete: #{Time.parse(line['cati_complete']).to_date}"
					puts "Current interview_completed_on : #{e.interview_completed_on}"
					e.interview_completed_on = Time.parse(line['cati_complete']).to_date
					if e.changed?
						changed << s
						puts "-- Updated interview_completed_on : #{e.interview_completed_on}"
						puts "-- Enrollment updated. Creating OE"

						e.save!
						s.operational_events.create!(
							:project_id                => Project['ccls'].id,
							:operational_event_type_id => OperationalEventType['other'].id,
							:occurred_at               => DateTime.now,
							:description               => "interview_completed_on set to " <<
								"cati_complete #{line['cati_complete']} from " <<
								"ICF Master Tracker file #{mod_time}"
						)

					else
						puts "No change so doing nothing."
					end
				end	#	if line['cati_complete'].blank?
			end	#	(f=CSV.open( csv_file.path, 'rb',{

			changes = changed.length
			puts
			puts "#{changes} #{(changes==1)?'change':'changes'} found."

			if changes > 0
				puts "ICF Master IDs ..."
				puts changed.collect(&:icf_master_id).join(', ')
				#	serves no purpose to commit if didn't change anything
				puts "Commiting Sunspot index."
				Sunspot.commit
			end

			puts "Archiving ICF Master Tracker file ..."
			File.rename("ICF_Master_Tracker.csv",
				"#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")

			#
			#	Email is NOT SECURE.  Be careful what is in it.
			#
			Notification.updates_from_icf_master_tracker(changed).deliver
			puts "----------------------------------------------------------------------"
		end

	end #	task :update_from_icf_master_tracker => :environment do

end
