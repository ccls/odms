require 'csv'
#
#	IcfMasterTracker files come from ICF
#
class IcfMasterTrackerUpdate

	attr_accessor :csv_file

	def initialize(csv_file)
		self.csv_file = csv_file	#	pointless?
		self.parse_csv_file
	end

	def parse_csv_file
		archive_dir = "ICF_Master_Trackers"
		FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
		mod_time = File.mtime(csv_file).strftime("%Y%m%d")
		if File.exists?("#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")
			Notification.plain(
				"ICF Master Tracker has the same modification time as a previously" <<
					" processed file. (#{mod_time})  Skipping.",
				email_options.merge({
					:subject => "ODMS: Duplicate ICF Master Tracker" })
			).deliver
			abort( "File is not new. Mod Time is #{mod_time}. Not doing anything." )
		end

		f=CSV.open( csv_file,'rb')
		actual_columns = f.readline
		f.close

		unless actual_columns.include?('master_id')
			Notification.plain(
				"ICF Master Tracker missing master_id column. Skipping.\n",
				email_options.merge({
					:subject => "ODMS: ICF Master Tracker missing master_id column" })
			).deliver
			abort( "ICF Master Tracker missing master_id column." )
		end

		unless actual_columns.include?('cati_complete')
			Notification.plain(
				"ICF Master Tracker missing cati_complete column. Skipping.\n",
				email_options.merge({
					:subject => "ODMS: ICF Master Tracker missing cati_complete column" })
			).deliver
			abort( "ICF Master Tracker missing cati_complete column." )
		end

		puts "Processing #{mod_time}..."
		changed = []
		(f=CSV.open( csv_file, 'rb',{ :headers => true })).each do |line|
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
						:occurred_at               => DateTime.current,
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
		File.rename(csv_file, "#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")

		#
		#	Email is NOT SECURE.  Be careful what is in it.
		#
		Notification.updates_from_icf_master_tracker(changed, 
			email_options.merge({ })).deliver

	end

end
