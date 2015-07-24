require 'csv'

namespace :app do
namespace :birth_data do

#	all birth record

#	subjectid, patid, subject_type, state_id_no, birth_year  bd derive, regist, filename


	task :reimport_boolean_values => :environment do
		Dir["birth_data/*/*.csv"].each do |birth_data_file|
			file_name = File.basename(birth_data_file)
			puts file_name

			#	match line count and record count in database with this :birth_data_file_name
			#puts (total_lines( birth_data_file,'rb:bom|utf-8') - 1 )
			#puts BirthDatum.where( :birth_data_file_name => file_name ).count

			(f=CSV.open( birth_data_file, 'rb:bom|utf-8',{ :headers => true })).each do |line|

				next if line['state_registrar_no'].blank?

				count = BirthDatum.where( :birth_data_file_name => file_name,
					:state_registrar_no => line['state_registrar_no'] ).count

				raise 'hell' if count != 1

				bd = BirthDatum.where( :birth_data_file_name => file_name,
					:state_registrar_no => line['state_registrar_no'] ).first

				puts "#{line['vacuum_attempt_unsuccessful']}:#{line['mother_received_wic']}:" <<
					"#{line['forceps_attempt_unsuccessful']}:#{line['found_in_state_db']}:" <<
					"#{bd.vacuum_attempt_unsuccessful}:#{bd.mother_received_wic}:" <<
					"#{bd.forceps_attempt_unsuccessful}:#{bd.found_in_state_db}"

				bd.update_attributes!( 
					'vacuum_attempt_unsuccessful' => line['vacuum_attempt_unsuccessful'],
					'mother_received_wic' => line['mother_received_wic'],
					'forceps_attempt_unsuccessful' => line['forceps_attempt_unsuccessful'],
					'found_in_state_db' => line['found_in_state_db'] )

			end	#	(f=CSV.open( birth_data_file, 'rb:bom|utf-8',
		end	#	Dir["birth_data/*/*.csv"].each do |birth_data_file|
	end	#	task :reimport_boolean_values => :environment do


	task :id_number_report_2 => :environment do
		cols = %w(subjectid patid subject_type birth_year state_id_no state_registrar_no 
			local_registrar_no derived_state_file_no_last6 derived_local_file_no_last6 
			birth_data_file_name )
		puts cols.to_csv
		BirthDatum.find_each do |bd|
			values = cols.collect do |col|
				" #{bd.send(col)}"
			end
			puts values.to_csv(:force_quotes => true)
		end
	end	#	task :id_number_report => :environment do




	task :dump_all_phase_5 => :environment do
		column_names = BirthDatum.column_names
		puts (column_names + %w( ss_icf_master_id ss_subjectid ss_interview_completed_on 
			ss_reference_date ss_mother_icf_master_id ss_mother_subjectid 
			ss_birth_data_count ss_phase )).to_csv
		requires_leading_space = %w( complications_labor_delivery 
			complications_pregnancy state_registrar_no 
			derived_state_file_no_last6 derived_local_file_no_last6 )

		#	Normal
		BirthDatum.joins(:study_subject).where(:'study_subjects.phase' => 5).find_each do |bd|

		#	20150121 - Alice's request again
		#	20140603 - Alice's data request (phase 4 AND 5)
		#BirthDatum.joins(:study_subject).find_each do |bd|
		#BirthDatum.joins(:study_subject).where(:'study_subjects.phase' => [4,5]).find_each do |bd|
		#	20140603 - Alice's data request (subjects with multiple birth data records)
		#BirthDatum.joins(:study_subject).where(:'study_subjects.phase' => 5).where(StudySubject.arel_table[:birth_data_count].gt(1)).find_each do |bd|


			out = []

