require 'csv'
namespace :automate do

	task :import_screening_data => :environment do
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

		bc_info_files = Dir["#{local_bc_info_dir}/bc_info*csv"]

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
							:subject => "ODMS: Unexpected or missing columns in BC Info" })
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
								:subject => "ODMS: Blank ICF Master ID" })
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
								:subject => "ODMS: No Subject with ICF Master ID" })
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
						:mother_hispanicity     => line['mother_hispanicity'],
						:mother_hispanicity_mex => line['mother_hispanicity_mex'],
						:father_hispanicity     => line['father_hispanicity'],
						:father_hispanicity_mex => line['father_hispanicity_mex'],
						:mom_is_biomom => line['mom_is_biomom'] || line['biomom'],
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
	
					a['mother_hispanicity'] = 999 if a['mother_hispanicity'].to_i == 9
					a['father_hispanicity'] = 999 if a['father_hispanicity'].to_i == 9
					a['mother_hispanicity_mex'] = 999 if a['mother_hispanicity_mex'].to_i == 9
					a['father_hispanicity_mex'] = 999 if a['father_hispanicity_mex'].to_i == 9


#	TODO set subject's hispanicity and hispanicity_mex?
	
	
	#	TODO	these are just to pass validations and should be better fixed
					a['father_hispanicity'] = nil if a['father_hispanicity'].to_i == 0
					a['mother_hispanicity'] = nil if a['mother_hispanicity'].to_i == 0
	
	
					new_attributes.each do |k,v|
						#	NOTE always check if attribute is blank as don't want to delete data
						study_subject.send("#{k}=",v) unless v.blank?
					end
	
	
	#	TODO
	#			date - what is this? interview date?  which field?
	
	#	TODO	will probably need to convert here
	#			mother_race 
	#			father_race 
	
	
	
	
					#	gotta save the changes before the subject, otherwise ... poof
					changes = study_subject.changes
	
	#puts s.changes.inspect
	puts "Changes: #{changes}"
	#=> "Changes: {\"mother_maiden_name\"=>[nil, \"Gonzalez\"], \"father_first_name\"=>[nil, \"Edgar\"], \"father_last_name\"=>[nil, \"Ramirez\"], \"birth_city\"=>[nil, \"Glendale\"], \"birth_country\"=>[nil, \"USA\"], \"birth_state\"=>[nil, \"CA\"], \"mom_is_biomom\"=>[nil, 1], \"other_mother_race\"=>[nil, \"LATINO\"], \"other_father_race\"=>[nil, \"LATINO\"], \"mother_hispanicity\"=>[nil, 1], \"mother_hispanicity_mex\"=>[nil, 2], \"father_hispanicity\"=>[nil, 1], \"father_hispanicity_mex\"=>[nil, 2], \"birth_year\"=>[nil, \"2004\"]}\n"
	#irb(main):004:0> s.length
	#=> 486	#	TOO BIG TO BE A STRING
	
	
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
								:occurred_at => DateTime.now,
								:project_id  => Project['ccls'].id,
								:operational_event_type_id => OperationalEventType['screener_complete'].id,
								:description => "ICF screening complete" )

						else

							puts "Subject #{study_subject.icf_master_id} didn't save?!?!?!"
							Notification.plain(
								"#{bc_info_file} subject save failed?  " <<
								"I'm confused?  Help me.  " <<
								"Subject #{study_subject.icf_master_id}. " <<
								"Error messages ...:#{study_subject.errors.full_messages.to_sentence}:",
								email_options.merge({ 
									:subject => "ODMS: ERROR!  Subject save failed?" })
							).deliver
							puts study_subject.errors.full_messages.to_sentence
							puts study_subject.inspect
							puts study_subject.errors.inspect

						end	#	if study_subject.save
	
					end	#	if study_subject.changed?
	
				end	#	(f=CSV.open( bc_info_file, 'rb',{
	
				Notification.updates_from_bc_info( bc_info_file, study_subjects,
						email_options.merge({ })
					).deliver

				puts; puts "Archiving #{bc_info_file}"
				archive_dir = "#{local_bc_info_dir}/#{Date.today.strftime('%Y%m%d')}"
				FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
				FileUtils.move(bc_info_file,archive_dir)

			end	#	bc_info_files.each do |bc_info_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else
			puts "No bc_info files found"
			Notification.plain("No BC Info Files Found",
				email_options.merge({ 
					:subject => "ODMS: No BC Info Files Found" })
			).deliver
		end	#	unless bc_info_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"
	end	#	task :import_screening_data => :environment do






	#	Only send to me in development (add this to ICF also)
	def email_options 
#		( Rails.env == 'development' ) ?
#				{ :to => 'jakewendt@berkeley.edu' } : {}
		{}
	end

	#	gonna start asserting that everything is as expected.
	#	will slow down import, but I want to make sure I get it right.
	def assert(expression,message = 'Assertion failed.')
		raise "#{message} :\n #{caller[0]}" unless expression
	end

	def assert_string_equal(a,b,field)
		assert a.to_s == b.to_s, "#{field} mismatch:#{a}:#{b}:"
	end

end	#	namespace :automate do

__END__
