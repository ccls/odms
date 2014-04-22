namespace :app do
namespace :study_subjects do

	task :checkup => :environment do
		begin
			puts "Checking consistancy based on matchingids"
			StudySubject.group(:matchingid).count.each do |matchingid,count|
				puts matchingid
				subjects = StudySubject.where(:matchingid => matchingid)
				children = StudySubject.children.where(:matchingid => matchingid)

				phases = subjects.collect(&:phase)
				if phases.uniq.length != 1
					#	odd that when inconsistent, all controls are set and case is nil?
					#	controls are newer (after my auto set phase to 5)
					#	mothers in the phase check as well?
					puts "phase is inconsistent"
					puts phases.inspect
				end

				sexes = children.collect(&:sex)
				if sexes.uniq.length != 1
					puts "children's sex is inconsistent"
					puts sexes.inspect
				end

				assert subjects.collect(&:reference_date).uniq.length == 1, subjects.collect(&:reference_date)
				reference_dates = subjects.collect(&:reference_date)
				if reference_dates.uniq.length != 1
					puts "reference_date is inconsistent"
					puts reference_dates.uniq.inspect
				end

				#	assert subjects.collect(&:patid).uniq.length == 1, subjects.collect(&:patid)
				patids = children.collect(&:patid)
				if patids.uniq.length != 1
					puts "patid is inconsistent"
					puts patids.uniq.inspect
				end

				#
				#	dob's can be plus or minus a couple days for hard to match cases, but the same for most
				#
				dobs = children.collect(&:dob)
				dobs -= [Date.parse('Jan 1, 1900')]
				#if dobs.uniq.length != 1
				#	puts "dob is inconsistent"
				#	puts dobs.uniq.inspect
				#end
				if(( dobs.sort.last.mjd - dobs.sort.first.mjd ) > 7 )
					puts "children's dobs are too inconsistent"
					puts dobs.sort.inspect
				end unless dobs.empty?
			end	#	StudySubject.group(:matchingid).count.each do |matchingid,count|
		end #if false

	end	#	task :checkup => :environment do


	task :duplicate_subject_check => :environment do
		puts "Searching for duplicated subjects based on dob"
		attrs = %w( childid patid subjectid state_id_no dob sex subject_type last_name first_name )
		puts attrs.to_csv
		StudySubject.children.group(:dob).count.each do |dob,count|
			next if dob.nil?
			next if dob < Date.parse('Feb 1,1900')	#	1/1/1900 is "Don't Know"
			subjects = StudySubject.where(:dob => dob)

			#	duplicate based on what other comparison?

			#	same dob, sex, names could be different
			subjects.each do |subject|
				duplicates = StudySubject.where(:dob => dob)
					.where(:sex => subject.sex)
					.where(:last_name => subject.last_name)
					.where(:first_name => subject.first_name)
				if duplicates.count > 1
					duplicates.each do |dup|
						puts attrs.collect{|a|dup[a]}.to_csv
					end
				end
			end
		end
	end	#	task :duplicate_subject_check => :environment do

	task :duplicate_state_id_no_check_2 => :environment do
		filename = "tracking2k/tChildInfo.csv"
		attrs = %w( childid patid subjectid state_id_no dob sex subject_type last_name first_name )
		wrong_count = 0
		CSV.open( filename, 'rb',{ :headers => true }).each do |line|
			next if line['StateIDNo'].blank?
			next if ["non-CA","Non-CA","not found"].include?( line['StateIDNo'] )

			subjects = StudySubject.with_childid(line['ChildId'])
			raise if subjects.empty?
			subject = subjects.first

			next if subject.state_id_no == line['StateIDNo']

			wrong_subjects = StudySubject.where(:state_id_no => line['StateIDNo'])
			unless wrong_subjects.empty?
				wrong_count +=1
				puts
				puts "Found other subject with this state id no:#{line['StateIDNo']}:"
				puts line
				puts attrs.to_csv
				puts attrs.collect{|a|subject[a]}.to_csv
				puts attrs.collect{|a|wrong_subjects[0][a]}.to_csv
				puts
			end

		end	#	CSV.open( filename, 'rb',{ :headers => true }).each do |line|
		puts "Found #{wrong_count} inconsistant state id nos."
	end	#	task :duplicate_state_id_no_check_2 => :environment do

	task :duplicate_state_id_no_check => :environment do
		filename = "tracking2k/tChildInfo.csv"
		state_id_nos = Hash.new(0)
		CSV.open( filename, 'rb',{ :headers => true }).each do |line|
			state_id_nos[line['StateIDNo']] += 1
		end	#	CSV.open( filename, 'rb',{ :headers => true }).each do |line|