#jakewendt@fxdgroup-169-229-196-225 : odms 521> bundle exec rake app:birth_data:dump_all_phase_5
#id,birth_datum_update_id,study_subject_id,master_id,found_in_state_db,birth_state,match_confidence,case_control_flag,length_of_gestation_weeks,father_race_ethn_1,father_race_ethn_2,father_race_ethn_3,mother_race_ethn_1,mother_race_ethn_2,mother_race_ethn_3,abnormal_conditions,apgar_1min,apgar_5min,apgar_10min,birth_order,birth_type,birth_weight_gms,complications_labor_delivery,complications_pregnancy,
#county_of_delivery,daily_cigarette_cnt_1st_tri,daily_cigarette_cnt_2nd_tri,daily_cigarette_cnt_3rd_tri,daily_cigarette_cnt_3mo_preconc,dob,first_name,middle_name,last_name,father_industry,father_dob,father_hispanic_origin_code,father_first_name,father_middle_name,father_last_name,father_occupation,father_yrs_educ,fetal_presentation_at_birth,forceps_attempt_unsuccessful,last_live_birth_on,last_menses_on,last_termination_on,length_of_gestation_days,live_births_now_deceased,live_births_now_living,local_registrar_district,local_registrar_no,method_of_delivery,month_prenatal_care_began,mother_residence_line_1,mother_residence_city,mother_residence_county,mother_residence_county_ef,mother_residence_state,mother_residence_zip,mother_weight_at_delivery,mother_birthplace,mother_birthplace_state,mother_dob,mother_first_name,mother_middle_name,mother_maiden_name,mother_height,mother_hispanic_origin_code,mother_industry,mother_occupation,mother_received_wic,mother_weight_pre_pregnancy,mother_yrs_educ,ob_gestation_estimate_at_delivery,prenatal_care_visit_count,sex,state_registrar_no,term_count_20_plus_weeks,term_count_pre_20_weeks,vacuum_attempt_unsuccessful,created_at,updated_at,control_number,father_ssn,mother_ssn,birth_data_file_name,childid,subjectid,deceased,case_dob,ccls_import_notes,study_subject_changes,derived_state_file_no_last6,derived_local_file_no_last6,ss_icf_master_id,ss_subjectid,ss_interview_completed_on,ss_reference_date,ss_mother_icf_master_id,ss_mother_subjectid,ss_birth_data_count,ss_phase

			column_names.each{ |c| out.push (
				( requires_leading_space.include?(c) ) ? " #{bd[c]}" : bd[c] ) }
			out.push bd.study_subject.icf_master_id
			out.push " #{bd.study_subject.subjectid}"
			out.push bd.study_subject.ccls_enrollment
				.try(:interview_completed_on).try(:strftime,'%m/%d/%Y')
			out.push bd.study_subject.reference_date.try(:strftime,'%m/%d/%Y')
			out.push bd.study_subject.mother.try(:icf_master_id)
			out.push " #{bd.study_subject.mother.try(:subjectid)}"
			out.push bd.study_subject.birth_data_count
			out.push bd.study_subject.phase
			puts out.to_csv
		end
	end	#	task :dump_all_phase_5 => :environment do

	task :dob_check => :environment do
		BirthDatum.find_each do |bd|
			if( bd.study_subject.present? and bd.case_dob.present? )
				if( bd.study_subject.dob != bd.case_dob )
					puts "#{bd.study_subject.try(:dob)},#{bd.case_dob}"
				end
			end
		end	#	BirthDatum.find_each do |bd|
	end	#	task :state_id_number_import => :environment do


	task :state_id_number_import => :environment do
		csv_out = CSV.open('state_id_number_import.csv','w')
		csv_out << %w( state_id_no current_subject_type current_patid current_subjectid current_icf_master_id
			new_subject_type new_patid new_subjectid new_icf_master_id )
		BirthDatum.find_each do |bd|
			puts "derived_state_file_no_last6 blank" if bd.derived_state_file_no_last6.blank?
			puts "case_dob blank"                    if bd.case_dob.blank?
			puts "study_subject blank"               if bd.study_subject.blank?
			puts "study_subject state_id_no blank"   if bd.study_subject.try(:state_id_no).blank?

			if( bd.derived_state_file_no_last6.present? and bd.case_dob.present? and
					bd.study_subject.present? and bd.study_subject.state_id_no.blank? )
				state_id_no = "#{bd.case_dob.year.to_s[-2..-1]}-#{bd.derived_state_file_no_last6}"
				puts state_id_no
				begin
					bd.study_subject.update_attributes!(:state_id_no => state_id_no)
				rescue
					csv_row = []
					csv_row << state_id_no
					puts (s = bd.study_subject).inspect
					csv_row << s.subject_type
					csv_row << s.patid
					csv_row << s.subjectid
					csv_row << s.icf_master_id
					puts (s = StudySubject.where(:state_id_no => state_id_no).first).inspect
					csv_row << s.subject_type
					csv_row << s.patid
					csv_row << s.subjectid
					csv_row << s.icf_master_id
					csv_out << csv_row
				end
			end
		end	#	BirthDatum.find_each do |bd|
		csv_out.close
	end	#	task :state_id_number_import => :environment do


	task :id_number_report => :environment do
		cols = %w(id study_subject_id birth_data_file_name state_registrar_no 
			derived_state_file_no_last6 derived_local_file_no_last6)
		puts (cols+%w(state_first_then_local state_last_after_unknown)).join(',')
		BirthDatum.find_each do |bd|
			values = cols.collect do |col|
				bd.send(col)
			end

			statefirst = sprintf("%d", "#{bd.derived_state_file_no_last6}#{bd.derived_local_file_no_last6}".to_i)
			values.push ( ( bd.state_registrar_no.to_s.length > 6 && bd.state_registrar_no == statefirst ) ? 'TRUE' : '-' )
			values.push ( ( bd.state_registrar_no.to_s.length > 6 && bd.state_registrar_no.to_s[-6..-1] == bd.derived_state_file_no_last6 ) ? 'TRUE' : '-' )

			puts values.join(',')
		end
	end	#	task :id_number_report => :environment do

	task :check_state_registrar_no => :environment do
		puts BirthDatum.count
		puts "state_registrar_no,derived_state_file_no_last6,derived_local_file_no_last6"
		counts = BirthDatum.all.to_a.inject(Hash.new(0)){|h,bd| 
			statefirst = sprintf("%d", "#{bd.derived_state_file_no_last6}#{bd.derived_local_file_no_last6}".to_i)
			localfirst = sprintf("%d", "#{bd.derived_local_file_no_last6}#{bd.derived_state_file_no_last6}".to_i)
			if( bd.state_registrar_no.blank? )
				h[:state_registrar_no_blank] += 1
			elsif( bd.derived_state_file_no_last6.blank? )
				h[:derived_state_file_no_last6_blank] += 1
			elsif( bd.derived_local_file_no_last6.blank? )
				h[:derived_local_file_no_last6_blank] += 1
			elsif( bd.state_registrar_no == statefirst )
				h[:state_first_then_local]+=1
			elsif( bd.state_registrar_no == localfirst )
				h[:local_first_then_state]+=1
			elsif( bd.state_registrar_no[-6..-1] == bd.derived_state_file_no_last6 )
				h[:state_last]+=1
			else
				h[:confused]+=1
				puts "#{bd.state_registrar_no}, #{bd.derived_state_file_no_last6}, #{bd.derived_local_file_no_last6}"
			end

			if( bd.study_subject.blank? )
				h[:study_subject_blank] +=1
			elsif( bd.study_subject.state_id_no.blank? )
				h[:study_subject_state_id_no_blank] +=1
			elsif( bd.study_subject.birth_year.blank? )
				h[:study_subject_birth_year_blank] +=1
			elsif( bd.study_subject.state_id_no == "#{bc.study_subject.birth_year}-#{bd.state_registrar_no}" )
				h["state_id_no_=_state_registrar_no"] +=1
			else
				h["state_id_no_!=_state_registrar_no"] +=1
			end

			h	#	must return the modified hash
		}
		puts counts
	end	#	task :check_state_registrar_no => :environment do


	task :reprocess_birth_data => :environment do
		puts "Study Subject count: #{StudySubject.count}"
