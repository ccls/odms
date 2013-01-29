require 'csv'
namespace :automate do

#	desc "Read CSV file and set Subject's CCLS enrollment#interview_completed_on"
#
	task :updates_from_icf_master_tracker => :environment do

		# Only send to me in development (add this to ICF also)
		def email_options
			( Rails.env == 'development' ) ?
				{ :to => 'jakewendt@berkeley.edu' } : {}
		end


		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In automate:update_from_icf_master_tracker"
		at_exit{		
			if File.exists?("ICF_Master_Tracker.csv")
				puts "Removing ICF Master Tracker"
				File.delete("ICF_Master_Tracker.csv")
			end
			puts "Done.(#{Time.now})"
			puts "----------------------------------------------------------------------"
		}

		puts "About to scp -p Icf master tracker"
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Volumes/BUF-Fileshare/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_master_trackers/ICF_Master_Tracker.csv ./")
		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_master_trackers/ICF_Master_Tracker.csv ./")
		unless File.exists?("ICF_Master_Tracker.csv")
			Notification.plain(
				"ICF Master Tracker not found after copy attempted. Skipping.",
				email_options.merge({
					:subject => "ODMS: Failed ICF Master Tracker copy" })
			).deliver
			abort( "scp seems to have failed as csv file is not found." )
		end


		archive_dir = "ICF_Master_Trackers"
		FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
		mod_time = File.mtime("ICF_Master_Tracker.csv").strftime("%Y%m%d")
		if File.exists?("#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")
			Notification.plain(
				"ICF Master Tracker has the same modification time as a previously" <<
					" processed file. (#{mod_time})  Skipping.",
				email_options.merge({
					:subject => "ODMS: Duplicate ICF Master Tracker" })
			).deliver
			abort( "File is not new. Mod Time is #{mod_time}. Not doing anything." )
		end


		f=CSV.open("ICF_Master_Tracker.csv",'rb')
		actual_columns = f.readline
		f.close
		expected_columns = %w(master_id case_master_id control_number date_control_released master_id_mother language record_owner record_status record_status_date date_received last_attempt last_disposition curr_phone record_sent_for_matching record_received_from_matching sent_pre_incentive released_to_cati confirmed_cati_contact refused deceased_notification screened ineligible_reason confirmation_packet_sent cati_protocol_exhausted new_phone_released_to_cati plea_notification_sent case_returned_for_new_info case_returned_from_berkeley cati_complete kit_mother_sent kit_infant_sent kit_child_sent kid_adolescent_sent kit_mother_refused_code kit_child_refused_code no_response_to_plea response_received_from_plea sent_to_in_person_followup kit_mother_received kit_child_received thank_you_sent physician_request_sent physician_response_received vaccine_auth_received recollect)

		if actual_columns.sort != expected_columns.sort
			Notification.plain(
				"ICF Master Tracker has unexpected column names. Skipping.<br/>\n" <<
					"Expected ...<br/>\n#{expected_columns.join(',')}<br/>\n" <<
					"Actual   ...<br/>\n#{actual_columns.join(',')}<br/>\n" <<
					"Diffs(E-A)...<br/>\n#{(expected_columns - actual_columns).join(',')}<br/>\n"<<
					"Diffs(A-E)...<br/>\n#{(actual_columns - expected_columns).join(',')}<br/>\n", 
#
#	Note that the comparison above is a "one-way diff"
#		a-b != b-a
#
				email_options.merge({
					:subject => "ODMS: Unexpected or missing columns in ICF Master Tracker" })
			).deliver
			abort( "Unexpected column names in ICF Master Tracker" )
		end


		puts "Processing #{mod_time}..."
		changed = []
		(f=CSV.open( "ICF_Master_Tracker.csv", 'rb',{
				:headers => true })).each do |line|
			puts
			puts "Processing line :#{f.lineno}:"
			puts line


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
		Notification.updates_from_icf_master_tracker(changed, 
			email_options.merge({ })).deliver

	end #	task :update_from_icf_master_tracker => :environment do

end
