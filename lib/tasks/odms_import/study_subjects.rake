require 'tasks/odms_import/base'

namespace :odms_import do

	desc "Import data from subjects csv file"
	task :subjects => :odms_import_base do
		puts "Importing subjects"

		error_file = File.open('subjects_errors.txt','w')	#	overwrite existing

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open(SUBJECTS_CSV, 'rb',{ :headers => true })).each do |line|

#	skip until ...
#			next if f.lineno <= 10619

			puts "Processing line #{f.lineno}"
			puts line

#"subjectid","subject_type_id","vital_status_id","do_not_contact","sex","reference_date","childidwho","hispanicity_id","childid","icf_master_id","matchingid","familyid","patid","case_control_type","orderno","newid","studyid","related_case_childid","state_id_no","admit_date","diagnosis_id","created_at","first_name","middle_name","last_name","maiden_name","dob","died_on","mother_first_name","mother_maiden_name","mother_last_name","father_first_name","father_last_name","was_previously_treated","was_under_15_at_dx","raf_zip","raf_county","birth_year","hospital_no","organization_id","other_diagnosis","father_hispanicity_id","mother_hispanicity_id"



#
#		Models built in block mode to avoid protected attributes
#

			s = StudySubject.new do |x|
				x.subject_type_id = line['subject_type_id']
				x.hispanicity_id  = line['hispanicity_id']
				x.father_hispanicity_id  = line['father_hispanicity_id']
				x.mother_hispanicity_id  = line['mother_hispanicity_id']
#
#	do_not_contact is a boolean string in the csv file.
#	It does seem to convert correctly in the database.
				x.do_not_contact  = line['do_not_contact']

				x.sex             = line['sex']
				x.reference_date  = ( line['reference_date'].blank?
						) ? nil : Time.parse(line['reference_date'])

				x.birth_year         = line['birth_year']
				x.first_name         = line['first_name']
				x.middle_name        = line['middle_name']
				x.last_name          = line['last_name']
				x.maiden_name        = line['maiden_name']
				x.died_on            = ( line['died_on'].blank? 
					) ? nil : Time.parse(line['died_on'])
				x.mother_first_name  = line['mother_first_name']
				x.mother_maiden_name = line['mother_maiden_name']
				x.mother_last_name   = line['mother_last_name']
				x.father_first_name  = line['father_first_name']
				x.father_last_name   = line['father_last_name']

				x.dob                = ( line['dob'].blank? 
						) ? nil : Time.parse(line['dob']).to_date

				x.subjectid     = line['subjectid']
				x.childid       = line['childid']
				x.childidwho    = line['childidwho']
				x.icf_master_id = line['icf_master_id']
				x.matchingid    = line['matchingid']
				x.familyid      = line['familyid']
				x.patid         = line['patid']
				x.orderno       = line['orderno']
				x.newid         = line['newid']
				x.studyid       = line['studyid']
				x.state_id_no   = line['state_id_no']
				x.case_control_type = line['case_control_type']
				x.related_case_childid = line['related_case_childid']
				x.created_at         = line['created_at']

				unless line['vital_status_id'].blank?
					x.vital_status_id = line['vital_status_id']
#				else leave as database default
				end
			end

			if line['subject_type_id'].to_i == StudySubject.subject_type_case_id
				patient = Patient.new do |m|
					m.admit_date = ( line['admit_date'].blank?
						) ? nil : Time.parse(line['admit_date'])
					m.diagnosis_id    = line['diagnosis_id']
					m.other_diagnosis = line['other_diagnosis']




					#	1 record is missing organization_id so must do this. (9999999)
#					m.organization_id = line['organization_id'].to_dk_or_i
					m.organization_id = line['organization_id']





					m.hospital_no     = line['hospital_no']

#	TODO deal with incorrect value 9 in was_* fields

					m.was_previously_treated = line['was_previously_treated'].to_nil_or_999_or_i
