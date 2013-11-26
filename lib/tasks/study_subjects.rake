namespace :app do
namespace :study_subjects do

	task :update_interview_date => :environment do

#		filename = "missing_intvwdata.csv"
		filename = "qry_intvw_status.csv"

		output_filename = "#{File.basename(filename,File.extname(filename))}.output.csv"

		outcsv = CSV.open( output_filename, 'w' )
		outcsv << %w( subjectid childid patid icf_master_id languages_before 
			languages_after 
			languages_changed?
			assigned_for_interview_at_before 
			assigned_for_interview_at_after 
			assigned_for_interview_at_changed?
			interview_completed_on_before 
			interview_completed_on_after
			interview_completed_on_changed?
		)
		CSV.open( filename, 'rb',{ :headers => true }).each do |line|
			puts line
			csv = []
			#	PatID,ChildID,Type,Eligibl,Consen,Language,Intass,InterviewDate
			#subjects = StudySubject.cases.with_patid(line['PatID'])
			#Inst,Language,ICFMasterID,PatID,ChildID,Eligibl,Consen,Intass,InterviewDate,Type,Admitdte,AbstractDate
			#	PatID,subjectid,ChildId,Type,OrderNo,Eligibl,Consen,Consdate,Intass,InterviewDate,Language

			csv_subjectid = line['subjectid'] || line['SubjectID'] || line['SubjectId']
			csv_childid = line['childid'] || line['ChildID'] || line['ChildId']
			csv_patid   = line['patid'] || line['PatID'] || line['PatId']
			csv_cctype  = line['Type']
			csv_orderno = line['OrderNo']

			subjects = StudySubject.with_subjectid(csv_subjectid)
			subjects = StudySubject.with_childid(csv_childid) if subjects.empty?

			if subjects.length == 1
				subject = subjects.first
				subject_language_names_before = subject.language_names
				subject_assigned_for_interview_at_before = subject.ccls_enrollment.assigned_for_interview_at.try(:to_date)
				subject_interview_completed_on_before = subject.ccls_enrollment.interview_completed_on.try(:to_date)

				puts "ChildIDs #{csv_childid}:#{subject.childid}"
				raise "ChildID mismatch #{csv_childid}:#{subject.childid}" if(
					csv_childid.to_i != subject.childid.to_i )

				puts "PatIDs #{csv_patid}:#{subject.patid}"
				raise "PatID mismatch #{csv_patid}:#{subject.patid}" if(
					csv_patid.to_i != subject.patid.to_i )

				puts "CaseControlType #{csv_cctype}:#{subject.case_control_type}"
				raise "CaseControlType mismatch #{csv_cctype}:#{subject.case_control_type}" if(
					csv_cctype != subject.case_control_type )

				#	OrderNo isn't in the first file
				if csv_orderno.present?
					puts "OrderNo #{csv_orderno}:#{subject.orderno}"
					raise "OrderNo mismatch #{csv_orderno}:#{subject.orderno}" if(
						csv_orderno.to_i != subject.orderno.to_i )
				end

				unless( line['Language'].blank? or 
						line['Language'] == 'Other' or
						line['Language'] == "Don't Know" or
						Language[line['Language']].nil? or
						subject.languages.include?(Language[line['Language']]))
					subject.languages << Language[line['Language']] 
					subject.operational_events.create(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['datachanged'].id,
						:description => "Language changes from #{filename}",
						:notes => "#{line['Language']} added to languages")
				end

				#	don't want to DELETE existing data, so check if new value exists before assigning it

				#	if date is in format 01-Jan-00, the year will be 0000, not 2000
				#	unless explicitly parsed with Date.parse and second arg of true given
				#	to flag a "near now parsing"

				ccls_enrollment = subject.ccls_enrollment
				ccls_enrollment.assigned_for_interview_at = Date.parse(line['Intass'],true) if line['Intass'].present?
				ccls_enrollment.interview_completed_on = Date.parse(line['InterviewDate'],true) if line['InterviewDate'].present?

				ccls_enrollment_changes = ccls_enrollment.changes
				if ccls_enrollment.changed?
					ccls_enrollment.save!
					subject.operational_events.create(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['datachanged'].id,
						:description => "CCLS enrollment changes from #{filename}",
						:notes => ccls_enrollment_changes.to_s )
				end
			else
				raise "Not 1 subject found with subjectid :#{csv_subjectid}: or childid :#{csv_childid}:"
			end

			subject.reload
			ccls_enrollment.reload
			csv << subject.subjectid
			csv << subject.childid
			csv << subject.patid
			csv << subject.icf_master_id
			csv << subject_language_names_before
			csv << subject.language_names
			csv << ( subject_language_names_before != subject.language_names )

			csv << subject_assigned_for_interview_at_before
			csv << ccls_enrollment.assigned_for_interview_at.try(:to_date)
			csv << ( subject_assigned_for_interview_at_before !=
				ccls_enrollment.assigned_for_interview_at.try(:to_date) )
#	db is datetime, csv is date.  will always be different even when the same
#			csv << ccls_enrollment_changes.keys.include?('assigned_for_interview_at')

			csv << subject_interview_completed_on_before
			csv << ccls_enrollment.interview_completed_on.try(:to_date)
