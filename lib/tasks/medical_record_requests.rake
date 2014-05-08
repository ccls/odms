require 'csv'
namespace :app do
namespace :medical_record_requests do

	task :create_waitlist_requests => :environment do
#		puts "Cases"
#		puts StudySubject.cases.count
#		puts "Admitted more than 60 days ago"
#		puts StudySubject.cases.where(StudySubject.arel_table[:reference_date].lt(Date.current-60.days)).count
#		puts "Consented"
#		puts StudySubject.cases.where(StudySubject.arel_table[:reference_date].lt(Date.current-60.days))
#				.joins(:enrollments => :project).where(:'projects.key' => :ccls)
#				.where(:'enrollments.consented' => YNDK[:yes]).count
#		puts "Without a MRR"
#		puts StudySubject.cases.where(StudySubject.arel_table[:reference_date].lt(Date.current-60.days))
#				.joins(:enrollments => :project).where(:'projects.key' => :ccls)
#				.where(:'enrollments.consented' => YNDK[:yes])
#				.left_joins(:medical_record_requests).where(:'medical_record_requests.id' => nil).count
#		puts "Phase 5"
#		puts StudySubject.cases.where(StudySubject.arel_table[:reference_date].lt(Date.current-60.days))
#				.joins(:enrollments => :project).where(:'projects.key' => :ccls)
#				.where(:'enrollments.consented' => YNDK[:yes])
#				.left_joins(:medical_record_requests).where(:'medical_record_requests.id' => nil)
#				.where(:phase => 5).count
#Cases
#3112
#Admitted more than 60 days ago
#3086
#Consented
#2027
#Without a MRR
#1534
#Phase 5
#172
		StudySubject.cases.where(StudySubject.arel_table[:reference_date].lt(Date.current-60.days))
				.joins(:enrollments => :project).where(:'projects.key' => :ccls)
				.where(:'enrollments.consented' => YNDK[:yes])
				.left_joins(:medical_record_requests).where(:'medical_record_requests.id' => nil)
				.where(:phase => 5).find_each do |s|
			
			puts s.full_name

#			s.medical_record_requests.create!(
#				:status => 'waitlist',
#				:notes => "Auto-created from rake task on #{Date.current.strftime("%-m/%-d/%Y")}."
#			)

		end	#	.find_each do |s|
	end	#	task :create_waitlist_requests => :environment do

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
