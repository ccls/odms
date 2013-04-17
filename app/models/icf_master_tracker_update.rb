#
#	IcfMasterTracker files come from ICF
#
class IcfMasterTrackerUpdate < CSVFile

	attr_accessor :icf_master_trackers

	def initialize(csv_file,options={})
		super
		self.icf_master_trackers = []
		self.parse_csv_file unless self.options[:no_parse]
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

	def archive_dir 
		"ICF_Master_Trackers"
	end

	def mod_time 
		File.mtime(csv_file).strftime("%Y%m%d")
	end

	def parse_csv_file
		FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
		if File.exists?("#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")
			Notification.plain(
				"ICF Master Tracker has the same modification time as a previously" <<
					" processed file. (#{mod_time})  Skipping.",
				email_options.merge({
					:subject => "ODMS: Duplicate ICF Master Tracker" })
			).deliver


#	"abort" causes problems in testing. Try to avoid.
			abort( "File is not new. Mod Time is #{mod_time}. Not doing anything." )

#	perhaps add to status and just return?


		end

		required_column('master_id')
		required_column('cati_complete')

		puts "Processing #{mod_time}..." if verbose
		changed = []
		(f=CSV.open( csv_file, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno} of #{total_lines}" if verbose
			puts line.to_s if verbose
			icf_master_tracker = IcfMasterTracker.new( line.to_hash.merge( :verbose => verbose ))
			self.icf_master_trackers << icf_master_tracker
#			icf_master_tracker.process	#	done in initialize
			changed << icf_master_tracker.changed unless icf_master_tracker.changed.blank?
		end	#	(f=CSV.open( csv_file.path, 'rb',{

		changes = changed.length

		puts "#{changes} #{(changes==1)?'change':'changes'} found." if verbose

		if changes > 0
			puts "ICF Master IDs ..." if verbose
			puts changed.collect(&:icf_master_id).join(', ') if verbose
			#	serves no purpose to commit if didn't change anything
			puts "Commiting Sunspot index." if verbose
			Sunspot.commit
		end

		#
		#	Email is NOT SECURE.  Be careful what is in it.
		#
		Notification.updates_from_icf_master_tracker(changed, 
			email_options.merge({ })).deliver
	end

	def archive
		puts "Archiving ICF Master Tracker file ..." if verbose
		File.rename(csv_file, "#{archive_dir}/ICF_Master_Tracker_#{mod_time}.csv")
	end

end