#			csv << ( subject_interview_completed_on_before !=
#				ccls_enrollment.interview_completed_on.try(:to_date) )
			csv << ccls_enrollment_changes.keys.include?('interview_completed_on')
			outcsv << csv
		end
		outcsv.close
	end

	task :update_birth_year_from_dob => :environment do
		raise "This task has been run and disabled."
		#	find_each is a apparently a batch find method
		StudySubject.find_each do |study_subject|
			dob = study_subject.dob
			puts "Updating #{study_subject} birth year to #{dob.try(:year)} from dob #{dob}"
			#	probably didn't need to actually call this as is called again in before_save (duh)
			study_subject.set_birth_year	
			study_subject.save!
		end
		Sunspot.commit
		#
		#	With all the callbacks and extra stuff, that took way too long
		#	Quit it and ran this instead.
		#	StudySubject.find_each{|s|s.update_column(:birth_year, s.dob.try(:year))}
		#	and then reindexed
		#
	end

	task :sync_related_icf_master_ids => :environment do
		puts Time.zone.now
#
#	Not all subjects have icf_master_ids, not all have mothers.
#	Using :phase => 5 to limit these, although eventually it will not be true
#
		StudySubject.where(:phase => 5).where(:case_icf_master_id => nil).each do |s|
			puts "Syncing case subject for #{s}"
			if s.case_subject.present?
				if s.case_subject.icf_master_id.present?
					s.update_column(:case_icf_master_id, s.case_subject.icf_master_id )
					s.update_column(:needs_reindexed, true)
				else
					puts "Case doesn't have an icf master id"
				end
			else
				puts "Case doesn't exist"
			end
		end
		StudySubject.where(:phase => 5).where(:mother_icf_master_id => nil).each do |s|
			puts "Syncing mother subject for #{s}"
			if s.mother.present?
				if s.mother.icf_master_id.present?
					s.update_column(:mother_icf_master_id, s.mother.icf_master_id )
					s.update_column(:needs_reindexed, true)
				else
					puts "Mother doesn't have an icf_master_id"
				end
			else
				puts "Mother doesn't exist"
			end
		end
	end

	task :reindex => :environment do
		puts Time.zone.now
		StudySubject.where(:needs_reindexed => true).each do |subject|
			puts "Reindexing #{subject}"
			subject.index
			subject.update_column(:needs_reindexed, false)
		end
		Sunspot.commit
	end

	task :merge_missing_other_diagnosis_with_missing_diagnosis => :environment do
		raise "This task has been run and disabled."
		Patient.where(:diagnosis_id => Diagnosis[:other])
			.where(:other_diagnosis => '777: no legacy diagnosis data available in T2K').each do |p|
			#	could have used an update_all, but that wouldn't
			#	trigger the reindexing of the study subjects
			p.other_diagnosis = nil
			p.diagnosis = Diagnosis[:legacy]
			p.save!
		end
		Sunspot.commit
	end

	task :synchronize_counter_caches => :environment do
		#	find_each is a apparently a batch find method
		StudySubject.find_each do |study_subject|
			puts "Updating #{study_subject}"
			StudySubject.reset_counters( study_subject.id,
				:samples, :operational_events, :addresses, :phone_numbers, 
				:birth_data, :interviews, :abstracts, :enrollments )
		end
	end

	task :add_cdcids_from_anand => :environment do
		raise "This task has been run and disabled."
		CSV.open( 'anand/2010-12-06_MaternalBiospecimenIDLink.csv',
				'rb',{ :headers => true }).each do |line|
			puts line
			subjects = StudySubject.with_childid(line['CHILDID'].to_i)
			raise "Multiple subjects with childid #{line['CHILDID']}" if subjects.length > 1
			raise "No subjects with childid #{line['CHILDID']}" if subjects.length < 1
			subject = subjects.first
			raise "Subject is mother?" if subject.is_mother?
			subject.update_attribute(:cdcid, line['CDC_ID'].to_i)
		end
		Sunspot.commit
	end

#	task :synchronize_subject_type_with_subject_type_id => :environment do
#		SubjectType.all.each do |subject_type|
#			puts "Updating #{subject_type} subjects"
#			StudySubject.where(:subject_type_id => subject_type.id)
#				.update_all(:subject_type => subject_type.to_s )
#		end	#	SubjectType.all
#	end
#
#	task :synchronize_vital_status_with_vital_status_id => :environment do
#		VitalStatus.all.each do |vital_status|
#			puts "Updating #{vital_status} subjects"
#			StudySubject.where(:vital_status_code => vital_status.code)
#				.update_all(:vital_status => vital_status.to_s )
#		end	#	VitalStatus.all
#	end

end	#	namespace :study_subjects do
end	#	namespace :app do
__END__

# subject types fixture
case:
  id: 1
  key:  Case
  description:  Case
control:
  id:  2
  key:  Control
  description:  Control
father:
  id:  3
  key:  Father
  description:  Father
mother:
  id:  4
  key:  Mother
  description:  Mother
twin:
  id:  5
  key:  Twin
  description:  Twin

# vital statuses fixture
living:
  code: 1
  position: 1
  key: living
  description: Living
deceased:
  code: 2
  position: 2 
  key: deceased
  description: Deceased
refused:
  code: 888
  position: 4
  key: refused
  description: Refused to State
dk:
  code: 999
  position: 3
  key: unknown
  description: "Don't Know"

#	diagnoses fixture
all:
  id: 1
  position: 1
  key: ALL
  description: ALL
aml:
  id: 2
  position: 2 
  key: AML
  description: AML
other:
  id: 3
  position: 3
  key: other
  description: other diagnosis
legacy:
  id: 777
  position: 4
  key: legacy
  description:  missing data (e.g. legacy nulls)
dk:
  id: 999
  position: 5
  key: unknown
  description:  unknown diagnosis
