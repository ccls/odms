namespace :automate do

	task :export_mother_maiden_names => :automate do
		local_bc_info_dir = 'bc_infos'
		FileUtils.mkdir_p(local_bc_info_dir) unless File.exists?(local_bc_info_dir)
		Dir.chdir( local_bc_info_dir )
		bc_info_files = Dir["bc_info_*.csv"]

		unless bc_info_files.empty?
			puts ['','masterid','icf_master_id','mother_maiden_name',
				'new_mother_maiden_name','mother_maiden','new_mother_maiden'].to_csv
			bc_info_files.each do |bc_info_file|
				puts [bc_info_file].to_csv
				(f=CSV.open( bc_info_file, 'rb',{ :headers => true })).each do |line|
					row = []
					row << ''
					row << line['masterid']
					row << line['icf_master_id']
					row << line['mother_maiden_name']
					row << line['new_mother_maiden_name']
					row << line['mother_maiden']
					row << line['new_mother_maiden']
					puts row.to_csv
				end

			end

		end

	end

	task :import_screening_data => :automate do

		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In automate:import_screening_data"

		local_bc_info_dir = 'bc_infos'
		FileUtils.mkdir_p(local_bc_info_dir) unless File.exists?(local_bc_info_dir)

		puts "About to scp -p bc_info files"
		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_bc_info/bc_info_*.csv ./#{local_bc_info_dir}/")
	
		Dir.chdir( local_bc_info_dir )
		bc_info_files = Dir["bc_info_*.csv"]

		unless bc_info_files.empty?

			bc_info_files.each do |bc_info_file|
	
				bc_info_update = BcInfoUpdate.new(bc_info_file,:verbose => true)
				bc_info_update.archive

			end	#	bc_info_files.each do |bc_info_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless bc_info_files.empty?
			puts "No bc_info files found"
			Notification.plain("No BC Info Files Found",
					:subject => "ODMS: No BC Info Files Found"
			).deliver
		end	#	unless bc_info_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"
	end	#	task :import_screening_data => :environment do

	task :import_bc_info_files => :import_screening_data

end	#	namespace :automate do

__END__
