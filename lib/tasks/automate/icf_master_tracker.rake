namespace :automate do

#	desc "Read CSV file and set Subject's CCLS enrollment#interview_completed_on"
#
	task :updates_from_icf_master_tracker => :automate do

		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In automate:update_from_icf_master_tracker"
		at_exit{		
			#	if task doesn't complete, destroy the csv file so will run again
			if File.exists?("ICF_Master_Tracker.csv")
				puts "Removing ICF Master Tracker"
				File.delete("ICF_Master_Tracker.csv")
			end
			puts "Done.(#{Time.now})"
			puts "----------------------------------------------------------------------"
		}

		puts "About to scp -p Icf master tracker"
		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_master_trackers/ICF_Master_Tracker.csv ./")
		unless File.exists?("ICF_Master_Tracker.csv")
			Notification.plain(
				"ICF Master Tracker not found after copy attempted. Skipping.",
				email_options.merge({
					:subject => "ODMS: Failed ICF Master Tracker copy" })
			).deliver
			abort( "scp seems to have failed as csv file is not found." )
		end

		icf_master_tracker_update = IcfMasterTrackerUpdate.new("ICF_Master_Tracker.csv")	#	fixed name
		puts icf_master_tracker_update.log

	end #	task :updates_from_icf_master_tracker => :environment do

	task :import_icf_master_tracker => :updates_from_icf_master_tracker
	task :import_icf_master_tracker_file => :updates_from_icf_master_tracker

end