#		birth_data = BirthDatum.where(:match_confidence => 'NO').where(:study_subject_id => nil)
		birth_data = BirthDatum.where(:study_subject_id => nil)
			.where(BirthDatum.arel_table[:match_confidence].eq_any(['NO','DEFINITE']))
		birth_data.each{|bd| 
			puts "Processing #{bd}"
			bd.post_processing; bd.reload }
		puts "Study Subject count: #{StudySubject.count}"

		puts; puts "Commiting changes to Sunspot"
		Sunspot.commit

		Notification.updates_from_birth_data( 'fake file', birth_data ).deliver

		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :reprocess_birth_data => :environment do

	task :update_file_nos => :environment do
		raise "This task has been disabled."
		csv_file = "Ca_Co_6_Digit_State_Local.csv"
		raise "CSV File :#{csv_file}: not found" unless File.exists?(csv_file)
		not_found = []
		CSV.open(csv_file,'rb:bom|utf-8', { :headers => true }).each do |line|
			#	master_id,match_confidence,case_control_flag,state_registrar_no,derived_state_file_no_last6,control_number,
			#	dob,last_name,first_name,middle_name,local_registrar_no,derived_local_file_no_last6
			#
			#	If created an actual birth datum record for a control, it would create a control. 
			#	These controls have already been created.
			#	So.  Create one WITHOUT a master_id, which will stop the post_processing.
			#	Basically, create a blank one.
			#	Manually find by state_registrar_no?  and attach study subject
			#	add derived_local_file_no_last6 and derived_state_file_no_last6
			#
			puts line['state_registrar_no']
			next if line['state_registrar_no'].blank?

			birth_data = BirthDatum.where(:state_registrar_no => line['state_registrar_no'] )
			if birth_data.length == 0
				puts "Found #{birth_data.length} subjects matching" 
				not_found.push line
				next
			end

			birth_data.each do |birth_datum| 
				derived_state_file_no_last6 = sprintf("%06d",line['derived_state_file_no_last6'].to_i)
				birth_datum.update_column(:derived_state_file_no_last6, derived_state_file_no_last6)

				derived_local_file_no_last6 = sprintf("%06d",line['derived_local_file_no_last6'].to_i)
				birth_datum.update_column(:derived_local_file_no_last6, derived_local_file_no_last6)

				if birth_datum.study_subject

					birth_datum.study_subject.update_column(:needs_reindexed, true)

					birth_datum.study_subject.operational_events.create(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
						:description => "Birth Record data changes from #{csv_file}",
						:notes => "Added derived_state_file_no_last6 #{derived_state_file_no_last6} and "<<
							"derived_local_file_no_last6 #{derived_local_file_no_last6} to birth data records.")

				end
			end
		end
		puts "#{not_found.length} state registrar nos not found."
		puts not_found
	end

	task :import_birth_data => :environment do

		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In app:birth_data:import_birth_data"

		local_birth_data_dir = 'birth_data'
		FileUtils.mkdir_p(local_birth_data_dir) unless File.exists?(local_birth_data_dir)


