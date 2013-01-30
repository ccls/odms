require 'csv'
namespace :automate do

	task :import_screening_data => :environment do

		#	Only send to me in development (add this to ICF also)
		def email_options 
			( Rails.env == 'development' ) ?
					{ :to => 'jakewendt@berkeley.edu' } : {}
		end
	
		#	gonna start asserting that everything is as expected.
		#	will slow down import, but I want to make sure I get it right.
		def assert(expression,message = 'Assertion failed.')
			raise "#{message} :\n #{caller[0]}" unless expression
		end
	
		def assert_string_equal(a,b,field)
			assert a.to_s == b.to_s, "#{field} mismatch:#{a}:#{b}:"
		end

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
	
					icf_master_id = line['icf_master_id'] || line['masterid']
		
					if icf_master_id.blank?
						Notification.plain(
							"#{bc_info_file} contained line with blank icf_master_id",
							email_options.merge({ 
								:subject => "ODMS: Blank ICF Master ID in #{bc_info_file}" })
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
							"#{bc_info_file} contained line with icf_master_id" <<
							"but no subject with icf_master_id:#{icf_master_id}:",
							email_options.merge({ 
								:subject => "ODMS: No Subject with ICF Master ID in #{bc_info_file}" })
						).deliver
						puts "No subject with icf_master_id:#{icf_master_id}:" 
						next
					end
		
					study_subject = subjects.first
	
					#	using "a" as a synonym for "new_attributes" since is a Hash (pointer)
					a = new_attributes = {
						:mother_first_name  => ( line['new_mother_first_name'] || 
							line['new_mother_first'] ).to_s.squish.namerize,
						:mother_last_name   => ( line['new_mother_last_name'] ||
							line['new_mother_last'] ).to_s.squish.namerize,
						:mother_maiden_name => ( line['new_mother_maiden_name'] ||
							line['new_mother_maiden'] ).to_s.squish.namerize,
						:father_first_name  => ( line['new_father_first_name'] ||
							line['new_father_first'] ).to_s.squish.namerize,
						:father_last_name   => ( line['new_father_last_name'] ||
							line['new_father_last'] ).to_s.squish.namerize,
						:first_name  => ( line['new_first_name'] ||
							line['new_child_first'] ).to_s.squish.namerize,
						:middle_name => ( line['new_middle_name'] ||
							line['new_child_middle'] ).to_s.squish.namerize,
						:last_name   => ( line['new_last_name'] ||
							line['new_child_last'] ).to_s.squish.namerize,
						:birth_city    => line['birth_city'].to_s.squish.namerize,
						:birth_state   => line['birth_state'],
						:birth_country => line['birth_country'],
						:birth_year => line['new_dob_year'] || line['dob_year'] ||
													line['new_child_doby'] || line['child_doby'],
						:mother_hispanicity     => line['mother_hispanicity'].to_s.squish,
						:mother_hispanicity_mex => line['mother_hispanicity_mex'].to_s.squish,
						:father_hispanicity     => line['father_hispanicity'].to_s.squish,
						:father_hispanicity_mex => line['father_hispanicity_mex'].to_s.squish,
						:mom_is_biomom => line['mom_is_biomom'] || line['biomom'],
						:father_race_id => line['father_race'].to_s.squish,
						:mother_race_id => line['mother_race'].to_s.squish,
						:dad_is_biodad => line['dad_is_biodad'] || line['biodad'],
						:other_mother_race => ( line['other_mother_race'] || 
							line['mother_race_other'] ).to_s.squish.namerize,
						:other_father_race => ( line['other_father_race'] || 
							line['father_race_other'] ).to_s.squish.namerize,
						:sex => line['new_sex'] || line['new_child_gender'],
						:dob => line['new_dob'] || line['new_child_dobfull']
					}.with_indifferent_access
	
					if( a[:dob].blank? && 
						!( line['new_child_doby'].blank? || 
							line['new_child_dobm'].blank? || 
							line['new_child_dobd'].blank?) )
						a[:dob] = sprintf( "%4d-%02d-%02d", 
							line['new_child_doby'],line['new_child_dobm'],line['new_child_dobd'] ) 
					end
	
					a[:father_hispanicity] = 888 if a[:father_hispanicity] == '0'
					a[:mother_hispanicity] = 888 if a[:mother_hispanicity] == '0'
					a[:mother_hispanicity] = 999 if a[:mother_hispanicity] == '9'
					a[:father_hispanicity] = 999 if a[:father_hispanicity] == '9'
					a[:mother_hispanicity_mex] = 888 if a[:mother_hispanicity_mex] == '0'
					a[:father_hispanicity_mex] = 888 if a[:father_hispanicity_mex] == '0'
					a[:mother_hispanicity_mex] = 999 if a[:mother_hispanicity_mex] == '9'
					a[:father_hispanicity_mex] = 999 if a[:father_hispanicity_mex] == '9'

					a[:hispanicity] = 999
					if a[:mother_hispanicity] == a[:father_hispanicity]
						a[:hispanicity] = a[:father_hispanicity]
					end
					a[:hispanicity] = 1 if ( 
						[a[:mother_hispanicity],a[:father_hispanicity]].include?('1') )

					a[:hispanicity_mex] = 999
					if a[:mother_hispanicity_mex] == a[:father_hispanicity_mex]
						a[:hispanicity_mex] = a[:father_hispanicity_mex]
					end
					a[:hispanicity_mex] = 1 if ( 
						[a[:mother_hispanicity_mex],a[:father_hispanicity_mex]].include?('1') )

					a[:father_race_id] = 888 if a[:father_race_id] == '0'
					a[:mother_race_id] = 888 if a[:mother_race_id] == '0'
					a[:father_race_id] = 999 if a[:father_race_id] == '9'
					a[:mother_race_id] = 999 if a[:mother_race_id] == '9'

					new_attributes.each do |k,v|
						#	NOTE always check if attribute is blank as don't want to delete data
						study_subject.send("#{k}=",v) unless v.blank?
					end
	
					#	gotta save the changes before the subject, otherwise ... poof
					changes = study_subject.changes
