namespace :automate do

	task :export_mother_maiden_names => :automate do
		local_bc_info_dir = 'bc_infos'
		FileUtils.mkdir_p(local_bc_info_dir) unless File.exists?(local_bc_info_dir)
		Dir.chdir( local_bc_info_dir )
		bc_info_files = Dir["bc_info*csv"]

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
	
		expected_columns = [
			%w( masterid biomom biodad date 
				mother_full_name mother_maiden_name father_full_name 
				child_full_name child_dobm child_dobd child_doby child_gender 
				birthplace_country birthplace_state birthplace_city 
				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort,
			%w( masterid biomom biodad date 
				mother_first mother_last new_mother_first new_mother_last 
				mother_maiden new_mother_maiden 
				father_first father_last new_father_first new_father_last 
				child_first child_middle child_last 
				new_child_first new_child_middle new_child_last 
				child_dobfull new_child_dobfull child_dobm new_child_dobm 
				child_dobd new_child_dobd child_doby new_child_doby 
				child_gender new_child_gender 
				birthplace_country birthplace_state birthplace_city 
				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort,
			%w( icf_master_id mom_is_biomom dad_is_biodad
				date mother_first_name mother_last_name new_mother_first_name
				new_mother_last_name mother_maiden_name new_mother_maiden_name
				father_first_name father_last_name new_father_first_name
				new_father_last_name first_name middle_name last_name
				new_first_name new_middle_name new_last_name dob
				new_dob dob_month new_dob_month dob_day
				new_dob_day dob_year new_dob_year sex
				new_sex birth_country birth_state birth_city
				mother_hispanicity mother_hispanicity_mex mother_race other_mother_race
				father_hispanicity father_hispanicity_mex father_race other_father_race ).sort,
			%w( icf_master_id mom_is_biomom dad_is_biodad 
				date mother_first_name mother_last_name new_mother_first_name 
				new_mother_last_name mother_maiden_name new_mother_maiden_name 
				father_first_name father_last_name new_father_first_name 
				new_father_last_name first_name middle_name last_name 
				new_first_name new_middle_name new_last_name dob 
				new_dob dob_month new_dob_month dob_day 
				new_dob_day dob_year new_dob_year sex 
				new_sex birth_country birth_state birth_city 
				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort]

		Dir.chdir( local_bc_info_dir )
		bc_info_files = Dir["bc_info*csv"]

		unless bc_info_files.empty?

			bc_info_files.each do |bc_info_file|
	
				puts bc_info_file
	
				f=CSV.open(bc_info_file,'rb')
				actual_columns = f.readline
				f.close
	
				unless expected_columns.include?(actual_columns.sort)
					Notification.plain(
						"BC Info (#{bc_info_file}) has unexpected column names<br/>\n" <<
						"Actual   ...<br/>\n#{actual_columns.join(',')}<br/>\n" ,
						email_options.merge({ 
							:subject => "ODMS: Unexpected or missing columns in #{bc_info_file}" })
					).deliver
				end	#	unless expected_columns.include?(actual_columns.sort)
	
				study_subjects = []
				puts "Processing #{bc_info_file}..."

				(f=CSV.open( bc_info_file, 'rb',{ :headers => true })).each do |line|
					puts
					puts "Processing line :#{f.lineno}:"
					puts line

					bc_info = BcInfo.new(line.to_hash.merge(
						:bc_info_file => bc_info_file ) )
					bc_info.process
					study_subjects.push( bc_info.study_subject )
	
				end	#	(f=CSV.open( bc_info_file, 'rb',{
	
				Notification.updates_from_bc_info( bc_info_file, study_subjects,
						email_options.merge({ })
					).deliver
				puts; puts "Archiving #{bc_info_file}"
				archive_dir = Date.today.strftime('%Y%m%d')
				FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
				FileUtils.move(bc_info_file,archive_dir)

			end	#	bc_info_files.each do |bc_info_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless bc_info_files.empty?
			puts "No bc_info files found"
			Notification.plain("No BC Info Files Found",
				email_options.merge({ 
					:subject => "ODMS: No BC Info Files Found" })
			).deliver
		end	#	unless bc_info_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"
	end	#	task :import_screening_data => :environment do

end	#	namespace :automate do

__END__