#		f=CSV.open( filename, 'rb')
#		puts f.gets.to_csv
#		f.close
		puts "subjectid,ChildId,PatID,StateIDNo,Dob,Phase,Sex,Fname,Lname"
#		puts state_id_nos.select{|k,v| v>1}.inspect
		CSV.open( filename, 'rb',{ :headers => true }).each do |line|
			next if line['StateIDNo'].blank?
			next if ["non-CA","Non-CA","not found"].include?( line['StateIDNo'] )
			next if state_id_nos[line['StateIDNo']] <= 1
			puts [line['subjectid'],line['ChildId'],line['PatID'],line['StateIDNo'],
				line['Dob'],line['Phase'],line['Sex'],line['Fname'],line['Lname']].to_csv
		end	#	CSV.open( filename, 'rb',{ :headers => true }).each do |line|
	end	#	task :duplicate_state_id_no_check => :environment do

	task :check_cases_with_phase_nil => :environment do
		StudySubject.controls.where(:phase => nil).each do |s|
			phases = StudySubject.where(:matchingid => s.matchingid).collect(&:phase)
			if phases.uniq.compact.length > 1
			#	So many inconsistencies!
				puts s.matchingid
				puts phases.inspect
			end
		end
	end	#	task :check_cases_with_phase_nil => :environment do




	task :fill_in_the_nil_phases => :environment do
		raise "This task has been run and disabled."
		puts StudySubject.where(StudySubject.arel_table[:phase].not_eq(nil)).count
		StudySubject.where(StudySubject.arel_table[:phase].not_eq(nil)).find_each do |s|
			subjects = StudySubject.where(:matchingid => s.matchingid)
			phases = subjects.collect(&:phase)
			if phases.uniq.compact.length == 1 && phases.uniq.length == 1
				puts "already sunc #{s.matchingid} #{phases.uniq.inspect}"
			elsif phases.uniq.compact.length == 1 && phases.uniq.length == 2
				#	just one non-nil phase for group
				puts "------ SYNCABLE! #{s.matchingid} #{phases.uniq.inspect}"
				phase = phases.uniq.compact.first
				subjects.each do |subject|
					if subject.phase.nil?
						puts "Updated phase to #{phase}"
						subject.update_attributes!(:phase => phase)	
						#	found a father_hispanicity validation failure?
						#unless subject.update_attributes(:phase => phase)
						#	puts subject.errors.full_messages.to_sentence
						#	puts subject.inspect
						#	raise 'hell'
						#end
						puts "Create operational event"
						subject.operational_events.create!(
							:occurred_at => DateTime.current,
							:project_id => Project['ccls'].id,
							:operational_event_type_id => OperationalEventType['datachanged'].id,
							:description => "Phase set to #{phase} based on others with this matchingid")
					else
						puts "This subject's phase not nil. Skipping."
					end
				end
			else
				puts "unsyncable #{s.matchingid} #{phases.inspect}"
			end
		end
		puts StudySubject.where(StudySubject.arel_table[:phase].not_eq(nil)).count
		Sunspot.commit
	end	#	task :fill_in_the_nil_phases => :environment do

	task :update_to_phase_5_based_on_reference_date => :environment do
		raise "This task has been run and disabled."
		cases = StudySubject.cases.where(StudySubject.arel_table[:reference_date].gteq(Date.parse('1/1/2011')))
			.where(StudySubject.arel_table[:reference_date].lteq(Date.parse('7/31/2011')))
		raise "Expected exactly 102" if cases.length != 102
		cases.each do |c|
			StudySubject.where(:matchingid => c.matchingid).each do |subject|
				if subject.phase != 5
					puts "Updated phase to 5"
					subject.update_attributes!(:phase => 5)
					puts "Create operational event"
					subject.operational_events.create!(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['datachanged'].id,
						:description => "Phase set to 5 based on reference date inclusively between 1/1/2011 and 7/31/2011")
				end
			end
		end
		Sunspot.commit
	end	#	task :update_phases_based_on_reference_date => :environment do

	task :update_phases_from_tChildInfo => :environment do
		raise "This task has been run and disabled."
		filename = "tracking2k/tChildInfo.csv"
		CSV.open( filename, 'rb',{ :headers => true }).each do |line|
			subjects = StudySubject.with_childid(line['ChildId'])
			raise if subjects.empty?
			subject = subjects.first
			if !line['Phase'].blank? && ( subject.phase != line['Phase'].to_i )	#	IMPORT about 5500!
				puts "#{subject.subjectid},#{subject.phase},#{line['Phase']}"
				if subject.phase.present? && subject.phase > line['Phase'].to_i
					puts "DOWN PHASE CHANGE!!!!! SKIPPING"		#	WOULD CHANGE FROM 5 TO 4!?????
					#puts subject.reference_date
				else
					puts "Updated phase to #{line['Phase']}"
					subject.update_attributes!(:phase => line['Phase'])
					puts "Create operational event"
					subject.operational_events.create!(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['datachanged'].id,
						:description => "Phase set to #{line['Phase']} based on tracking2k/tChildInfo.csv")
				end

			end
		end	#	CSV.open( filename, 'rb',{ :headers => true }).each do |line|
		Sunspot.commit
	end	#	task :update_phases_from_tChildInfo => :environment do




	task :child_info_check => :environment do