#					m.was_previously_treated = line['was_previously_treated']
#	kinda pointless as is set in callback
#					m.was_under_15_at_dx     = line['was_under_15_at_dx'].to_nil_or_999_or_i
					m.was_under_15_at_dx     = line['was_under_15_at_dx']

					m.raf_zip                = line['raf_zip']
					m.raf_county             = line['raf_county']
					m.created_at             = line['created_at']
				end
				s.patient = patient
			end
			s.save

			if s.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: #{s.errors.full_messages.to_sentence}"
				error_file.puts line
				error_file.puts
			else
				s.reload
				compare_subject_and_line(s,line)
			end
		end	#	FasterCSV.open
		error_file.close
	end		#	task :subjects => :odms_import_base do





	namespace :compare do

		desc "Compare data from subjects.csv file"
		task :subjects => :odms_import_base do
			puts "Comparing subjects"
			warn_file = File.open('subjects_warnings.txt','w')	#	overwrite existing
			#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
			(f=FasterCSV.open(SUBJECTS_CSV, 'rb',{ :headers => true })).each do |line|
				puts "Processing line #{f.lineno}"
				puts line
	
				s = StudySubject.where(:subjectid => line['subjectid'])
				if s
					compare_subject_and_line(s,line,warn_file)
				else
					warn_file.puts "Subject not found with subjectid:#{line['subjectid']}"
					warn_file.puts
				end
	
			end	#	FasterCSV.open
			warn_file.close
		end		#	task :subjects => :odms_import_base do

	end	#	namespace :compare do

end	#	namespace :odms_import do





def compare_subject_and_line(s,line,warn_file=nil)
#
#	TODO Add a "warnings" file containing some of these changes?
#			Some may actually occur on the import of another subject though.
#			Would have to loop to loop through the csv file again to actually compare.
#

	assert s.subject_type_id == line['subject_type_id'].to_nil_or_i,
		"subject_type_id mismatch:#{s.subject_type_id}:#{line['subject_type_id']}:"

	if line['vital_status_id'].blank?
		assert s.vital_status_id == 1,
			"Vital Status not set to default"
	else
		assert s.vital_status_id.to_s == line['vital_status_id'],
			"Vital Status mismatch:#{s.vital_status_id}:#{line['vital_status_id']}:"
	end

#	TODO 	TRUE / FALSE
	assert s.do_not_contact == line['do_not_contact'].to_nil_or_boolean,
		'Do Not Contact mismatch'
	assert s.sex == line['sex'],
		"sex mismatch:#{s.sex}:#{line['sex']}:"
	assert s.hispanicity_id == line['hispanicity_id'].to_nil_or_i,
		"hispanicity_id mismatch:#{s.hispanicity_id}:#{line['hispanicity_id']}:"
	assert s.mother_hispanicity_id == line['mother_hispanicity_id'].to_nil_or_i,
		"mother_hispanicity_id mismatch:#{s.mother_hispanicity_id}:#{line['mother_hispanicity_id']}:"
	assert s.father_hispanicity_id == line['father_hispanicity_id'].to_nil_or_i,
		"father_hispanicity_id mismatch:#{s.father_hispanicity_id}:#{line['father_hispanicity_id']}:"

#	TODO not always be true due to callbacks
#				if line['reference_date'].blank?
#					assert s.reference_date.nil?, 'reference_date not nil'
#				else
#					assert !s.reference_date.nil?, 'reference_date nil'
#					assert s.reference_date == Time.parse(line['reference_date']),
#						"reference_date mismatch:#{s.reference_date}:#{line['reference_date']}:"
#				end

	unless warn_file.nil?

		#	reference_date is changed to Patient#admit_date for all matching matchingid
		#		when matchingid or admit_date changes
		#	FYI ... During import, the case may not exist yet.
		matching_case = if s.is_case?
			s
		else
#			matching_cases = StudySubject.find(:all,	#	should only be one
#				:conditions => { 
#					:subject_type_id => StudySubject.subject_type_case_id,
#					:matchingid      => s.matchingid
#				})
			matching_cases = StudySubject.where(
				:subject_type_id => StudySubject.subject_type_case_id).where(
				:matchingid      => s.matchingid)
			#	still in testing so there isn't always one
			raise "There can be only One!" if matching_cases.length > 1
