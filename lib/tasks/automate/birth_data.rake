namespace :automate do

	task :reprocess_birth_data => :automate do
		puts "Study Subject count: #{StudySubject.count}"
#		birth_data = BirthDatum.where(:match_confidence => 'NO').where(:study_subject_id => nil)
		birth_data = BirthDatum.where(:study_subject_id => nil)
			.where(BirthDatum.arel_table[:match_confidence].eq_any(['NO','DEFINITE']))
		birth_data.each{|bd| 
			puts "Processing #{bd}"
			bd.post_processing; bd.reload }
		puts "Study Subject count: #{StudySubject.count}"

		puts; puts "Commiting changes to Sunspot"
		Sunspot.commit

		Notification.updates_from_birth_data( 'fake file', birth_data ).deliver

		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :reprocess_birth_data => :automate do

	task :update_file_nos => :automate do
		csv_file = "Ca_Co_6_Digit_State_Local.csv"
		raise "CSV File :#{csv_file}: not found" unless File.exists?(csv_file)
		not_found = []
		CSV.open(csv_file,'rb:bom|utf-8', { :headers => true }).each do |line|
			#	master_id,match_confidence,case_control_flag,state_registrar_no,derived_state_file_no_last6,control_number,
			#	dob,last_name,first_name,middle_name,local_registrar_no,derived_local_file_no_last6
			#
			#	If created an actual birth datum record for a control, it would create a control. 
			#	These controls have already been created.
			#	So.  Create one WITHOUT a master_id, which will stop the post_processing.
			#	Basically, create a blank one.
			#	Manually find by state_registrar_no?  and attach study subject
			#	add derived_local_file_no_last6 and derived_state_file_no_last6
			#
			puts line['state_registrar_no']
			next if line['state_registrar_no'].blank?

			birth_data = BirthDatum.where(:state_registrar_no => line['state_registrar_no'] )
			if birth_data.length == 0
				puts "Found #{birth_data.length} subjects matching" 
				not_found.push line
				next
			end

			birth_data.each do |birth_datum| 
				derived_state_file_no_last6 = sprintf("%06d",line['derived_state_file_no_last6'].to_i)
				birth_datum.update_column(:derived_state_file_no_last6, derived_state_file_no_last6)

				derived_local_file_no_last6 = sprintf("%06d",line['derived_local_file_no_last6'].to_i)
				birth_datum.update_column(:derived_local_file_no_last6, derived_local_file_no_last6)

				if birth_datum.study_subject

					birth_datum.study_subject.update_column(:needs_reindexed, true)

					birth_datum.study_subject.operational_events.create(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
						:description => "Birth Record data changes from #{csv_file}",
						:notes => "Added derived_state_file_no_last6 #{derived_state_file_no_last6} and "<<
							"derived_local_file_no_last6 #{derived_local_file_no_last6} to birth data records.")

				end
			end
		end
		puts "#{not_found.length} state registrar nos not found."
		puts not_found
	end

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
		birth_data_files = Dir["*.csv"]

		unless birth_data_files.empty?

			birth_data_files.each do |birth_data_file|

				bdu = BirthDatumUpdate.new(birth_data_file,:verbose => true)
				bdu.archive

			end	#	birth_data_files.each do |birth_data_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless birth_data_files.empty?
			puts "No birth_data files found"
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
