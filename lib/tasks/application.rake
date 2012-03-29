namespace :app do

	desc "Load some fixtures to database for application"
	task :update => :environment do
		fixtures = %w(
			address_types
			context_data_sources
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

end
