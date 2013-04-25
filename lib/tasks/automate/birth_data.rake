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
	
		Dir.chdir( local_birth_data_dir )
		birth_data_files = Dir["*csv"]

		unless birth_data_files.empty?

			birth_data_files.each do |birth_data_file|

				bdu = BirthDatumUpdate.new(birth_data_file,:verbose => true)
				bdu.archive

			end	#	birth_data_files.each do |birth_data_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless birth_data_files.empty?
			puts "No birth_data files found"
#			Notification.plain("No Birth Data Files Found",
#				email_options.merge({ 
#					:subject => "ODMS: No Birth Data Files Found" })
#			).deliver
			Notification.plain("No Birth Data Files Found",
					:subject => "ODMS: No Birth Data Files Found"
			).deliver
		end	#	unless birth_data_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :import_birth_data => :automate do

	task :import_birth_data_files => :import_birth_data
	task :import_birth_data_update_files => :import_birth_data
	task :import_birth_datum_files => :import_birth_data
	task :import_birth_datum_update_files => :import_birth_data

end	#	namespace :automate do

__END__
