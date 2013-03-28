namespace :automate do

	task :import_birth_data => :automate do

		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In automate:import_birth_data"

		local_birth_data_dir = 'birth_data'
		FileUtils.mkdir_p(local_birth_data_dir) unless File.exists?(local_birth_data_dir)


#
#	Where are the birth data files?
#	Naming convention?
#

#		puts "About to scp -p birth_data files"
#	S:\CCLS\FieldOperations\ICF\DataTransfers\USC_control_matches\Birth_Certificate_Match_Files
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_birth_data/birth_data_*.csv ./#{local_birth_data_dir}/")
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/USC_control_matches/birth_data_*.csv ./#{local_birth_data_dir}/")
	
#		expected_columns = [
#			%w( masterid biomom biodad date 
#				mother_full_name mother_maiden_name father_full_name 
#				child_full_name child_dobm child_dobd child_doby child_gender 
#				birthplace_country birthplace_state birthplace_city 
#				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
#				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort,
#			%w( masterid biomom biodad date 
#				mother_first mother_last new_mother_first new_mother_last 
#				mother_maiden new_mother_maiden 
#				father_first father_last new_father_first new_father_last 
#				child_first child_middle child_last 
#				new_child_first new_child_middle new_child_last 
#				child_dobfull new_child_dobfull child_dobm new_child_dobm 
#				child_dobd new_child_dobd child_doby new_child_doby 
#				child_gender new_child_gender 
#				birthplace_country birthplace_state birthplace_city 
#				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
#				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort,
#			%w( icf_master_id mom_is_biomom dad_is_biodad
#				date mother_first_name mother_last_name new_mother_first_name
#				new_mother_last_name mother_maiden_name new_mother_maiden_name
#				father_first_name father_last_name new_father_first_name
#				new_father_last_name first_name middle_name last_name
#				new_first_name new_middle_name new_last_name dob
#				new_dob dob_month new_dob_month dob_day
#				new_dob_day dob_year new_dob_year sex
#				new_sex birth_country birth_state birth_city
#				mother_hispanicity mother_hispanicity_mex mother_race other_mother_race
#				father_hispanicity father_hispanicity_mex father_race other_father_race ).sort,
#			%w( icf_master_id mom_is_biomom dad_is_biodad 
#				date mother_first_name mother_last_name new_mother_first_name 
#				new_mother_last_name mother_maiden_name new_mother_maiden_name 
#				father_first_name father_last_name new_father_first_name 
#				new_father_last_name first_name middle_name last_name 
#				new_first_name new_middle_name new_last_name dob 
#				new_dob dob_month new_dob_month dob_day 
#				new_dob_day dob_year new_dob_year sex 
#				new_sex birth_country birth_state birth_city 
#				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
#				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort ]

		Dir.chdir( local_birth_data_dir )
		birth_data_files = Dir["*csv"]

		unless birth_data_files.empty?

			birth_data_files.each do |birth_data_file|
	
				puts "Processing #{birth_data_file}..."

				f=CSV.open(birth_data_file,'rb')
				actual_columns = f.readline
				f.close
				f = CSV.open(birth_data_file,'rb')
				total_lines = f.readlines.size	#	includes header, but so does f.lineno
				f.close
	
#				unless expected_columns.include?(actual_columns.sort)
#					Notification.plain(
#						"Birth Data (#{birth_data_file}) has unexpected column names<br/>\n" <<
#						"Actual   ...<br/>\n#{actual_columns.join(',')}<br/>\n" ,
#						email_options.merge({ 
#							:subject => "ODMS: Unexpected or missing columns in #{birth_data_file}" })
#					).deliver
#				end	#	unless expected_columns.include?(actual_columns.sort)

				study_subjects = []

				(f=CSV.open( birth_data_file, 'rb',{ :headers => true })).each do |line|
					puts
					puts "Processing line :#{f.lineno}/#{total_lines}:"
					puts line

					birth_datum_line = line.to_hash.with_indifferent_access
raise "column count mismatch :#{birth_datum_line.keys.length}:#{actual_columns.length}:" if ( birth_datum_line.keys.length != actual_columns.length )
					birth_datum_line.delete(:ignore1)
					birth_datum_line.delete(:ignore2)
					birth_datum_line.delete(:ignore3)
					birth_datum_line[:birth_data_file_name] = birth_data_file
					birth_datum = BirthDatum.new(birth_datum_line)
					birth_datum.save!

					icf_master_id = line['icf_master_id'] || line['masterid'] || line['master_id']
					if icf_master_id.blank?
						Notification.plain(
							"#{birth_data_file} contained line with blank icf_master_id",
							email_options.merge({ 
								:subject => "ODMS: Blank ICF Master ID in #{birth_data_file}" })
						).deliver
						puts "icf_master_id is blank" 
						next
					end
					subjects = StudySubject.where(:icf_master_id => icf_master_id)
		
					#	Shouldn't be possible as icf_master_id is unique in the db
					#raise "Multiple case subjects? with icf_master_id:" <<
					#	"#{line['icf_master_id']}:" if subjects.length > 1
					unless subjects.length == 1
						Notification.plain(
							"#{birth_data_file} contained line with icf_master_id" <<
							"but no subject with icf_master_id:#{icf_master_id}:",
							email_options.merge({ 
								:subject => "ODMS: No Subject with ICF Master ID in #{birth_data_file}" })
						).deliver
						puts "No subject with icf_master_id:#{icf_master_id}:" 
						next
					end
					study_subject = subjects.first

					study_subjects.push(study_subject)


					#	as we appear to be keeping the BirthDatum model
					#	we shouldn't have to do anything else as the BirthDatum
					#	model has callbacks for doing post processing


					#	TODO should birth_data be edittable?
					#	TODO should the callbacks be moved to rake task?
					#		don't think so. being there allows for testing

					#	TODO then what about sending emails?


				end	#	(f=CSV.open( birth_data_file, 'rb',{
	
				Notification.updates_from_birth_data( birth_data_file, study_subjects,
						email_options.merge({ })
					).deliver
				puts; puts "Archiving #{birth_data_file}"
				archive_dir = Date.current.strftime('%Y%m%d')
				FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
#				FileUtils.move(birth_data_file,archive_dir)

			end	#	birth_data_files.each do |birth_data_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless birth_data_files.empty?
			puts "No birth_data files found"
			Notification.plain("No Birth Data Files Found",
				email_options.merge({ 
					:subject => "ODMS: No Birth Data Files Found" })
			).deliver
		end	#	unless birth_data_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :import_birth_data => :automate do

end	#	namespace :automate do

__END__