#Columns are ChildId, PatID, ICFMasterID, Type, OrderNo, Eligibl, Consen, Consdate, ConsVersion, WhichConsent, vaccine_releases_received, StateID#, Dob, SSN, Sex, Fname, Mname, Lname, Language, Notes, Mofname, Molname, Mosname, Momname, Fafname, Falname, Saqsent, Saqback, RefDate, Phase, Bornca, Postdue, Postsent, Intassdu, Intass, CashGave, Intid, Intret, Bclistdu, Bclistrq, Requested Results, Job List To Reviewer, Job List Returned, Job Module Int Assign, Job Module Interviewer, Job Module Int Returned, FoodQLang, SelectNo, Chose, Nominator, EntDate, Birth County, BirthCountyNonCA, Age, InterviewDate, InterviewLanguage, BreastFed, Flistopt, Numfrs, Outcome, OutForReview, DateOut, InitialsOfReviewer, EditingComplete, SampleNo, LocationID, Requested, Received, BCOutcome, BCOutcomeDate, CHDSLetterOut, CHDSBack, ControlFount, SRCOut, SRCBack, DelayLtrSent, DelayLtrSnt-2nd, Change, InterimPending, InterimCase, InterviewEntered, InterviewEnteredHSQ, InterviewEnteredHPI, InterviewEnteredHIS, InterviewEnteredDS, InterviewEnteredWS, CreateDate, CreateTime, HomeAgeAtIntrv, Active, Retro, StateIDNo, FutureUseSpec, SearchStopped4, SearchStopped5, SearchStopped6, SearchStoppedB, VitalStatus, VitalStatusDate, DoNotContact, subjectid, addedToSubjects, OptOut_ShareResearchers, OptOut_ContactInFuture, OptOut_GeneralInfo, OptOut_ProvideSaliva, RevokeUseOfSamples, RevokeUseDate, generational_suffix, father_generational_suffix, Dod, childid_txt
		filename = "tracking2k/tChildInfo.csv"
		inconsistancies_filename = "#{File.basename(filename,File.extname(filename))}.inconsistancies"
		inconsistancies = File.open(inconsistancies_filename,'w')

		CSV.open( filename, 'rb',{ :headers => true }).each do |line|
			puts line
