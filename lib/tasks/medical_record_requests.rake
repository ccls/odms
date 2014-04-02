require 'csv'
namespace :app do
namespace :medical_record_requests do

	task :import_requested_and_received => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		#	NOTE Not all have icf_master_id
		#	  patid,subjectid,icf_master_id,AbstractRequested_on,AbstractReceived_on
		(csv_in = CSV.open( ENV['csv_file'], 'rb',{ :headers => true })).each do |line|
			subjects = StudySubject.where(:subjectid => line['subjectid'])
			puts "Subject not found with subjectid #{line['subjectid']}" if subjects.empty?
			if subjects.length > 1
				puts "Multiple found with subjectid #{line['subjectid']}?" 
				puts subjects.inspect
			end
			subject = subjects.first
			if subject.patid != line['patid']
				puts "Inconsistent patids #{subject.patid} != #{line['patid']}"
				raise "Inconsistent patids #{subject.patid} != #{line['patid']}"
			end
			if subject.icf_master_id != line['icf_master_id']
				puts "Inconsistent icf_master_id #{subject.icf_master_id} != #{line['icf_master_id']}"
				raise "Inconsistent icf_master_id #{subject.icf_master_id} != #{line['icf_master_id']}"
			end
			
			subject.medical_record_requests.create!(
				:status => 'complete',
				:sent_on => line['AbstractRequested_on'],
				:returned_on => line['AbstractReceived_on'],
				:notes => "Imported after the fact from #{ENV['csv_file']}"
			)
			subject.operational_events.create!(
				:project => Project['ccls'],
				:operational_event_type => OperationalEventType['medical_record_request_sent'],
				:occurred_at => line['AbstractRequested_on'],
				:notes => "Imported after the fact from #{ENV['csv_file']}"
			)
			subject.operational_events.create!(
				:project => Project['ccls'],
				:operational_event_type => OperationalEventType['medical_record_received'],
				:occurred_at => line['AbstractReceived_on'],
				:notes => "Imported after the fact from #{ENV['csv_file']}"
			)
		end	#	(csv_in = CSV.open( csv_file, 'rb',{ :headers => true })).each do |line|
	end	#	task :import_requested_and_received => :environment do

	task :import_requested => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		#	patid,subjectid,icf_master_id
		(csv_in = CSV.open( ENV['csv_file'], 'rb',{ :headers => true })).each do |line|
			subjects = StudySubject.where(:subjectid => line['subjectid'])
			puts "Subject not found with subjectid #{line['subjectid']}" if subjects.empty?
			if subjects.length > 1
				puts "Multiple found with subjectid #{line['subjectid']}?" 
				puts subjects.inspect
			end
			subject = subjects.first
			if subject.patid != line['patid']
				puts "Inconsistent patids #{subject.patid} != #{line['patid']}"
				raise "Inconsistent patids #{subject.patid} != #{line['patid']}"
			end
			if subject.icf_master_id != line['icf_master_id']
				puts "Inconsistent icf_master_id #{subject.icf_master_id} != #{line['icf_master_id']}"
				raise "Inconsistent icf_master_id #{subject.icf_master_id} != #{line['icf_master_id']}"
			end
			
			subject.medical_record_requests.create!(
				:status => 'waitlist',
				:notes => "Imported from #{ENV['csv_file']}"
			)
		end	#	(csv_in = CSV.open( csv_file, 'rb',{ :headers => true })).each do |line|
	end	#	task :import_requested_and_received => :environment do

end	#	namespace :medical_record_requests do
end	#	namespace :app do