#						raise "There must be One!" if matching_cases.length < 1
			( matching_cases.length == 1 ) ? matching_cases[0] : nil
		end

		if line['reference_date'].blank? 
			if !s.reference_date.nil?
				warn_file.puts s.inspect
				warn_file.puts "-reference_date not nil:"
				warn_file.puts "-reference_date csv :#{line['reference_date']}:" 
				warn_file.puts "-reference_date db  :#{s.reference_date}:"
				if matching_case
					warn_file.puts "-case admit_date    :#{matching_case.admit_date}:"
				else
					warn_file.puts "-case admit_date    :no case found:"
				end
				warn_file.puts
			end
		else
			if s.reference_date != Time.parse(line['reference_date']).to_date
				warn_file.puts s.inspect
				warn_file.puts "-reference_date mismatch:"
				warn_file.puts "-reference_date csv :#{line['reference_date']}:" 
				warn_file.puts "-reference_date db  :#{s.reference_date}:"
				if matching_case
					warn_file.puts "-case admit_date    :#{matching_case.admit_date}:"
				else
					warn_file.puts "-case admit_date    :no case found:"
				end
				warn_file.puts
			end
		end
	end

	assert s.first_name == line['first_name'],
		"first_name mismatch:#{s.first_name}:#{line['first_name']}:"
	assert s.middle_name == line['middle_name'],
		"middle_name mismatch:#{s.middle_name}:#{line['middle_name']}:"
	assert s.last_name == line['last_name'],
		"last_name mismatch:#{s.last_name}:#{line['last_name']}:"
	assert s.maiden_name == line['maiden_name'],
		"maiden_name mismatch:#{s.maiden_name}:#{line['maiden_name']}:"

	if line['dob'].blank?
		assert s.dob.nil?, 'dob not nil'
	else
		assert !s.dob.nil?, 'dob nil'
		assert s.dob == Time.parse(line['dob']).to_date,
			"dob mismatch:#{s.dob}:#{line['dob']}:"
	end
	if line['died_on'].blank?
		assert s.died_on.nil?, 'died_on not nil'
	else
		assert !s.died_on.nil?, 'died_on nil'
		assert s.died_on == Time.parse(line['died_on']).to_date,
			"died_on mismatch:#{s.died_on}:#{line['died_on']}:"
	end

	assert s.mother_first_name == line['mother_first_name'],
		"mother_first_name mismatch:#{s.mother_first_name}:#{line['mother_first_name']}:"
	assert s.mother_maiden_name == line['mother_maiden_name'],
		"mother_maiden_name mismatch:#{s.mother_maiden_name}:#{line['mother_maiden_name']}:"
	assert s.mother_last_name == line['mother_last_name'],
		"mother_last_name mismatch:#{s.mother_last_name}:#{line['mother_last_name']}:"
	assert s.father_first_name == line['father_first_name'],
		"father_first_name mismatch:#{s.father_first_name}:#{line['father_first_name']}:"
	assert s.father_last_name == line['father_last_name'],
		"father_last_name mismatch:#{s.father_last_name}:#{line['father_last_name']}:"
	assert s.birth_year == line['birth_year'],
		"birth_year mismatch:#{s.birth_year}:#{line['birth_year']}:"


	pa = s.patient
	if s.subject_type == SubjectType['case']
		pa.reload

#	TODO may not always be true
		if line['admit_date'].blank?
			assert pa.admit_date.nil?, 'admit_date not nil'
		else
			assert !pa.admit_date.nil?, 'admit_date nil'
			assert pa.admit_date == Time.parse(line['admit_date']).to_date,
				'admit_date mismatch'
		end