#			inconsistancies.puts line.to_s.gsub("\xC3",'')	#.force_encoding('UTF-8').encode
#			inconsistancies.puts line.to_s.gsub('\xC3','')	#.force_encoding('UTF-8').encode
#			inconsistancies.puts line.to_s.gsub('ñ','')

			subjects = StudySubject.with_childid(line['ChildId'])
			raise if subjects.empty?
			subject = subjects.first

			if !line['subjectid'].blank? && ( subject.subjectid.to_s != line['subjectid'] )
				inconsistancies.puts "SubjectID"
				inconsistancies.puts subject.subjectid
				inconsistancies.puts line['subjectid']
			end	#	NONE

			if subject.patid != line['PatID']
				inconsistancies.puts "PatID"
				inconsistancies.puts subject.patid
				inconsistancies.puts line['PatID']
			end	#	NONE

			if subject.case_control_type != line['Type']
				inconsistancies.puts "case_control_type"
				inconsistancies.puts subject.case_control_type
				inconsistancies.puts line['Type']
			end	#	NONE

			if subject.orderno.to_s != line['OrderNo'].to_s
				inconsistancies.puts "orderno"
				inconsistancies.puts subject.orderno
				inconsistancies.puts line['OrderNo']
			end	#	NONE

			if subject.do_not_contact != line['DoNotContact'].to_boolean
				inconsistancies.puts "do_not_contact"
				inconsistancies.puts subject.do_not_contact
				inconsistancies.puts line['DoNotContact']
			end	#	NONE

			if !line['ICFMasterID'].blank? && ( subject.icf_master_id != line['ICFMasterID'] )	#	DO NOT IMPORT!
				inconsistancies.puts "#{subject.subjectid},icf_master_id," <<
					"#{subject.icf_master_id},#{line['ICFMasterID']}"
			end	#	NONE

			if !line['Sex'].blank? && ( subject.sex != line['Sex'] )	#	IMPORT!
				inconsistancies.puts "#{subject.subjectid},sex," <<
					"#{subject.sex},#{line['Sex']}"
			end	#	NONE




			if !line['Dob'].blank? && ( subject.dob != Date.parse(line['Dob']) )
				inconsistancies.puts "#{subject.subjectid},dob," <<
					"#{subject.dob},#{Date.parse(line['Dob']).to_s}"
			end

			if !line['RefDate'].blank? && ( subject.reference_date != Date.parse(line['RefDate']) )
				inconsistancies.puts "#{subject.subjectid},reference_date," <<
					"#{subject.reference_date},#{Date.parse(line['RefDate']).to_s}"
			end

			#
			#	Use line['StateIDNo']
			#
			#	Use line['StateIDNo'] and not line['StateID#'] (mostly blank unless same)
			#
			#	PROBLEM!
			#rake csv:show_column_values csv_file=tracking2k/tChildInfo.csv columns=StateID#
			#	shows that some of StateID# are NOT UNIQUE (but we are ignoring them, yes?)
			#
			#	Sadly, same for StateIDNo.  Hmm
			#
			#
			#			if !line['StateID#'].blank? && !line['StateIDNo'].blank? && ( line['StateID#'] != line['StateIDNo'] )
			#			if ( line['StateID#'] != line['StateIDNo'] )
			#				inconsistancies.puts "StateID# different than StateIDNo - #{line['StateID#']},#{line['StateIDNo']}"
			#			end
			#
			#StateID# different than StateIDNo - 92-134187,92-134178	#!!!!! really different. last is in odms.
			#StateID# different than StateIDNo - non-CA,Non-CA
			#StateID# different than StateIDNo - 03000474,03-000474
			#StateID# different than StateIDNo - 05015985,05-015985
			#StateID# different than StateIDNo - 03027985,03-027985
			#
			#if !line['StateID#'].blank? && ( subject.state_id_no != line['StateID#'] )
			#	inconsistancies.puts "#{subject.subjectid},state_id_no 1," <<
			#		"#{subject.state_id_no},#{line['StateID#']}"
			#end
			#
			#if !line['StateIDNo'].blank? && ( subject.state_id_no != line['StateIDNo'] )
			#	inconsistancies.puts "#{subject.subjectid},state_id_no 2,"<<
			#		"#{subject.state_id_no},#{line['StateIDNo']}"
			#end

			#	Already imported separatly
			#if !line['Phase'].blank? && ( subject.phase != line['Phase'].to_i )	#	IMPORT about 5500!
			#	inconsistancies.puts "#{subject.subjectid},phase," <<
			#		"#{subject.phase},#{line['Phase']}"
			##	subject.update_attributes!(:phase => line['Phase'])
			#end

			if !line['Eligibl'].blank? && ( YNDK[subject.ccls_enrollment.is_eligible] != line['Eligibl'] )
				inconsistancies.puts "#{subject.subjectid},eligible," <<
					"#{YNDK[subject.ccls_enrollment.is_eligible]},#{line['Eligibl']}"
			end

			if !line['Consen'].blank? && ( YNDK[subject.ccls_enrollment.consented] != line['Consen'] )
				inconsistancies.puts "#{subject.subjectid},consented," <<
					"#{YNDK[subject.ccls_enrollment.consented]},#{line['Consen']}"
			end


#	Eligibl
#	Consen
#	Consdate

		end
		inconsistancies.close
	end

	task :update_interview_date => :environment do
		raise "This task has been run and disabled."

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