#
#	Where are the birth data files?
#	Naming convention?
#

#		puts "About to scp -p birth_data files"
#	S:\CCLS\FieldOperations\ICF\DataTransfers\USC_control_matches\Birth_Certificate_Match_Files
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_birth_data/birth_data_*.csv ./#{local_birth_data_dir}/")
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/USC_control_matches/birth_data_*.csv ./#{local_birth_data_dir}/")
	
		Dir.chdir( local_birth_data_dir )
		birth_data_files = Dir["*.csv"]

		unless birth_data_files.empty?

			birth_data_files.each do |birth_data_file|

				bdu = BirthDatumUpdate.new(birth_data_file,:verbose => true)
				bdu.archive

			end	#	birth_data_files.each do |birth_data_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless birth_data_files.empty?
			puts "No birth_data files found"
			Notification.plain("No Birth Data Files Found",
					:subject => "ODMS: No Birth Data Files Found"
			).deliver
		end	#	unless birth_data_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :import_birth_data => :environment do

#	task :import_birth_data_files => :import_birth_data
#	task :import_birth_data_update_files => :import_birth_data
#	task :import_birth_datum_files => :import_birth_data
#	task :import_birth_datum_update_files => :import_birth_data



	task :replace_birth_data => :environment do

		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In app:birth_data:replace_birth_data"

		#	DON'T WANT this one.
		BirthDatum.skip_callback(:create,:after,:post_processing)

		#	Want this one.
		#BirthDatum.skip_callback(:create,:before,:cleanup_data)

		env_required('csv_file')
		file_required(ENV['csv_file'])
		f=CSV.open( ENV['csv_file'], 'rb:bom|utf-8',{ :headers => true })
		f.each do |line|

			bda = line.dup.to_hash
			["id","birth_datum_update_id","subjectid","childid","ss_icf_master_id",
				"ss_subjectid","ss_interview_completed_on","ss_reference_date",
				"ss_mother_icf_master_id","ss_mother_subjectid","ss_birth_data_count",
				"ss_phase"].each {|attr| bda.delete(attr) }

			puts bda
			BirthDatum.create(bda)

		end	#	f.each

		puts; puts "Re-syncing the candidate control's birth_datum_id's ..."
		#	the candidate control points to both the study_subject and birth_datum, so ...
		CandidateControl.find_each do |cc|
			#puts cc.study_subject_id
			#puts cc.birth_datum_id
			new_bdid = BirthDatum.where(:study_subject_id => cc.study_subject_id).first.id
			#puts new_bdid
			#puts
			cc.update_column(:birth_datum_id, new_bdid)
		end

		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :replace_birth_data => :environment do

end	#	namespace :birth_data do
end	#	namespace :app do

__END__