#					unless warn_file.nil?
#						if pa.admit_date != Time.parse(line['admit_date']).to_date
##	don't think that this happens
#raise "i guess that it does"
#							warn_file.puts s.inspect
#							warn_file.puts pa.inspect
#							warn_file.puts "-admit_date mismatch:"
#							warn_file.puts "-admit_date csv :#{line['admit_date']}:" 
#							warn_file.puts "-admit_date db  :#{pa.admit_date}:"
#							warn_file.puts 
#						end
#					end


		assert pa.diagnosis_id == line['diagnosis_id'].to_nil_or_i,
			"diagnosis_id mismatch:#{pa.diagnosis_id}:#{line['diagnosis_id']}:"
		assert pa.raf_zip.only_numeric == line['raf_zip'].only_numeric,
			"raf_zip mismatch:#{pa.raf_zip}:#{line['raf_zip']}:"
		assert pa.raf_county == line['raf_county'],
			"raf_county mismatch:#{pa.raf_county}:#{line['raf_county']}:"
		assert pa.hospital_no == line['hospital_no'],
			"hospital_no mismatch:#{pa.hospital_no}:#{line['hospital_no']}:"


# TODO
#					assert pa.organization_id == line['organization_id'].to_dk_or_i,
		assert pa.organization_id == line['organization_id'].to_nil_or_i,
			"organization_id mismatch:#{pa.organization_id}:#{line['organization_id']}:"


		assert pa.other_diagnosis == line['other_diagnosis'],
			"other_diagnosis mismatch:#{pa.other_diagnosis}:#{line['other_diagnosis']}:"

#	TODO problem with the 9 and 999 issue as well
#					assert pa.was_previously_treated == line['was_previously_treated'].to_nil_or_i,
		assert pa.was_previously_treated == line['was_previously_treated'].to_nil_or_999_or_i,
			"was_previously_treated mismatch:#{pa.was_previously_treated}:#{line['was_previously_treated']}:"
#	TODO probably won't be true all the time
#					assert pa.was_under_15_at_dx == line['was_under_15_at_dx'],
#						'was_under_15_at_dx mismatch'

		unless warn_file.nil?
			if pa.was_under_15_at_dx != line['was_under_15_at_dx'].to_nil_or_i
				warn_file.puts s.inspect
				warn_file.puts pa.inspect
				warn_file.puts "was_under_15_at_dx mismatch:"
				warn_file.puts "was_under_15_at_dx csv :#{line['was_under_15_at_dx']}:" 
				warn_file.puts "was_under_15_at_dx db  :#{pa.was_under_15_at_dx}:"
				warn_file.puts "dob db           :#{s.dob}:"
				warn_file.puts "admit_date db    :#{pa.admit_date}:"
				warn_file.puts "admit_date - dob :#{((pa.admit_date.to_date - s.dob.to_date).to_f/365)}:"
				warn_file.puts
			end
		end

	else
		assert pa.nil?, 'Patient for non-case'
	end

	assert s.subjectid == line['subjectid'],
		"subjectid mismatch:#{s.subjectid}:#{line['subjectid']}:"
	assert s.childid.to_s == line['childid'],
		"childid mismatch:#{s.childid}:#{line['childid']}:"
	assert s.icf_master_id == line['icf_master_id'],
		"icf_master_id mismatch:#{s.icf_master_id}:#{line['icf_master_id']}:"
	assert s.childidwho == line['childidwho'],
		"childidwho mismatch:#{s.childidwho}:#{line['childidwho']}:"
	assert s.familyid == line['familyid'],
		"familyid mismatch:#{s.familyid}:#{line['familyid']}:"
	assert s.matchingid == line['matchingid'],
		"matchingid mismatch:#{s.matchingid}:#{line['matchingid']}:"
	assert s.patid == line['patid'],
		"patid mismatch:#{s.patid}:#{line['patid']}:"
	assert s.case_control_type == line['case_control_type'],
		"case_control_type mismatch:#{s.case_control_type}:#{line['case_control_type']}:"
	assert s.orderno == line['orderno'].to_nil_or_i,
		"orderno mismatch:#{s.orderno}:#{line['orderno']}:"
	assert s.newid == line['newid'],
		"newid mismatch:#{s.newid}:#{line['newid']}:"
	assert s.studyid == line['studyid'],
		"studyid mismatch:#{s.studyid}:#{line['studyid']}:"
	assert s.related_case_childid == line['related_case_childid'],
		"related_case_childid mismatch:#{s.related_case_childid}:#{line['related_case_childid']}:"
	assert s.state_id_no == line['state_id_no'],
		"state_id_no mismatch:#{s.state_id_no}:#{line['state_id_no']}:"
end
