namespace :odms_import do

	desc "Destroy subject and address data"
	task :destroy_all => :odms_import_base do
		puts "Destroying existing data"
		StudySubject.destroy_all
#	subject_races?	currently, there aren't any created
#	subject_languages?	currently, there aren't any created
		Enrollment.destroy_all
		Addressing.destroy_all
		Address.destroy_all
		PhoneNumber.destroy_all
		Interview.destroy_all
		Patient.destroy_all
		Sample.destroy_all
		SampleKit.destroy_all
		HomexOutcome.destroy_all
		HomeExposureResponse.destroy_all
		OperationalEvent.destroy_all
		#	have to destroy these as well as they are associated with a given 
		#	subject, all of which were just destroyed.
		BcRequest.destroy_all	
		CandidateControl.destroy_all
		IcfMasterId.destroy_all
	end	#	task :destroy_all => :odms_import_base do

	#
	#	Generates subject_in.csv from Magee's input file.
	#	This file will need sorted before comparison.
	#
	#
	#	GONNA NEED TO SORT THESE TO COMPARE THEM, BUT BEWARE! OF MULTI-LINED ENTRIES
	#
	#
	task :prepare_input_for_comparison => :odms_import_base do
		#	Some columns are quoted and some aren't.  Quote all.
		FasterCSV.open('subject_in.csv','w', {:force_quotes=>true}) do |out|
			out.add_row ["subjectid","subject_type_id","vital_status_id","do_not_contact","sex","reference_date","childidwho","hispanicity_id","childid","icf_master_id","matchingid","familyid","patid","case_control_type","orderno","newid","studyid","related_case_childid","state_id_no","admit_date","diagnosis_id","created_at","first_name","middle_name","last_name","maiden_name","dob","died_on","mother_first_name","mother_maiden_name","mother_last_name","father_first_name","father_last_name","was_previously_treated","was_under_15_at_dx","raf_zip","raf_county","birth_year","hospital_no","organization_id","other_diagnosis"]
	
			#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
			(f=FasterCSV.open(SUBJECTS_CSV, 'rb',{ :headers => true })).each do |line|

				#	Not all input records have created_at so nillify all
				line['created_at'] = nil

				#	
				#	Some dates are dates and some are strings so the format is different.
				#
				line['reference_date'] = format_time_to_date( line['reference_date'] )
				line['admit_date'] = format_time_to_date( line['admit_date'] )
				line['dob'] = format_time_to_date( line['dob'] )
				line['died_on'] = format_time_to_date( line['died_on'] )


#	TODO deal with incorrect value 9 in was_* fields
#				if( line['was_previously_treated'].to_s == '9' )
#					puts "Converting was_previously_treated = 9 to 999"
#					puts line
#					line['was_previously_treated'] = '999' 
#					puts line
#				end
#				if( line['was_under_15_at_dx'].to_s == '9' )
#					puts "Converting was_under_15_at_dx = 9 to 999"
#					puts line
#					line['was_under_15_at_dx'] = '999' 
#					puts line
#				end

#				if line['subject_type_id'].to_i == StudySubject.subject_type_case_id &&
#						line['organization_id'].blank?
#
##					#	1 record is missing organization_id so must do this.
##					m.organization_id = ( line['organization_id'].blank? ) ?
##						999 : line['organization_id']
#
#					line['organization_id'] = 999 
#				end

				out.add_row line
			end	#	(f=FasterCSV.open(SUBJECTS_CSV, 'rb',{ :headers => true })).each do |line|

		end	#	FasterCSV.open('subject_in.csv','w', {:force_quotes=>true}) do |out|

	end	#	task :prepare_input_for_comparison => :odms_import_base do

	#
	#	Generates a subject_out.csv file from data in the database.
	#
	#
	#	GONNA NEED TO SORT THESE TO COMPARE THEM
	#
	#
	task :csv_dump => :odms_import_base do
		puts "Dumping to csv for comparison"

		FasterCSV.open('subject_out.csv','w', {:force_quotes=>true}) do |f|
			f.add_row ["subjectid","subject_type_id","vital_status_id","do_not_contact","sex","reference_date","childidwho","hispanicity_id","childid","icf_master_id","matchingid","familyid","patid","case_control_type","orderno","newid","studyid","related_case_childid","state_id_no","admit_date","diagnosis_id","created_at","first_name","middle_name","last_name","maiden_name","dob","died_on","mother_first_name","mother_maiden_name","mother_last_name","father_first_name","father_last_name","was_previously_treated","was_under_15_at_dx","raf_zip","raf_county","birth_year","hospital_no","organization_id","other_diagnosis"]

#			StudySubject.find(:all,
#					:order => 'subjectid ASC' ).each do |s|
			StudySubject.order( 'subjectid ASC' ).all.each do |s|

				f.add_row([
					s.subjectid,
					s.subject_type_id,
					s.vital_status_id,
					s.do_not_contact.to_s.upcase,	# FALSE
					s.sex,
					format_date(s.reference_date),
					s.childidwho,
					s.hispanicity_id,
					s.childid,
					s.icf_master_id,
					s.matchingid,
					s.familyid,
					s.patid,
					s.case_control_type,
					s.orderno,
					s.newid,
					s.studyid,		
					s.related_case_childid,
					s.state_id_no,
					format_date(s.patient.try(:admit_date)),
					s.patient.try(:diagnosis_id),
					nil,
					s.first_name,
					s.middle_name,
					s.last_name,
					s.maiden_name,
					format_date(s.dob),
					format_date(s.died_on),
					s.mother_first_name,
					s.mother_maiden_name,
					s.mother_last_name,
					s.father_first_name,
					s.father_last_name,
					s.patient.try(:was_previously_treated),
					s.patient.try(:was_under_15_at_dx),
					s.patient.try(:raf_zip),
					s.patient.try(:raf_county),
					s.birth_year,
					s.patient.try(:hospital_no),
					s.patient.try(:organization_id),
					s.patient.try(:other_diagnosis)
				])
			end

		end	#	FasterCSV.open('subject_out.csv','w', {:force_quotes=>true}) do |f|

	end	#	task :csv_dump => :odms_import_base do

	desc "Import subject data from CSV files"
	task :csv_data => [
#		'odms_destroy:csv_data',
		'odms_import:destroy_all',
		'odms_import:subjects',
		'odms_import:icf_master_ids',
		'odms_import:enrollments',
		'odms_import:operational_events',
		'odms_import:phone_numbers',
		'odms_import:addresses',
		'odms_import:addressings',
#		'odms_import:samples',
#		'odms_import:create_dummy_candidate_controls',
		'app:data:report'
	]



#	task :create_dummy_candidate_controls => :odms_import_base do
##		puts "Destroying candidate controls"
##		CandidateControl.destroy_all
#		puts "Creating dummy candidate controls"
#		SubjectType['Case'].study_subjects.each do |s|
#			rand(5).times do |i|
#				puts "Creating candidate control for study_subject_id:#{s.id}"
#				CandidateControl.create!({
#					:related_patid => s.patid,
#					:first_name => "First#{i}",
#					:last_name  => "Last#{s.id}",
#					:sex        => ['M','F'][rand(2)],
#					:dob        => Date.jd(2440000+rand(15000))
#				})
#			end
#		end
#		
#		printf "%-19s %5d\n", "CandidateControl.count:", CandidateControl.count
#	end

end	#	namespace :odms_import do
