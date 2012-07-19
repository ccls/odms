namespace :app do

	desc "Load some fixtures to database for application"
	task :update => :environment do
#			context_data_sources
		fixtures = %w(
			address_types
			context_contextables
			contexts
			data_sources
			diagnoses
			document_types
			document_versions
			follow_up_types
			hospitals
			ineligible_reasons
			instrument_types
			instrument_versions
			instruments
			interview_methods
			interview_outcomes
			languages
			operational_event_types
			organizations
			people
			phone_types
			project_outcomes
			projects
			races
			refusal_reasons
			roles
			sample_formats
			sample_locations
			sample_outcomes
			sample_temperatures
			sample_types
			sections
			states
			subject_relationships
			subject_types
			tracing_statuses
			units
			vital_statuses 
		)
		ENV['FIXTURES'] = fixtures.join(',')
		puts "Loading fixtures for #{ENV['FIXTURES']}"
		Rake::Task["db:fixtures:load"].invoke
		Rake::Task["db:fixtures:load"].reenable
	end


	task :full_update => [:update,'zip_codes:import_all','counties:import_all']

#	task :full_update => [:update,'zip_codes:import_all','counties:import_all'] do
##	task :full_update => :update do
##
##	We don't use this yet, plus it hasn't changed, so why keep updating it?
##	It takes about 30 minutes.
##
##		#	the zip_codes.csv fixtures is too big and takes too long to
##		#	load in testing, so I left a small one there and put
##		#	the full version from http://www.populardata.com/zipcode_database.html
#
##			pages
##			guides
##			zip_codes
##			counties
#		fixtures = %w(
#		)
##	Do not import icf_master_ids this way in production as these are real
##	icf_master_ids and some may be assigned to real subjects already.
##			icf_master_ids
#
#		ENV['FIXTURES'] = fixtures.join(',')
#		ENV['FIXTURES_PATH'] = 'production/fixtures'
#		puts "Loading production fixtures for #{ENV['FIXTURES']}"
#		Rake::Task["db:fixtures:load"].invoke
#		Rake::Task["db:fixtures:load"].reenable
#	end

#irb(main):009:0* "CHE-GUI".downcase.gsub(/\b('?[a-z])/) { $1.capitalize }
#=> "Che-Gui"
#irb(main):010:0> "CHE-GUI".titleize
#=> "Che Gui"
#irb(main):010:0> "CHE-GUI".namerize
#=> "Che-Gui"
#
#	titleize DOES NOT PRESERVE DASHES

	task :import_and_namerize_study_subject_names => :environment do
		#	This will include controls and mothers (cases too, but no biggy)
		StudySubject.where(:phase => 5).each do |ss|
#		StudySubject.where(:case_control_type => 6).each do |ss|

			puts "Processing #{ss.subject_type} ..."

			unless ss.birth_data.empty?
				bd = ss.birth_data.first
				%w( father_first_name father_middle_name father_last_name ).each do |field|
					puts " Current: #{field}:#{ss.send(field)}:"
					if !bd.send(field).blank?
						ss.send("#{field}=", bd.send(field).namerize)
					end
					puts " Updated: #{field}:#{ss.send(field)}:"
				end
			end

			%w( mother_first_name mother_middle_name mother_maiden_name mother_last_name
				first_name middle_name maiden_name last_name ).each do |field|
				puts " Current: #{field}:#{ss.send(field)}:"
				unless ss.send(field).blank?
					ss.send("#{field}=", ss.send(field).namerize)
				end
				puts " Updated: #{field}:#{ss.send(field)}:"
			end
			if ss.changed?
				puts "#{ss}"
				puts "Changes:#{ss.changes}"
				puts "Update? Y / N / Q"
				response = STDIN.gets
				if response.match(/y/i)
					puts "Saving ..."
					ss.save!
				elsif response.match(/q/i)
					puts "Quiting ..."
					exit
				else
					puts "Skipping ..."
				end
			else
				puts "No changes."
			end
		end
	end

	#	This is more of a synchronize_birth_data_records_with_csv_file_content
	#	as I am no longer explicitly updating the ssn fields.  I'm throwing
	#	the whole line at the record, very similar to creation.
	task :import_parents_ssns_from_csv_file_to_birth_data_records => :environment do
		bdus = BirthDatumUpdate.all
		#	at the time or writing this script, there should be only one BDU
		raise "OMG! Where did all these come from?" if bdus.length > 1
		bdu = bdus.first
		(f=CSV.open( bdu.csv_file.path, 'rb',{
				:headers => true })).each do |line|
			puts
			puts "Processing line :#{f.lineno}:"

			raise "master_id is blank" if line['master_id'].blank?
			raise "case_control_flag is blank" if line['case_control_flag'].blank?
			#	state_registrar_no will be blank for cases

			#	these 3 fields make the request unique enough to always return 1 record. (so far)
			bds = bdu.birth_data
				.where(:case_control_flag  => line['case_control_flag'])
				.where(:state_registrar_no => line['state_registrar_no'])
				.where(:master_id          => line['master_id'])

			#	this shouldn't happen unless another file was uploaded
			raise "no matches" if bds.count < 1
			raise "multiple matches :#{bd.count}:" if bds.count > 1

			bd = bds.first

			puts " Father SSN:#{bd.father_ssn}: Mother SSN:#{bd.mother_ssn}:"
			puts " Father SSN:#{line['father_ssn']}: Mother SSN:#{line['mother_ssn']}:"

##	could have leading zeros so need to use sprintf
#
##			raise "Father SSN:#{bd.father_ssn}: already set!" unless bd.father_ssn.blank?
#			unless line['father_ssn'].blank?
##				raise "Father SSN invalid." if line['father_ssn'].match(/(0000|9999)/)
##raise "Father SSN non-numeric." unless line['father_ssn'] == line['father_ssn'].to_i.to_s
##puts "-- skipping Father SSN non-numeric." unless line['father_ssn'] == sprintf("%09d",line['father_ssn'].to_i)
#				bd.father_ssn = line['father_ssn']
#			end
#
##			raise "Mother SSN:#{bd.mother_ssn}: already set!" unless bd.mother_ssn.blank?
#			unless line['mother_ssn'].blank?
##				raise "Mother SSN invalid." if line['mother_ssn'].match(/(0000|9999)/)
##raise "Mother SSN non-numeric." unless line['mother_ssn'] == line['mother_ssn'].to_i.to_s
##puts "-- skipping Mother SSN non-numeric." unless line['mother_ssn'] == sprintf("%09d",line['mother_ssn'].to_i)
#				bd.mother_ssn = line['mother_ssn']
#			end

birth_datum_attributes = line.dup.to_hash
line.headers.each do |h|
birth_datum_attributes.delete(h) unless BirthDatumUpdate.expected_column_names.include?(h)
end
bd.attributes = birth_datum_attributes

			if bd.changed?
				puts "Changes:#{bd.changes}"
				puts "Update? Y / N / Q"
				response = STDIN.gets
				if response.match(/y/i)
					puts "Saving ..."
					bd.save!
				elsif response.match(/q/i)
					puts "Quiting ..."
					exit
				else
					puts "Skipping ..."
				end
			else
				puts "No changes."
			end
		end

	end

	task :create_addresses_from_birth_data_records => :environment do
		BirthDatum.where('study_subject_id IS NOT NULL').each do |bd|

			puts "Creating address from birth data for :#{bd.id}:"

			response = bd.create_address_from_attributes

			if response.new_record?
				puts "I Don't Think that worked."
				puts response.errors.full_messages.to_sentence
			else
				puts "success"
			end
		end

	end

end