puts changes.inspect
	
					study_subjects.push(study_subject)
	
					if study_subject.changed?

						#	kinda crued, but just want to remember that this was changed in email
						study_subject.instance_variable_set("@bc_info_changed",true) 

						if study_subject.save
		
							if( Rails.env == 'development' )
								new_attributes.each do |k,v|
									next if %w(dob).include?(k)
									unless v.blank?
										#	puts "comparing #{k}"
										#	puts "#{study_subject.send(k)}:#{v}"
										assert_string_equal( study_subject.send(k), v, k) 
									end
								end
								assert_string_equal( study_subject.dob, 
									new_attributes['dob'].to_date, 'dob'
									) unless new_attributes['dob'].blank?
							end
		
							study_subject.operational_events.create(
								:occurred_at => DateTime.now,
								:project_id => Project['ccls'].id,
								:operational_event_type_id => OperationalEventType['datachanged'].id,
								:description => "ICF Screening data changes from #{bc_info_file}",
								:event_notes => "Changes:  #{changes}")

							study_subject.operational_events.create(
								:occurred_at => line['date'] || DateTime.now,
								:project_id  => Project['ccls'].id,
								:operational_event_type_id => OperationalEventType['screener_complete'].id,
								:description => "ICF screening complete from #{bc_info_file}" ) if (
									study_subject.operational_events.where(:operational_event_type_id => OperationalEventType['screener_complete'].id).where(:project_id => Project[:ccls].id).empty? )

						else

							puts "Subject #{study_subject.icf_master_id} didn't save?!?!?!"
							Notification.plain(
								"#{bc_info_file} subject save failed?  " <<
								"I'm confused?  Help me.  " <<
								"Subject #{study_subject.icf_master_id}. " <<
								"Error messages ...:#{study_subject.errors.full_messages.to_sentence}:",
								email_options.merge({ 
									:subject => "ODMS: ERROR!  Subject save failed?  in #{bc_info_file}" })
							).deliver
							puts study_subject.errors.full_messages.to_sentence
							puts study_subject.inspect
							puts study_subject.errors.inspect

						end	#	if study_subject.save
	
					end	#	if study_subject.changed?

					#	ReadOnlyRecord due to joins so need to re-find.
					mother = StudySubject.find(study_subject.mother.id)
					mother.hispanicity = study_subject.mother_hispanicity unless study_subject.mother_hispanicity.blank?
					mother.hispanicity_mex = study_subject.mother_hispanicity_mex unless study_subject.mother_hispanicity_mex.blank?
					mother.first_name  = study_subject.mother_first_name unless study_subject.mother_first_name.blank?
					mother.last_name   = study_subject.mother_last_name unless study_subject.mother_last_name.blank?
					mother.maiden_name = study_subject.mother_maiden_name unless study_subject.mother_maiden_name.blank?

					puts "Mother changes"
					changes = mother.changes
					puts changes
					mother.save

					mother.operational_events.create(
						:occurred_at => DateTime.now,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['datachanged'].id,
						:description => "ICF Screening data changes from #{bc_info_file}",
						:event_notes => "Changes:  #{changes}")

					if study_subject.mother_race_id
						mr = Race.where(:id => study_subject.mother_race_id).first
						if mr.nil?
							Notification.plain("No race found with id :#{study_subject.mother_race_id}:",
								email_options.merge({ 
									:subject => "ODMS: Invalid mother_race_id" })
							).deliver
						elsif mr.is_other? or mr.is_mixed?
							msr = if mother.races.include?( mr )
								mother.subject_races.where(:race_id => mr.id).first
							else
								mother.subject_races.new(:race_id => mr.id)
							end

							new_other_race = study_subject.other_mother_race || "UNSPECIFIED IN BC_INFO"
							msr.other_race = if msr.other_race.blank?
								new_other_race
							elsif msr.other_race.include?(new_other_race)
								msr.other_race
							else
								"#{msr.other_race}, #{new_other_race}"
							end
							msr.save
						else
							mother.races << mr unless mother.races.include?( mr )
						end	#	if mr.nil? (mr is not nil or other or mixed)
					end	#	if study_subject.mother_race_id
	
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
