namespace :app do

	def assert(expression,message = 'Assertion failed.')
		raise "#{message} :\n #{caller[0]}" unless expression
	#puts "AAAAAAAAAAAAAAAA" unless expression
	end

	def assert_string_equal(a,b,field)
		assert a.to_s == b.to_s, "#{field} mismatch:#{a}:#{b}:"
	end

	def assert_string_in(a,b,field)
		assert b.include?(a.to_s), "#{field} value #{a} not included in:#{b}:"
	end



	task :parse_log_for_slow => :environment do
		#	the long contains some binary chars which makes using \s*
		#	nearly impossible?
		File.open('log/test.log','r').each do |line|
			#	skip as many as possible
			next if line.blank?
			next if line.match(/Connecting to database specified by database.yml/)
			next if line.match(/Migrating to /)
			next if line.match(/INSERT INTO `schema_migrations/)
			next if line.match(/CREATE DATABASE/)
			next if line.match(/CREATE TABLE/)
			next if line.match(/CREATE INDEX/)
			next if line.match(/CREATE UNIQUE INDEX/)
			next if line.match(/CACHE\s*\(/)
#			puts line unless line.match(/^\s*\S+\s+\S+\s+\((.*)ms\)/)
			if line.match(/\(([\d\.]+)ms\)/)
				ms=$1.to_f
				puts line if ms > 500
			end
		end
	end

#
#	I don't think that we'll be importing from fixtures anymore.
#	Any new stuff would probably be added directly. (20121219)
#
#	Some things have changed that would make loading these
#	fixtures in production a very bad idea.  Don't do it.
#
#	desc "Load some fixtures to database for application"
#	task :update => :environment do
##			context_data_sources
##			units
#		fixtures = %w(
#			address_types
#			context_contextables
#			contexts
#			data_sources
#			diagnoses
#			document_types
#			document_versions
#			follow_up_types
#			hospitals
#			ineligible_reasons
#			instrument_types
#			instrument_versions
#			instruments
#			interview_methods
#			interview_outcomes
#			languages
#			operational_event_types
#			organizations
#			people
#			phone_types
#			project_outcomes
#			projects
#			races
#			refusal_reasons
#			roles
#			sample_formats
#			sample_locations
#			sample_outcomes
#			sample_temperatures
#			sample_types
#			sections
#			states
#			subject_relationships
#			subject_types
#			tracing_statuses
#			vital_statuses 
#		)
#		ENV['FIXTURES'] = fixtures.join(',')
#		puts "Loading fixtures for #{ENV['FIXTURES']}"
#		Rake::Task["db:fixtures:load"].invoke
#		Rake::Task["db:fixtures:load"].reenable
#	end
#	desc "app:update, zip_codes:import_all, counties:import_all"
#	task :full_update => [:update,'zip_codes:import_all','counties:import_all']




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
#
#	task :import_and_namerize_study_subject_names => :environment do
#		#	This will include controls and mothers (cases too, but no biggy)
#		StudySubject.where(:phase => 5).each do |ss|
##		StudySubject.where(:case_control_type => 6).each do |ss|
#
#			puts "Processing #{ss.subject_type} ..."
#
#			unless ss.birth_data.empty?
#				bd = ss.birth_data.first
#				%w( father_first_name father_middle_name father_last_name ).each do |field|
#					puts " Current: #{field}:#{ss.send(field)}:"
#					if !bd.send(field).blank?
#						ss.send("#{field}=", bd.send(field).namerize)
#					end
#					puts " Updated: #{field}:#{ss.send(field)}:"
#				end
#			end
#
#			%w( mother_first_name mother_middle_name mother_maiden_name mother_last_name
#				first_name middle_name maiden_name last_name ).each do |field|
#				puts " Current: #{field}:#{ss.send(field)}:"
#				unless ss.send(field).blank?
#					ss.send("#{field}=", ss.send(field).namerize)
#				end
#				puts " Updated: #{field}:#{ss.send(field)}:"
#			end
#			if ss.changed?
#				puts "#{ss}"
#				puts "Changes:#{ss.changes}"
##				puts "Update? Y / N / Q"
##				response = STDIN.gets
##				if response.match(/y/i)
#					puts "Saving ..."
#					ss.save!
##				elsif response.match(/q/i)
##					puts "Quiting ..."
##					exit
##				else
##					puts "Skipping ..."
##				end
#			else
#				puts "No changes."
#			end
#		end
#	end
#
#	#	This is more of a synchronize_birth_data_records_with_csv_file_content
#	#	as I am no longer explicitly updating the ssn fields.  I'm throwing
#	#	the whole line at the record, very similar to creation.
#	task :import_parents_ssns_from_csv_file_to_birth_data_records => :environment do
#		bdus = BirthDatumUpdate.all
#		#	at the time or writing this script, there should be only one BDU
#		raise "OMG! Where did all these come from?" if bdus.length > 1
#		bdu = bdus.first
#		(f=CSV.open( bdu.csv_file.path, 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#
#			raise "master_id is blank" if line['master_id'].blank?
#			raise "case_control_flag is blank" if line['case_control_flag'].blank?
#			#	state_registrar_no will be blank for cases
#
#			#	these 3 fields make the request unique enough to always return 1 record. (so far)
#			bds = bdu.birth_data
#				.where(:case_control_flag  => line['case_control_flag'])
#				.where(:state_registrar_no => line['state_registrar_no'])
#				.where(:master_id          => line['master_id'])
#
#			#	this shouldn't happen unless another file was uploaded
#			raise "no matches" if bds.count < 1
#			raise "multiple matches :#{bd.count}:" if bds.count > 1
#
#			bd = bds.first
#
#			puts " Father SSN:#{bd.father_ssn}: Mother SSN:#{bd.mother_ssn}:"
#			puts " Father SSN:#{line['father_ssn']}: Mother SSN:#{line['mother_ssn']}:"
#
###	could have leading zeros so need to use sprintf
##
###			raise "Father SSN:#{bd.father_ssn}: already set!" unless bd.father_ssn.blank?
##			unless line['father_ssn'].blank?
###				raise "Father SSN invalid." if line['father_ssn'].match(/(0000|9999)/)
###raise "Father SSN non-numeric." unless line['father_ssn'] == line['father_ssn'].to_i.to_s
###puts "-- skipping Father SSN non-numeric." unless line['father_ssn'] == sprintf("%09d",line['father_ssn'].to_i)
##				bd.father_ssn = line['father_ssn']
##			end
##
###			raise "Mother SSN:#{bd.mother_ssn}: already set!" unless bd.mother_ssn.blank?
##			unless line['mother_ssn'].blank?
###				raise "Mother SSN invalid." if line['mother_ssn'].match(/(0000|9999)/)
###raise "Mother SSN non-numeric." unless line['mother_ssn'] == line['mother_ssn'].to_i.to_s
###puts "-- skipping Mother SSN non-numeric." unless line['mother_ssn'] == sprintf("%09d",line['mother_ssn'].to_i)
##				bd.mother_ssn = line['mother_ssn']
##			end
#
#birth_datum_attributes = line.dup.to_hash
#line.headers.each do |h|
#birth_datum_attributes.delete(h) unless BirthDatumUpdate.expected_column_names.include?(h)
#end
#bd.attributes = birth_datum_attributes
#
#			if bd.changed?
#				puts "Changes:#{bd.changes}"
##				puts "Update? Y / N / Q"
##				response = STDIN.gets
##				if response.match(/y/i)
#					puts "Saving ..."
#					bd.save!
##				elsif response.match(/q/i)
##					puts "Quiting ..."
##					exit
##				else
##					puts "Skipping ..."
##				end
#			else
#				puts "No changes."
#			end
#		end
#
#	end
#
#	task :create_addresses_from_birth_data_records => :environment do
#		BirthDatum.where('study_subject_id IS NOT NULL').each do |bd|
#			puts "Creating address from birth data for :#{bd.study_subject}:"
#			birthdata_addressing = bd.study_subject.addressings
#				.where(:data_source_id => DataSource['birthdata'].id)
#			if birthdata_addressing.empty?
#				response = bd.create_address_from_attributes
#				if response.new_record?
#					puts response.errors.full_messages.to_sentence
#					else
#					puts " success"
#				end
#			else
#				puts "This subject already has an address from birthdata. Skipping."
#			end
#		end
#
#	end

#	task :update_consents_from_pagan => :environment do
#		csv_file = 'consent_updates_from_pagan.csv'
#		require 'csv'
#		(f=CSV.open( csv_file, 'rb',{
#				:headers => true })).each do |line|
#			puts
##			puts "Processing line :#{f.lineno}:"
##			puts line
#
##	one is missing icf_master_id so using cases and patid
#			raise "patid is blank" if line['patid'].blank?
#			subjects = StudySubject.cases.where(:patid => line['patid'])
#			raise "Multiple case subjects? with patid:#{line['patid']}:" if subjects.length > 1
#			raise "No subject with patid:#{line['patid']}:" unless subjects.length == 1
#			s = subjects.first
#
#			raise_unless_string_equal(s,line,'case_control_type')
#			raise_unless_string_equal(s,line,'icf_master_id')
#			raise_unless_string_equal(s,line,'patid')
#			raise_unless_string_equal(s,line,'first_name')
#			raise_unless_string_equal(s,line,'last_name')
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#			puts_unless_yndk_equal(e,line,'is_eligible')
#			puts_unless_yndk_equal(e,line,'consented')
#			puts_unless_date_equal(e,line,'consented_on')
#			p = s.patient
#			puts_unless_date_equal(p,line,'admit_date')
##hospital
#
##birth_datum_attributes = line.dup.to_hash
##line.headers.each do |h|
##birth_datum_attributes.delete(h) unless BirthDatumUpdate.expected_column_names.include?(h)
##end
##bd.attributes = birth_datum_attributes
##
##			if bd.changed?
##				puts "Changes:#{bd.changes}"
###				puts "Update? Y / N / Q"
###				response = STDIN.gets
###				if response.match(/y/i)
##					puts "Saving ..."
##					bd.save!
###				elsif response.match(/q/i)
###					puts "Quiting ..."
###					exit
###				else
###					puts "Skipping ..."
###				end
##			else
##				puts "No changes."
##			end
#		end	#	(f=CSV.open( csv_file.path, 'rb',{
#	end #	task :update_consents_from_pagan => :environment do

#	task :update_assigned_from_pagan => :environment do
##		csv_file = 'assigned.csv'
##	#392
##	Please update the variable 'assigned_for_interview_at' with the date 09/06/2012 for the cases listed in the following file:
##S:\Research (xx)\Competing Renewal 2009-2014\ICF\DataTransfers\ICF_case_lists\newcases_09062012.xlsx
#		csv_file = 'newcases_09062012.csv'
#		require 'csv'
#		(f=CSV.open( csv_file, 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
#			raise "icf_master_id is blank" if line['icf_master_id'].blank?
#			subjects = StudySubject.cases.where(:icf_master_id => line['icf_master_id'])
#			raise "Multiple case subjects? with icf_master_id:#{line['icf_master_id']}:" if subjects.length > 1
#			raise "No subject with icf_master_id:#{line['icf_master_id']}:" unless subjects.length == 1
#			s = subjects.first
#
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#
##			puts Time.parse(line['assigned_for_interview_at'])
##			puts e.assigned_for_interview_at
##			e.assigned_for_interview_at = Time.parse(line['assigned_for_interview_at'])
#			e.assigned_for_interview_at = Time.parse('Sep 6, 2012')
#			if e.changed?
#				puts "enrollment updated. Creating OE"
#				e.save!
#				s.operational_events.create!(
#					:project_id                => Project['ccls'].id,
#					:operational_event_type_id => OperationalEventType['other'].id,
#					:occurred_at               => DateTime.current,
#					:description               => "assigned_for_interview_at set to "<<
#						"#{line['assigned_for_interview_at']} from " <<
#						"newcases_09062012 file"
#				)
#			end
#		end	#	(f=CSV.open( csv_file.path, 'rb',{
#
#	end #	task :update_assigned_from_pagan => :environment do

#
#	20121219 - This is now done from within the site before this csv
#		file is exported and so doesn't need to be "imported"
#
#	desc "Read CSV file and set Subject's CCLS enrollment#assigned_for_interview_at"
#	task :update_assigned_for_interview_at_from_new_cases_csv => :environment do
#		env_required('csv_file')
#		env_required('assigned_for_interview_at')
#		file_required(ENV['csv_file'])
#		assigned_for_interview_at = valid_date_required(ENV['assigned_for_interview_at'])
#		changes = 0
#
#		require 'csv'
#		(f=CSV.open( ENV['csv_file'], 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
#			raise "icf_master_id is blank" if line['icf_master_id'].blank?
#			subjects = StudySubject.cases.where(:icf_master_id => line['icf_master_id'])
#			raise "Multiple case subjects? with icf_master_id:" <<
#				"#{line['icf_master_id']}:" if subjects.length > 1
#			raise "No subject with icf_master_id:" <<
#				"#{line['icf_master_id']}:" unless subjects.length == 1
#			s = subjects.first
#			puts "Found subject #{s}"
#
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#
#			puts "Current assigned_for_interview_at: #{e.assigned_for_interview_at}"
#			e.assigned_for_interview_at = assigned_for_interview_at
#			if e.changed?
#				puts "Updated assigned_for_interview_at: #{e.assigned_for_interview_at}"
#				puts "enrollment updated. Creating OE"
#				if ENV['REALLY_SAVE_THIS_TIME'] == 'yes'
#					puts "'REALLY_SAVE_THIS_TIME=yes' set. Saving!"
#					e.save!
#					s.operational_events.create!(
#						:project_id                => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['other'].id,
#						:occurred_at               => DateTime.current,
#						:description               => "assigned_for_interview_at set to "<<
#							"#{ENV['assigned_for_interview_at']} from " <<
#							ENV['csv_file']
#					)
#				else
#					changes += 1
#					puts "'REALLY_SAVE_THIS_TIME=yes' not set at command line so doing nothing."
#				end
#			else
#				puts "No change so doing nothing."
#			end
#		end	#	(f=CSV.open( csv_file.path, 'rb',{
#		if ENV['REALLY_SAVE_THIS_TIME'] == 'yes'
#			puts "Commiting Sunspot index."
#			Sunspot.commit
#		elsif changes > 0
#			puts
#			puts "#{changes} #{(changes==1)?'change':'changes'} found."
#			puts "'REALLY_SAVE_THIS_TIME=yes' not set at command line so did nothing."
#		end
#	end #	task :update_assigned_from_pagan => :environment do


#	task :update_completes_from_pagan => :environment do
#		csv_file = 'completes.csv'
#		require 'csv'
#		(f=CSV.open( csv_file, 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
#			raise "icf_master_id is blank" if line['icf_master_id'].blank?
#			subjects = StudySubject.cases.where(:icf_master_id => line['icf_master_id'])
#			raise "Multiple case subjects? with icf_master_id:#{line['icf_master_id']}:" if subjects.length > 1
#			raise "No subject with icf_master_id:#{line['icf_master_id']}:" unless subjects.length == 1
#			s = subjects.first
#
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#
##			puts Time.parse(line['assigned_for_interview_at'])
##			puts Time.parse(line['interview_completed_on'])
##			puts e.assigned_for_interview_at
##			puts e.interview_completed_on
#			e.assigned_for_interview_at = Time.parse(line['assigned_for_interview_at'])
#			e.interview_completed_on = Time.parse(line['interview_completed_on'])
#			e.save!
#
#		end	#	(f=CSV.open( csv_file.path, 'rb',{
#
#	end #	task :update_completes_from_pagan => :environment do

#	task :create_missing_phase5_mom_subjects => :environment do
#		csv_file = 'ODMS_missing_phase5_mom_subjects.csv'
#		require 'csv'
#		(f=CSV.open( csv_file, 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
##	"subject_type_id","do_not_contact","sex","reference_date","hispanicity_id","matchingid","familyid","first_name","maiden_name","last_name","childid","childidwho","patid","newid","related_childid","related_case_childid"
#
#			unless StudySubject.mothers.with_patid(line["patid"]).empty?
#				raise "Mother exists for #{line["patid"]}" 
#			end
#
#			subject = StudySubject.new do |s|
#				s.subject_type_id = line["subject_type_id"]
#				s.do_not_contact = line["do_not_contact"]
#				s.sex = line["sex"]
#				s.reference_date = line["reference_date"]
#				s.hispanicity_id = line["hispanicity_id"]
#				s.matchingid = line["matchingid"]
#				s.familyid = line["familyid"]
#				s.first_name = line["first_name"]
#				s.maiden_name = line["maiden_name"]
#				s.last_name = line["last_name"]
#				#	s.childid = line["childid"]
#				s.childidwho = line["childidwho"]
#				s.patid = line["patid"]
#				s.newid = line["newid"]
#				s.related_childid = line["related_childid"]
#				s.related_case_childid = line["related_case_childid"]
#			end
#
##			puts subject.errors.inspect unless subject.valid?
#			subject.save!
#			subject.assign_icf_master_id
#			
#		end	#	(f=CSV.open( csv_file.path, 'rb',{
#
#	end #	task :create_missing_phase5_mom_subjects => :environment do

#
#	Eventually, this should be part of the ICFMasterTrackerUpdate
#
#	20121219 - This is now done with automate:updates_from_icf_master_tracker
#		via a cron job.
#
#	desc "Read CSV file and set Subject's CCLS enrollment#interview_completed_on"
#	task :update_interview_completed_on_from_icf_master_tracker => :environment do
#		#	from '/Volumes/BUF-Fileshare/SharedFiles/Research (xx)
#		#		/Competing Renewal 2009-2014/ICF/DataTransfers
#		#		/ICF_master_trackers/ICF_Master_Tracker.csv'
#		env_required('csv_file')
#		file_required(ENV['csv_file'])
#
#		changes = 0
#
#		require 'csv'
#		(f=CSV.open( ENV['csv_file'], 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
##	master_id,master_id_mother,language,record_owner,record_status,record_status_date,date_received,last_attempt,last_disposition,curr_phone,record_sent_for_matching,record_received_from_matching,sent_pre_incentive,released_to_cati,confirmed_cati_contact,refused,deceased_notification,is_eligible,ineligible_reason,confirmation_packet_sent,cati_protocol_exhausted,new_phone_released_to_cati,plea_notification_sent,case_returned_for_new_info,case_returned_from_berkeley,cati_complete,kit_mother_sent,kit_infant_sent,kit_child_sent,kid_adolescent_sent,kit_mother_refused_code,kit_child_refused_code,no_response_to_plea,response_received_from_plea,sent_to_in_person_followup,kit_mother_received,kit_child_received,thank_you_sent,physician_request_sent,physician_response_received,vaccine_auth_received,recollect
#
#			raise "master_id is blank" if line['master_id'].blank?
#			subjects = StudySubject.where(:icf_master_id => line['master_id'])
#			raise "Multiple case subjects? with icf_master_id:" <<
#				"#{line['master_id']}:" if subjects.length > 1
#			raise "No subject with icf_master_id:" <<
#				"#{line['master_id']}:" unless subjects.length == 1
#			s = subjects.first
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#
##	#393
##		Please update the 'interview_completed_on' field in odms with the dates listed in the 'cati_complete' in the ICF_Master_Tracker.csv file located in S:\Research (xx)\Competing Renewal 2009-2014\ICF\DataTransfers\ICF_master_trackers.
#
#			if line['cati_complete'].blank?
#				puts "cati_complete is blank so doing nothing."
#			else
#				puts "cati_complete: #{Time.parse(line['cati_complete']).to_date}"
#				puts "Current interview_completed_on : #{e.interview_completed_on}"
#				e.interview_completed_on = Time.parse(line['cati_complete']).to_date
#				if e.changed?
#					puts "Updated interview_completed_on : #{e.interview_completed_on}"
#					puts "enrollment updated. creating OE"
#					if ENV['REALLY_SAVE_THIS_TIME'] == 'yes'
#						puts "'REALLY_SAVE_THIS_TIME=yes' set. Saving!"
#						e.save!
#						s.operational_events.create!(
#							:project_id                => Project['ccls'].id,
#							:operational_event_type_id => OperationalEventType['other'].id,
#							:occurred_at               => DateTime.current,
#							:description               => "interview_completed_on set to " <<
#								"cati_complete #{line['cati_complete']} from " <<
#								"ICF Master Tracker file #{ENV['csv_file']}"
#						)
#					else
#						puts "'REALLY_SAVE_THIS_TIME=yes' not set at command line so doing nothing."
#						changes += 1
#					end
#				else
#					puts "No change so doing nothing."
#				end
#			end
#		end	#	(f=CSV.open( csv_file.path, 'rb',{
#		if ENV['REALLY_SAVE_THIS_TIME'] == 'yes'
#			puts "Commiting Sunspot index."
#			Sunspot.commit
#		elsif changes > 0
#			puts
#			puts "#{changes} #{(changes==1)?'change':'changes'} found."
#			puts "'REALLY_SAVE_THIS_TIME=yes' not set at command line so did nothing."
#		end
#
#	end #	task :update_interview_completed_on_from_icf_master_tracker => :environment do

	desc "Read csv file and show given columns"
	task :show_csv_columns => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		env_required('columns','is required comma separated list')
		columns = ENV['columns'].split(/\s*,\s*/)

		require 'csv'
		f=CSV.open( ENV['csv_file'], 'rb')
		header_line = f.gets
		f.close

		columns.each do |c|
			unless header_line.include?(c)
				puts
				puts "'#{c}' is not a valid column"
				puts "Columns are #{header_line.join(', ')}"
				puts
				exit
			end
		end

		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
			columns.each { |c| printf("%s\t",line[c]) }
			puts
		end
	end

end

def i_should?
	puts "Should I save this? ( Y / N / Q )"
	response = STDIN.gets
	if response.match(/y/i)
		return true
	elsif response.match(/q/i)
		puts "Quiting ..."
		exit
	else
		return false
	end
end

def raise_unless_string_equal(m,l,f)
	unless m.send(f).to_s == l[f].to_s
		puts m.inspect
		puts l.inspect
		raise "#{f} differs :#{m.send(f)}:#{l[f]}:" 
	end
end
def puts_unless_yndk_equal(m,l,f)
	unless YNDK[m.send(f).to_s] == l[f]
		puts m.inspect
		puts l.inspect
		puts "#{f} differs :#{YNDK[m.send(f)]}:#{l[f]}:" 
#		raise "#{f} differs :#{m.send(f)}:#{l[f]}:" 
	end
end
def puts_unless_date_equal(m,l,f)
	line_date = ( l[f].blank? ) ? nil : Date.parse(l[f])
	unless m.send(f) == line_date
		puts m.inspect
		puts l.inspect
		puts "#{f} differs :#{m.send(f)}:#{l[f]}:" 
#		raise "#{f} differs :#{m.send(f)}:#{l[f]}:" 
	end
end
def env_required(var,msg='is required')
	if ENV[var].blank?
		puts
		puts "'#{var}' is not set and #{msg}"
		puts "Rerun with #{var}=something"
		puts
		exit
	end
end
def file_required(filename,msg='is required')
	unless File.exists?(filename)
		puts
		puts "File '#{filename}' was not found and #{msg}"
		puts
		exit
	end
end
def valid_date_required(date_string,msg='is required')
	begin
		Time.parse(date_string)
	rescue
		puts
		puts "The parsing of '#{date_string}' failed and #{msg}."
		puts
		exit
	end
end
