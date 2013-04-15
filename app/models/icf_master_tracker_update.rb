require 'csv'
#
#	IcfMasterTracker files come from ICF
#
class IcfMasterTrackerUpdate

	attr_accessor :csv_file
	attr_accessor :log

	def initialize(csv_file)
		self.csv_file = csv_file	#	pointless?
		self.log = []
		self.parse_csv_file
	end

	def required_column(column)
		unless actual_columns.include?(column)
			Notification.plain(
				"ICF Master Tracker missing #{column} column. Skipping.\n",
				email_options.merge({
					:subject => "ODMS: ICF Master Tracker missing #{column} column" })
			).deliver
			abort( "ICF Master Tracker missing #{column} column." )
		end
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

		required_column('master_id')
		required_column('cati_complete')

		log << "Processing #{mod_time}..."
		changed = []
		(f=CSV.open( csv_file, 'rb',{ :headers => true })).each do |line|
			log << "Processing line :#{f.lineno}:"
			log << line.to_s
			icf_master_tracker = IcfMasterTracker.new( line.to_hash.merge( :log => log ))
			changed << icf_master_tracker.changed unless icf_master_tracker.changed.blank?
		end	#	(f=CSV.open( csv_file.path, 'rb',{

		changes = changed.length

		log << "#{changes} #{(changes==1)?'change':'changes'} found."

		if changes > 0
			log << "ICF Master IDs ..."
			log << changed.collect(&:icf_master_id).join(', ')
			#	serves no purpose to commit if didn't change anything
			log << "Commiting Sunspot index."
			Sunspot.commit
		end

		log << "Archiving ICF Master Tracker file ..."
		File.rename(csv_file, "#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")

		#
		#	Email is NOT SECURE.  Be careful what is in it.
		#
		Notification.updates_from_icf_master_tracker(changed, 
			email_options.merge({ })).deliver
	end

end
