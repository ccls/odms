require 'csv'
namespace :automate do

	task :import_screening_data => :environment do

		#	Only send to me in development (add this to ICF also)
		email_options = ( Rails.env == 'development' ) ?
			{ :to => 'jakewendt@berkeley.edu' } : {}


#	TODO
#	I expect the bc_info*.csv files to eventually be in ...
#
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_bc_info/bc_info_*.csv ./bc_infos/")
#	

		local_bc_info_dir = 'bc_infos'





#	TODO
#
#		Here is where problems begin.
#		The first bc_info files had 41 columns.
#		The latest have been simplified and have only 25.
#		Good luck.
#




		expected_columns = %w(icf_master_id mom_is_biomom dad_is_biodad
			date mother_first_name mother_last_name new_mother_first_name
			new_mother_last_name mother_maiden_name new_mother_maiden_name
			father_first_name father_last_name new_father_first_name
			new_father_last_name first_name middle_name last_name
			new_first_name new_middle_name new_last_name dob
			new_dob dob_month new_dob_month dob_day
			new_dob_day dob_year new_dob_year sex
			new_sex birth_country birth_state birth_city
			mother_hispanicity mother_hispanicity_mex mother_race other_mother_race
			father_hispanicity father_hispanicity_mex father_race other_father_race)

		Dir["#{local_bc_info_dir}/bc_info*csv"].each do |bc_info_file|

			puts bc_info_file

			f=CSV.open(bc_info_file,'rb')
			actual_columns = f.readline
			f.close

			if actual_columns.sort != expected_columns.sort
				Notification.plain(
					"BC Info (#{bc_info_file}) has unexpected column names<br/>\n" <<
					"Expected ...<br/>\n#{expected_columns.join(',')}<br/>\n" <<
					"Actual   ...<br/>\n#{actual_columns.join(',')}<br/>\n" <<
					"Diffs    ...<br/>\n#{(expected_columns - actual_columns).join(',')}<br/>\n", 
					email_options.merge({ 
						:subject => "ODMS: Unexpected or missing columns in BC Info" })
				).deliver
				abort( "Unexpected column names in ICF Master Tracker" )
			end	#	if actual_columns.sort != expected_columns.sort




			
			study_subjects = []
			puts "Processing #{bc_info_file}..."
			changed = []
			(f=CSV.open( bc_info_file, 'rb',{
					:headers => true })).each do |line|
				puts
				puts "Processing line :#{f.lineno}:"
				puts line
	
				if line['icf_master_id'].blank?
#	TODO
raise "icf_master_id is blank" 
					puts "icf_master_id is blank" 
					next
				end
				subjects = StudySubject.where(:icf_master_id => line['icf_master_id'])
	
				#	Shouldn't be possible as icf_master_id is unique in the db
				#raise "Multiple case subjects? with icf_master_id:" <<
				#	"#{line['icf_master_id']}:" if subjects.length > 1
				unless subjects.length == 1
#	TODO
raise "No subject with icf_master_id: #{line['icf_master_id']}:" 
					puts "No subject with icf_master_id:#{line['icf_master_id']}:" 
					next
				end
	
				study_subject = subjects.first

				#	"new_" string fields
				#	no parent middle names
				%w( mother_first_name mother_last_name mother_maiden_name
						father_first_name father_last_name sex
						first_name middle_name last_name ).each do |field|
					study_subject.send("#{field}=",
						line["new_#{field}"].to_s.squish.namerize) unless line["new_#{field}"].blank?
				end
					
				#	"new_" non-string fields
				%w( dob ).each do |field|
					study_subject.send("#{field}=", 
						line["new_#{field}"]) unless line["new_#{field}"].blank?
				end
					
				#	namerizable strings
				%w( birth_city ).each do |field|
					study_subject.send("#{field}=",
						line[field].to_s.squish.namerize) unless line[field].blank?
				end

				#	non-namerizable strings, integers and other non-string
				%w( birth_country birth_state 
						mom_is_biomom dad_is_biodad
						other_mother_race other_father_race
						mother_hispanicity mother_hispanicity_mex 
						father_hispanicity father_hispanicity_mex ).each do |field|
#	TODO	will probably need to convert here
					study_subject.send("#{field}=",line[field]) unless line[field].blank?
				end

				#	don't think that birth year is set so use initial
				#	dob year, then try new dob year?
				study_subject.birth_year = line['dob_year'] unless line['dob_year'].blank?
				study_subject.birth_year = line['new_dob_year'] unless line['new_dob_year'].blank?





#	TODO
#			date - what is this? interview date?  which field?

#	TODO	will probably need to convert here
#			mother_race 
#			father_race 






#puts s.changes.inspect
puts "Changes: #{study_subject.changes}"
#=> "Changes: {\"mother_maiden_name\"=>[nil, \"Gonzalez\"], \"father_first_name\"=>[nil, \"Edgar\"], \"father_last_name\"=>[nil, \"Ramirez\"], \"birth_city\"=>[nil, \"Glendale\"], \"birth_country\"=>[nil, \"USA\"], \"birth_state\"=>[nil, \"CA\"], \"mom_is_biomom\"=>[nil, 1], \"other_mother_race\"=>[nil, \"LATINO\"], \"other_father_race\"=>[nil, \"LATINO\"], \"mother_hispanicity\"=>[nil, 1], \"mother_hispanicity_mex\"=>[nil, 2], \"father_hispanicity\"=>[nil, 1], \"father_hispanicity_mex\"=>[nil, 2], \"birth_year\"=>[nil, \"2004\"]}\n"
#irb(main):004:0> s.length
#=> 486

study_subjects.push(study_subject)

StudySubject.transaction do
				if study_subject.save
#	for each or just one big one?  one big one, but beware description is string(255)
#		event_notes is text(>65000)
					study_subject.operational_events.create(
						:occurred_at => DateTime.now,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['datachanged'].id,
						:description => "ICF Screening data changes from #{bc_info_file}",
						:event_notes => "Changes:  #{study_subject.changes}")
					study_subject.operational_events.create(
						:occurred_at => DateTime.now,
						:project_id  => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['screener_complete'].id,
						:description => "ICF screening complete" )
puts "SAVED!"
				else
puts "didn't save"
#	WTF


#	TODO
#					Notification email?
#					OperationalEvent?
#					ODMSException?



				end

raise ActiveRecord::Rollback	#	for developnment
end
	
	
			end	#	(f=CSV.open( bc_info_file, 'rb',{


#	Notification email that bc_info_file has been processed
			Notification.updates_from_bc_info( bc_info_file, study_subjects,
					email_options.merge({ })
				).deliver


		end	#	Dir["#{local_bc_info_dir}/bc_info*csv"].each do |bc_info_file|




#	TODO
#		Sunspot.commit



	end	#	task :import_screening_data => :environment do

end
__END__
