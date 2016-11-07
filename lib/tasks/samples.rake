require 'csv'

namespace :app do
namespace :samples do

	#	mysql --user=odms_web_app ccls_odms_production --host=dba-opsc-qa-01.ist.berkeley.edu --port=3351 < ~/database_dumps/odms_production.20161104135013.sql


	#	20161107
	task :import_and_manifest_samples_20161107 => :environment do
		path = "/home/app_odms/"
		base = "R26_NBS_DBS_specimen_manifest_2016_11_02"
		manifest = File.open("#{path}#{base}.OUT.csv",'w')
		f=File.open("#{path}#{base}.csv",'rb')
		manifest.puts "sampleid,#{f.gets}"

			#	subjectid
			#	Packed Container Barcode = TFB00001309611 (all the same)
			#	Specimen Barcode = 0000055H9448
			#	Specimen Type = Dried Blood Spot (all the same)


		f.close
		CSV.open("#{path}#{base}.csv",'rb',
				{ :headers => true }).each do |line|

			puts line

			if line['subjectid'].blank?
				puts "------ No subjectid provided."
				puts line
				exit	#	next
			end

			subject = StudySubject.with_subjectid( line['subjectid'] ).first
			unless subject.present?
				puts "------ Subject not found with subjectid '#{line['subjectid']}'"
				next
			end

			raise "subject not found" unless subject.present?

			attributes = { :project_id => Project[:ccls].id,
				:organization_id => Organization['GEGL'].id,
				:sample_type_id => SampleType[:guthrie].id,
				:sample_format => "Guthrie Card",
				:sample_temperature => "Refrigerated",
				:shipped_to_ccls_at  => "11/1/2016",
				:received_by_ccls_at => "11/2/2016",
				:sent_to_lab_at      => "11/2/2016",
				:received_by_lab_at  => "11/2/2016",
				:external_id => line['Specimen Barcode'],
				:external_id_source => "Specimen Barcode from #{base}.csv",
				:notes => "Imported from #{base}.csv,\n" <<
					"Packed Container Barcode = #{line['Packed Container Barcode']},\n" <<
					"Specimen Barcode = #{line['Specimen Barcode']},\n" <<
					"Specimen Type = #{line['Specimen Type']}"
			}
			puts attributes

			sample = subject.samples.create!(attributes) if subject.present?

			attributes = {
				:occurred_at => DateTime.current,
				:project_id => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
				:description => "manifesting of #{base}.csv" 
			}
			puts attributes

			subject.operational_events.create!(attributes) if subject.present?

			manifest.puts " #{sample.sampleid},#{line}" if subject.present?

		end	#	CSV.open
		manifest.close
	end	#	task :import_and_manifest_samples_20161107 => :environment do



#	#	20160620
#	task :import_and_manifest_maternal_blood_samples_20160614 => :environment do
#		path = "/home/app_odms/Maternal_Urine_Blood/"
#		base = "Maternal_Blood_ListForODMS_06-04-2016ak"
#		manifest = File.open("#{path}#{base}.OUT.csv",'w')
#		f=File.open("#{path}#{base}.csv",'rb')
#		manifest.puts "\"sampleid\",#{f.gets}"
#			#	Box - ##
#			#	Position - ##
#			#	CDC Barcode ID - ##-##-####-??
#			#	Sample Type -
#			#	CDC ID - ##-##-####
#			#	2-digit CDC Specimen ID -
#			#	Volume - 10
#			#	Date Collected - date
#			#	Date Received - date
#			#	Hematocrit -
#			#	Storage Temp -
#			#	UCSF Study Code -
#			#	UCSF Item# - ####
#			#	subjectid - ######
#			#	idlink_familyid - ######
#		f.close
#		CSV.open("#{path}#{base}.csv",'rb',
#				{ :headers => true }).each do |line|
#
##			puts line
#
#			if line['subjectid'].blank?
#				puts "------ No subjectid provided."
#				puts line
#				next
#			end
#
#			subject = StudySubject.with_subjectid( line['subjectid'] ).first
#			unless subject.present?
#				puts "------ Subject not found with subjectid '#{line['subjectid']}'"
#				next
#			end
#
##			raise "subject not found" unless subject.present?
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:momblood].id,
##				:sample_format => "Other Source",
#				:sample_temperature => "Refrigerated",		#line["Storage Temp"],
#				:collected_from_subject_at => line["Date Collected"],
#				:received_by_ccls_at => line["Date Received"],
#				:shipped_to_ccls_at => "12/2/2015",
#				:sent_to_lab_at => "12/2/2015",
#				:received_by_lab_at => "12/2/2015",
#				:ucsf_item_no => line['UCSF Item#'],
#				:cdc_id => line['CDC ID'],
#				:cdc_barcode_id => line['CDC Barcode ID'],
#				:external_id => line['CDC Barcode ID'],
#				:external_id_source => "CDC Barcode from #{base}.csv",
#				:notes => "Imported from #{base}.csv,\n" <<
#					"Received by CCLS is received from UCSF/CDC,\n" <<
#					"Box #{line['Box']},\n" <<
#					"Position #{line['Position']},\n" <<
#					"Volume #{line['Volume']},\n" <<
#					"Sample Type #{line['Sample Type']},\n" <<
#					"Storage Temp #{line['Storage Temp']},\n" <<
#					"Specimen Type #{line['Specimen type']},\n" <<
#					"UCSF Study Code #{line['UCSF Study Code']},\n" <<
#					"Hematocrit #{line['Hematocrit']},\n" <<
#					"idlink_familyid #{line['idlink_familyid']}"
#			) if subject.present?
#
#			subject.operational_events.create!(
#				:occurred_at => DateTime.current,
#				:project_id => Project['ccls'].id,
#				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
#				:description => "manifesting of #{base}.csv"
#			) if subject.present?
#
#			manifest.puts " #{sample.sampleid},#{line}" if subject.present?
#
#		end	#	CSV.open
#		manifest.close
#	end	#	task :import_and_manifest_maternal_blood_samples_20160614 => :environment do
#
#
#
#	#	20160620
#	task :import_and_manifest_maternal_urine_samples_20160614 => :environment do
#		path = "/home/app_odms/Maternal_Urine_Blood/"
#		base = "Maternal_Urine_ListForODMS_06-04-2016ak"
#		manifest = File.open("#{path}#{base}.OUT.csv",'w')
#		f=File.open("#{path}#{base}.csv",'rb')
#		manifest.puts "\"sampleid\",#{f.gets}"
#			#	Box - ##
#			#	Pos - ##
#			#	CDC Barcode ID - ##-##-####-U1
#			#	Sample Type - Urine Archive
#			#	CDCID - ##-##-####
#			#	2-digit CDC Specimen ID - U1 or X6
#			#	Specimen Type - Urine
#			#	VOL - 10
#			#	Date collected - date
#			#	Date Received - date
#			#	First morning void - 0 or 1
#			#	Storage temperature - -80C
#			#	UCSF Study code - BCL
#			#	UCSF Item# - ####
#			#	note: - notes
#			#	subjectid - ######
#			#	idlink_familyid - ######
#		f.close
#		CSV.open("#{path}#{base}.csv",'rb',
#				{ :headers => true }).each do |line|
#
##			puts line
#			subject = StudySubject.with_subjectid( line['subjectid'] ).first
#			unless subject.present?
#				puts "------ Subject not found with #{line['subjectid']}"
#				raise "subject not found"
#			end
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:momurine].id,
##				:sample_format => "Other Source",
#				:sample_temperature => "Refrigerated",		#line["Storage temperature"],
#				:collected_from_subject_at => line["Date collected"],
#				:received_by_ccls_at => line["Date Received"],
#				:shipped_to_ccls_at => "12/2/2015",
#				:sent_to_lab_at => "12/2/2015",
#				:received_by_lab_at => "12/2/2015",
#				:ucsf_item_no => line['UCSF Item#'],
#				:cdc_id => line['CDCID'],
#				:cdc_barcode_id => line['CDC Barcode ID'],
#				:external_id => line['CDC Barcode ID'],
#				:external_id_source => "CDC Barcode from #{base}.csv",
#				:notes => "Imported from #{base}.csv,\n" <<
#					"Received by CCLS is received from UCSF/CDC ,\n" <<
#					"Box #{line['Box']},\n" <<
#					"Pos #{line['Pos']},\n" <<
#					"VOL #{line['VOL']},\n" <<
#					"Sample Type #{line['Sample Type']},\n" <<
#					"Storage temperature #{line['Storage temperature']},\n" <<
#					"Specimen Type #{line['Specimen type']},\n" <<
#					"UCSF Study code #{line['UCSF Study code']},\n" <<
#					"First morning void #{line['First morning void']},\n" <<
#					"idlink_familyid #{line['idlink_familyid']},\n" <<
#					"notes #{line['note:']}"
#			)
#
#			subject.operational_events.create!(
#				:occurred_at => DateTime.current,
#				:project_id => Project['ccls'].id,
#				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
#				:description => "manifesting of #{base}.csv"
#			)
#
#			manifest.puts " #{sample.sampleid},#{line}"
#
#		end	#	CSV.open
#		manifest.close
#	end	#	task :import_and_manifest_maternal_urine_samples_20160614 => :environment do



#	20160504 - Commented out to avoid accidental usage.
#	task :reassociate_samples_for_alice_20160418 => :environment do
#		puts "UCSF_item_no,subjectid,sampleid,UCB_labno,UCB_Biospecimen_Flag,prev_subjectid,changed"
#		CSV.open('FIXforJW_CCLSSampleID_Feb2016.csv', 'rb', { :headers => true }).each do |line|
#			#	UCSF_item_no,subjectid,sampleid,UCB_labno,UCB_Biospecimen_Flag
#
#			samples = Sample.where(:id => line['sampleid'])
#			raise "No sample found with sampleid #{line['sampleid']}" if samples.empty?
#			sample = samples.first	#	id is unique so can be only 1
#			current_subject = sample.study_subject
#
#			#
#			#			FYI: SUBJECT MAY NOT CHANGE!
#			#
#
#			subjects = StudySubject.with_subjectid( line['subjectid'] )
#			raise "No subject found with subjectid #{line['subjectid']}" if subjects.empty?
#			new_subject = subjects.first	#	subjectid is unique so can be only 1
#
#			sample.ucsf_item_no = line['UCSF_item_no']
#			sample.ucb_labno = line['UCB_labno']
#			sample.ucb_biospecimen_flag = line['UCB_Biospecimen_Flag']
#
#			notes = sample.notes
#			( notes.present? ) ? ( notes << "\n" ) : ( notes = "" )
#			if current_subject != new_subject
#				notes << "Sample moved from subjectid #{current_subject.subjectid} "
#				notes << "to #{new_subject.subjectid} (20160420)."
#			end
#			notes << "\n"
#			notes << "Assigned UCSF_item_no:#{line['UCSF_item_no']}, "
#			notes << "UCB_labno:#{line['UCB_labno']}, "
#			notes << "UCB_Biospeciment_Flag:#{line['UCB_Biospecimen_Flag']}."
#			sample.notes = notes
#
#			changed = 'No'
#			if current_subject != new_subject
#				changed = 'Yes'
#				sample.study_subject = new_subject
#			end
#			puts "#{line.to_s.chomp},#{current_subject.subjectid},#{changed}"
#			sample.save!
#		end	#	CSV.open('FIXforJW_CCLSSampleID_Feb2016.csv'
#	end	#	task :reassociate_samples_for_alice_20160418 => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20141208
#	task :report_bloodspot_date_received => :environment do
#		dupe_dates = {}
#		CSV.open('data/dbs_replenish_alternate_ids.csv','rb',{
#				:headers => true }).each do |line|
#			#	subjectid,state_id_no,group,external_id
#			if( line['external_id'] == 'NA' )
#				#				puts "Skipping NA"
#				next
#			end
#
#			samples = Sample.where(:external_id => line['external_id'])
#			puts line['external_id']
#				#			puts samples.collect(&:received_by_ccls_at).inspect
#			puts samples.collect(&:received_by_lab_at).inspect
#			puts samples.collect(&:subjectid).inspect
#
#			if samples.collect(&:subjectid).uniq.length > 1
#				#	NONE
#				puts "---- Multiple subjects with samples with that external_id!"
#			end
#
#			dates = samples.collect(&:received_by_lab_at).compact
#
#			if dates.collect{|d|d.to_date}.uniq.length > 1
#				#	Several with differing dates (3 actually)
#				puts "---- Multiple dates with samples with that external_id!"
#				dupe_dates[ line['external_id'] ] = samples
#			end unless dates.empty?
#
#			if samples.length > 1
#				#	Several (but all same subject)
#				puts "Multiple found with external_id #{line['external_id']}"
#				#raise "Multiple found with external_id #{line['external_id']}"
#			end
#			raise "None found with external_id #{line['external_id']}" if samples.empty?
#
#		end	#	CSV.open('dbs_replenish_alternate_ids.csv
#		dupe_dates.each{|k,v| puts k; puts v.inspect; puts v.collect(&:notes) }
#	end	#	task :report_bloodspot_date_received => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20141007
#	task :update_collected_at_datetimes => :environment do
#		raise "This task has been run and disabled."
#		CSV.open('gegl/Child Leukemia Age at Blood Collection - col_age.csv','rb',{ :headers => true }).each do |line|
#			#Barcode,SPCMN_COLCTN_DT,SPCMN_COLTD_HR (24 hour),AGE_AT_COLCTN (hours)
#			samples = Sample.where(:external_id => line['Barcode'])
#			raise "Multiple found with external_id #{line['Barcode']}" if samples.length > 1
#			raise "None found with external_id #{line['Barcode']}" if samples.empty?
#			sample = samples.first
#
#			time = sprintf('%04d', line['SPCMN_COLTD_HR (24 hour)'])
#			#	puts Time.parse("#{time[0..1]}:#{time[2..3]} #{line['SPCMN_COLCTN_DT']}")
#			#puts sample.collected_from_subject_at
#			sample.update_attributes!(:collected_from_subject_at => "#{time[0..1]}:#{time[2..3]} #{line['SPCMN_COLCTN_DT']}")
#			#puts sample.reload.collected_from_subject_at
#		end	#	CSV.open
#	end


#	20160418 - Commented out to avoid accidental usage.
#	#	20150205
#	task :validate_manifest_bloodspots_20150203 => :environment do
#		raise "This task has been run and disabled."
#		CSV.open('gegl/Request_26_group_A_SFN_to_Barcode_Link_manifest_paste.csv','rb',
#				{ :headers => true }).each do |line|
#			#	icf_master_id,subjectid,sex,sampleid,gegl_sample_type_id,
#			#	collected_from_subject_at,received_by_ccls_at,storage_temperature,
#			#	sent_to_lab_at,SFN,YOB,Barcode,Comment
#
#			sample = Sample.find( line['sampleid'] )
#
#			if sample.external_id != line['Barcode']
#				puts sample.external_id
#				puts line['Barcode']
#				raise 'barcode mismatch'
#			end
#
#			subject = StudySubject.where(
#				:state_id_no => "#{line['YOB'][2,2]}-#{sprintf('%06d', line['SFN'])}" ).first
#			if subject.subjectid != line['subjectid'].squish
#				puts subject.subjectid
#				puts line['subjectid']
#				raise 'subjectid mismatch'
#			end
#		end	#	CSV.open
#	end	#	task :validate_manifest_bloodspots_20150203 => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20150225
#	task :import_and_manifest_bloodspots_20150225 => :environment do
##		raise "This task has been run and disabled."
#		manifest = CSV.open('gegl/old_spots_transfered_from_joes_lab_10202014_with_ids_manifest.csv','w')
#
#		manifest.puts %w( icf_master_id subjectid sex sampleid gegl_sample_type_id
#			collected_from_subject_at received_by_ccls_at
#			storage_temperature sent_to_lab_at )
#		CSV.open('gegl/old_spots_transfered_from_joes_lab_10202014_with_ids.csv','rb',
#				{ :headers => true }).each do |line|
#
#			#ID From Adam,childid,patid,phase,subjectid,NOTES
#
#			puts line
#			subject = StudySubject.with_subjectid( line['subjectid'] ).first
#			puts "------ Subject not found with #{line['subjectid']}" unless subject.present?
#			raise "subject not found" unless subject.present?
#			raise "childid mismatch:#{subject.childid}" unless subject.childid.to_s == line['childid']
#			raise "patid mismatch:#{subject.patid}" unless subject.patid.to_s == sprintf("%04d",line['patid'].to_i)
#			raise "phase mismatch:#{subject.phase}" unless subject.phase.to_s == line['phase']
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:guthrie].id,
#				:sample_format => "Guthrie Card",
#				:sample_temperature => "Refrigerated",
#				:received_by_ccls_at => "10/20/2014",
#				:shipped_to_ccls_at => "10/20/2014",
#				:sent_to_lab_at => "10/20/2014",
#				:received_by_lab_at => "10/20/2014",
#				:external_id => line['ID From Adam'],
#				:external_id_source => "old_spots_transfered_from_joes_lab_10202014_with_ids.csv",
#				:notes => "Imported from old_spots_transfered_from_joes_lab_10202014_with_ids.csv"
#			)
#
#			subject.operational_events.create!(
#				:occurred_at => DateTime.current,
#				:project_id => Project['ccls'].id,
#				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
#				:description => "manifesting of old_spots_transfered_from_joes_lab_10202014_with_ids.csv"
#			)
#
#			manifest.puts [
#				sample.study_subject.icf_master_id_to_s,
#				" #{sample.subjectid}",
#				sample.study_subject.sex,
#				" #{sample.sampleid}",
#				sample.sample_type.gegl_sample_type_id,
#				mdyhm_or_nil(sample.collected_from_subject_at),
#				mdyhm_or_nil(sample.received_by_ccls_at),
#				sample.sample_temperature,
#				mdyhm_or_nil(sample.sent_to_lab_at)
#			]
#
#		end	#	CSV.open
#		manifest.close
#	end	#	task :import_and_manifest_bloodspots_20150223 => :environment do


#	#	20150223
#	task :import_and_manifest_bloodspots_20150223 => :environment do
#		raise "This task has been run and disabled."
#		manifest = CSV.open('gegl/Request_26_group_B_SFN_to_Barcode_Link_manifest.csv','w')
#
#		manifest.puts %w( icf_master_id subjectid sex sampleid gegl_sample_type_id
#			collected_from_subject_at received_by_ccls_at
#			storage_temperature sent_to_lab_at Barcode state_id_no Group Comment )
#		CSV.open('gegl/Request_26_group_B_SFN_to_Barcode_Link.csv','rb',
#				{ :headers => true }).each do |line|
#
#			#Barcode,subjectid,state_id_no,Group,Comment
#
#			puts line
#			subject = StudySubject.with_subjectid( line['subjectid'] ).first
#			puts "------ Subject not found with #{line['subjectid']}" unless subject.present?
#			raise 'hell' unless subject.present?
#			raise 'hell' unless subject.state_id_no == line['state_id_no']
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:guthrie].id,
#				:sample_format => "Guthrie Card",
#				:sample_temperature => "Refrigerated",
#				:received_by_ccls_at => "2/18/2015",
#				:shipped_to_ccls_at => "2/18/2015",
#				:sent_to_lab_at => "2/18/2015",
#				:received_by_lab_at => "2/18/2015",
#				:external_id => line['Barcode'],
#				:external_id_source => "Request_26_group_B_SFN_to_Barcode_Link.csv",
#				:notes => "Imported from Request_26_group_B_SFN_to_Barcode_Link.csv"
#			)
#
#			subject.operational_events.create!(
#				:occurred_at => DateTime.current,
#				:project_id => Project['ccls'].id,
#				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
#				:description => "manifesting of Request_26_group_B_SFN_to_Barcode_Link.csv"
#			)
#
#			manifest.puts [
#				sample.study_subject.icf_master_id_to_s,
#				" #{sample.subjectid}",
#				sample.study_subject.sex,
#				" #{sample.sampleid}",
#				sample.sample_type.gegl_sample_type_id,
#				mdyhm_or_nil(sample.collected_from_subject_at),
#				mdyhm_or_nil(sample.received_by_ccls_at),
#				sample.sample_temperature,
#				mdyhm_or_nil(sample.sent_to_lab_at),
#				line['Barcode'],
#				line['state_id_no'],
#				line['Group'],
#				line['Comment']
#			]
#
#		end	#	CSV.open
#		manifest.close
#	end	#	task :import_and_manifest_bloodspots => :environment do


#	#	20150203
#	task :import_and_manifest_bloodspots_20150203 => :environment do
#		raise "This task has been run and disabled."
#		manifest = CSV.open('gegl/Request_26_group_A_SFN_to_Barcode_Link_manifest.csv','w')
#
#		manifest.puts %w( icf_master_id subjectid sex sampleid gegl_sample_type_id
#			collected_from_subject_at received_by_ccls_at
#			storage_temperature sent_to_lab_at )
#		CSV.open('gegl/Request_26_group_A_SFN_to_Barcode_Link.csv','rb',
#				{ :headers => true }).each do |line|
#
#			#SFN,YOB,Barcode,Comment
#
#			puts line
#			subject = StudySubject.where(
#				:state_id_no => "#{line['YOB'][2,2]}-#{sprintf('%06d', line['SFN'])}" ).first
#			puts "------ Subject not found with #{line['SFN']}" unless subject.present?
#			raise 'hell' unless subject.present?
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:guthrie].id,
#				:sample_format => "Guthrie Card",
#				:sample_temperature => "Refrigerated",
#				:received_by_ccls_at => "1/27/2015",
#				:shipped_to_ccls_at => "1/27/2015",
#				:sent_to_lab_at => "1/27/2015",
#				:received_by_lab_at => "1/27/2015",
#				:external_id => line['Barcode'],
#				:external_id_source => "Request_26_group_A_SFN_to_Barcode_Link.csv",
#				:notes => "Imported from Request_26_group_A_SFN_to_Barcode_Link.csv"
#			)
#
#			subject.operational_events.create!(
#				:occurred_at => DateTime.current,
#				:project_id => Project['ccls'].id,
#				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
#				:description => "manifesting of Request_26_group_A_SFN_to_Barcode_Link.csv"
#			)
#
#			manifest.puts [
#				sample.study_subject.icf_master_id_to_s,
#				" #{sample.subjectid}",
#				sample.study_subject.sex,
#				" #{sample.sampleid}",
#				sample.sample_type.gegl_sample_type_id,
#				mdyhm_or_nil(sample.collected_from_subject_at),
#				mdyhm_or_nil(sample.received_by_ccls_at),
#				sample.sample_temperature,
#				mdyhm_or_nil(sample.sent_to_lab_at)
#			]
#
#		end	#	CSV.open
#		manifest.close
#	end	#	task :import_and_manifest_bloodspots => :environment do


#	#	20141006
#	task :import_and_manifest_bloodspots_20141006 => :environment do
#		raise "This task has been run and disabled."
#		manifest = CSV.open('bloodspot_receipt_10062014_manifest.csv','w')
#		manifest.puts %w( icf_master_id subjectid sex sampleid gegl_sample_type_id collected_from_subject_at
#			received_by_ccls_at storage_temperature sent_to_lab_at )
#		CSV.open('gegl/bloodspot_receipt_10062014.csv','rb',{ :headers => true }).each do |line|
#
#			#subjectid,derived_state_file_no_last6,Birth SFN,Birth Year,Specimen Barcode,Comment
#
#			puts line
#			subject = StudySubject.with_subjectid(line['subjectid'].to_i).first
#			#puts "------ Subject not found with #{line['subjectid']}" unless subject.present?
#
#			#	They are always the same
#			#	raise "derived_state_file_no_last6 and Birth SFN differ in csv" if(
#			#		line['derived_state_file_no_last6'] != line['Birth SFN'] )
#			#	raise "Birth Year different :#{line['Birth Year']}:#{subject.birth_year}" if(
#			#		line['Birth Year'] != subject.birth_year )
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:guthrie].id,
#				:sample_format => "Guthrie Card",
#				:sample_temperature => "Refrigerated",
#				:received_by_ccls_at => "9/18/2014",
#				:shipped_to_ccls_at => "9/18/2014",
#				:sent_to_lab_at => "9/18/2014",
#				:received_by_lab_at => "9/18/2014",
#				:external_id => line['Specimen Barcode'],
#				:external_id_source => "bloodspot_receipt_10062014.csv",
#				:notes => "Imported from bloodspot_receipt_10062014.csv"
#			)
#
#			subject.operational_events.create!(
#				:occurred_at => DateTime.current,
#				:project_id => Project['ccls'].id,
#				:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
#				:description => "manifesting of bloodspot_receipt_10062014.csv"
#			)
#
#			manifest.puts [
#				sample.study_subject.icf_master_id_to_s,
#				" #{sample.subjectid}",
#				sample.study_subject.sex,
#				" #{sample.sampleid}",
#				sample.sample_type.gegl_sample_type_id,
#				mdyhm_or_nil(sample.collected_from_subject_at),
#				mdyhm_or_nil(sample.received_by_ccls_at),
#				sample.sample_temperature,
#				mdyhm_or_nil(sample.sent_to_lab_at)
#			]
#
#		end	#	CSV.open
#		manifest.close
#	end	#	task :import_and_manifest_bloodspots => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20140916
#	task :gegl_oldest_date_received => :environment do
#		#columns=csv_columns( 'gegl/lab_yield.ccls.txt', { :col_sep => "\t" })
#		#	["locations_subjectid", "locations_sampleid", "total_yield", "ratio", "wga", "type", "type_desc",
#		#		"ucb_sampleid", "date_recieved", "status", "reason"]
#		#	oldest date received 2011-08-17
#		oldest_date_received = Date.current
#		puts oldest_date_received
#		CSV.open( 'gegl/lab_yield.ccls.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|
#			#
#			#	YES.  THE FIELD IS CORRECTLY SPELLED INCORRECTLY.
#			#
#			if( line['date_recieved'].present? )
#				date=Date.parse(line['date_recieved'])
#				oldest_date_received = date if( date < oldest_date_received )
#			end
#		end
#		puts oldest_date_received
#	end	#	task :gegl_oldest_date_received => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20140917
#	task :gegl_sampleid_subjectid_check_for_GuthrieCards => :environment do
#		puts Organization['gegl'].id
#		CSV.open( 'gegl/lab_yield.ucsf_buffler.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|
#			sampleid = line['locations_sampleid']
#			next unless sampleid.match(/\d\d\d\dG$/)
#			samples = Sample.where(:external_id => sampleid)
#			puts "------ Samples not found with external_id #{sampleid}" if samples.empty?
#
#			samples.each do |sample|
#				subject = StudySubject.with_subjectid(line['locations_subjectid'].to_i).first
#				puts "------ Subject not found with #{line['locations_subjectid']}" unless subject.present?
#
#				if sample.present? and subject.present?
#					if sample.study_subject.familyid != subject.familyid
#						puts "------ Sample #{line['locations_sampleid']} belongs to different Subject / Mother"
#					else
#						puts "EVERYTHING IS OK!!!  Updating sample #{sample}"
#						updates = {}
#						updates[:organization_id] = Organization['gegl'].id if sample.organization_id != Organization['gegl'].id
#						#	many dates as 9999-01-01
#						#	some dates as 2015-07-29
#						if line['date_recieved'].present?  and sample.received_by_lab_at.nil? and
#								line['date_recieved'].match(/^9999-01-01/).nil?  and
#								line['date_recieved'].match(/^2015-07-29/).nil?
#							updates[:received_by_lab_at] = line['date_recieved']
#						end
#						unless updates.empty?
#							notes = sample.notes
#							( notes.present? ) ? ( notes << "\n" ) : ( notes = "" )
#							notes << "#{Date.current.strftime("%-m/%-d/%-Y")}: Synchronizing location and date received with lab db.\n"
#							notes << "#{updates}\n"
#							updates[:notes] = notes
#							sample.update_attributes!(updates)
#						end
#					end
#				end
#			end	#	samples.each do |sample|
#
#		end
#	end	#	task :gegl_sampleid_subjectid_check_for_GuthrieCards => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20140916
#	task :gegl_sampleid_subjectid_check => :environment do
#		#matching = File.open( "#{Date.current.strftime("%Y%m%d")}-gegl_errors.mismatched_samples.matching.txt", 'w')
#		#family = File.open( "#{Date.current.strftime("%Y%m%d")}-gegl_errors.mismatched_samples.family.txt", 'w')
#		#columns=csv_columns( 'gegl/lab_yield.merged.txt', { :col_sep => "\t" })
#		#	["locations_subjectid", "locations_sampleid", "total_yield", "ratio", "wga", "type", "type_desc",
#		#		"ucb_sampleid", "date_recieved", "status", "reason"]
#		#csv_out.puts columns
#		#matching.puts %w( sampleid gegl_subjectid gegl_subject_type gegl_patid odms_subjectid odms_subject_type odms_patid sample_type ).to_csv
#		#family.puts %w( sampleid gegl_subjectid gegl_subject_type gegl_patid odms_subjectid odms_subject_type odms_patid sample_type ).to_csv
#		#CSV.open( 'gegl/lab_yield.ccls.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|					#	all good except 1
#		#CSV.open( 'gegl/lab_yield.ccls_smith.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|			#	all good
#		CSV.open( 'gegl/lab_yield.ucsf_buffler.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|			#	most good
#		#CSV.open( 'gegl/lab_yield.merged.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|			#	most good
#			sampleid = line['locations_sampleid']
#			#
#			next if sampleid.match(/G$/)			#	kinda have to ignore as not unique
#			#
#			if sampleid.match(/^ccls_/i)
#				sampleid = sampleid.split(/\D/).last
#			end
#			sampleid = sampleid.split(/\D/).first
#			sampleid = sampleid.to_i
#			sample   = Sample.where(id:sampleid).first if sampleid.present? and sampleid > 0
#			puts "------ Sample not found with #{line['locations_sampleid']}" unless sample.present?
#			subject = StudySubject.with_subjectid(line['locations_subjectid'].to_i).first
#			puts "------ Subject not found with #{line['locations_subjectid']}" unless subject.present?
#
#			if sample.present? and subject.present?
#				if sample.study_subject_id == subject.id
#
#					puts "EVERYTHING IS OK!!!  Updating sample #{sample}"
#
#				#	match familyid first as will also match matchingid
#				elsif sample.study_subject.familyid == subject.familyid
#					puts "------ Sample #{line['locations_sampleid']} belongs to different family member Subject / Mother"
#
#					#family.puts [	sprintf('%07d',sampleid), line['locations_subjectid'], subject.subject_type, subject.patid,
#					#	sample.study_subject.subjectid, sample.study_subject.subject_type, sample.study_subject.patid, sample.sample_type ].to_csv
#
#				elsif sample.study_subject.matchingid == subject.matchingid
#					puts "------ Sample #{line['locations_sampleid']} belongs to different matching member Control / Control Mother"
#
#					#matching.puts [ sprintf('%07d',sampleid), line['locations_subjectid'], subject.subject_type, subject.patid,
#					#	sample.study_subject.subjectid, sample.study_subject.subject_type, sample.study_subject.patid, sample.sample_type ].to_csv
#
#				else
#					puts "------ Confused"
#					puts line
#					raise 'hell'		#	NONE!  YAY!
#				end
#
#				puts "Preparing to update"
#				updates = {}
#				updates[:organization_id] = Organization['gegl'].id if sample.organization_id != Organization['gegl'].id
#				#	many dates as 9999-01-01
#				#	some dates as 2015-07-29
#				if line['date_recieved'].present?  and sample.received_by_lab_at.nil? and
#						line['date_recieved'].match(/^9999-01-01/).nil?  and
#						line['date_recieved'].match(/^2015-07-29/).nil?
#					updates[:received_by_lab_at] = line['date_recieved']
#				end
#				unless updates.empty?
#					notes = sample.notes
#					( notes.present? ) ? ( notes << "\n" ) : ( notes = "" )
#					notes << "#{Date.current.strftime("%-m/%-d/%-Y")}: Synchronizing location and date received with lab db.\n"
#					notes << "#{updates}\n"
#					updates[:notes] = notes
#					puts "Updating database with #{updates}"
#					sample.update_attributes!(updates)
#				end
#
#			end	#	if sample.present? and subject.present?
#		
#		end	#	CSV.open
#		#csv_out.close
#		#matching.close
#		#family.close
#	end	#	task :gegl_sampleid_subjectid_check => :environment do


#	lab_yield.ccls.txt	(change 858007 to 585007
#	------ Subject not found with 858007

#	lab_yield.ucsf_buffler.txt
#------ Sample 0002205 belongs to different Subject / Mother
#------ Sample 0002206 belongs to different Subject / Mother
#------ Sample 0002217 belongs to different Subject / Mother
#------ Sample 0002218 belongs to different Subject / Mother
#------ Sample 0002219 belongs to different Subject / Mother
#------ Sample 0002520 belongs to different Subject / Mother
#------ Sample 0002521 belongs to different Subject / Mother
#------ Sample 0002522 belongs to different Subject / Mother
#------ Sample 0002664 belongs to different Subject / Mother
#------ Sample 0002315 belongs to different Subject / Mother
#------ Sample 0002316 belongs to different Subject / Mother
#------ Sample 0002523 belongs to different Subject / Mother
#------ Sample 0002524 belongs to different Subject / Mother
#------ Sample 0002525 belongs to different Subject / Mother
#------ Sample 0002411 belongs to different Subject / Mother
#------ Sample 0002412 belongs to different Subject / Mother
#------ Sample 0002547 belongs to different Subject / Mother
#------ Sample 0002548 belongs to different Subject / Mother
#------ Sample 0002549 belongs to different Subject / Mother
#------ Sample 0002310 belongs to different Subject / Mother
#------ Sample 0002704 belongs to different Subject / Mother
#------ Sample 0002705 belongs to different Subject / Mother
#------ Sample 0002706 belongs to different Subject / Mother
#------ Sample 0002208 belongs to different Subject / Mother
#------ Sample 0002209 belongs to different Subject / Mother
#------ Sample 0002210 belongs to different Subject / Mother
#------ Sample 0002214 belongs to different Subject / Mother
#------ Sample 0002215 belongs to different Subject / Mother
#------ Sample 0002216 belongs to different Subject / Mother
#------ Sample 0002486 belongs to different Subject / Mother
#------ Sample 0002487 belongs to different Subject / Mother
#------ Sample 0002488 belongs to different Subject / Mother
#------ Sample 0002748 belongs to different Subject / Mother
#------ Sample 0002749 belongs to different Subject / Mother
#------ Sample 0002211 belongs to different Subject / Mother
#------ Sample 0002212 belongs to different Subject / Mother
#------ Sample 0002213 belongs to different Subject / Mother
#------ Sample 0002668 belongs to different Subject / Mother
#------ Sample 0002669 belongs to different Subject / Mother
#------ Sample 0002440 belongs to different Subject / Mother
#------ Sample 0002441 belongs to different Subject / Mother
#------ Sample 0002339 belongs to different Subject / Mother
#------ Sample 0002340 belongs to different Subject / Mother
#------ Sample 0002659 belongs to different Subject / Mother
#------ Sample 0002660 belongs to different Subject / Mother
#------ Sample 0002661 belongs to different Subject / Mother
#------ Sample 0002333 belongs to different Subject / Mother
#------ Sample 0002334 belongs to different Subject / Mother
#------ Sample 0002683 belongs to different Subject / Mother
#------ Sample 0002684 belongs to different Subject / Mother
#------ Sample 0002685 belongs to different Subject / Mother
#------ Sample 0002359 belongs to different Subject / Mother
#------ Sample 0002360 belongs to different Subject / Mother
#------ Sample 0002369 belongs to different Subject / Mother
#------ Sample 0002370 belongs to different Subject / Mother
#------ Sample 0002511 belongs to different Subject / Mother
#------ Sample 0002512 belongs to different Subject / Mother
#------ Sample 0002513 belongs to different Subject / Mother
#------ Sample 0002508 belongs to different Subject / Mother
#------ Sample 0002509 belongs to different Subject / Mother
#------ Sample 0002510 belongs to different Subject / Mother
#------ Sample 0002289 belongs to different Subject / Mother
#------ Sample 0002711 belongs to different Subject / Mother
#------ Sample 0002608 belongs to different Subject / Mother
#------ Sample 0002220 belongs to different Subject / Mother
#------ Sample 0002221 belongs to different Subject / Mother
#------ Sample 0002222 belongs to different Subject / Mother
#------ Sample 0002750 belongs to different Subject / Mother
#------ Sample 0002751 belongs to different Subject / Mother
#------ Sample 0002752 belongs to different Subject / Mother
#------ Sample 0002701 belongs to different Subject / Mother
#------ Sample 0002702 belongs to different Subject / Mother
#------ Sample 0002703 belongs to different Subject / Mother
#------ Sample 0002305 belongs to different Subject / Mother
#------ Sample 0002306 belongs to different Subject / Mother
#------ Sample 0002609 belongs to different Subject / Mother
#------ Sample 0002610 belongs to different Subject / Mother
#------ Sample 0002432 belongs to different Subject / Mother
#------ Sample 0002433 belongs to different Subject / Mother
#------ Sample 0002434 belongs to different Subject / Mother
#------ Sample 0002290 belongs to different Subject / Mother
#------ Sample 0002291 belongs to different Subject / Mother
#------ Sample 0002653 belongs to different Subject / Mother
#------ Sample 0002654 belongs to different Subject / Mother
#------ Sample 0002655 belongs to different Subject / Mother
#------ Sample 0002226 belongs to different Subject / Mother
#------ Sample 0002228 belongs to different Subject / Mother
#------ Sample 0002313 belongs to different Subject / Mother
#------ Sample 0002314 belongs to different Subject / Mother

#	Sample.where(Sample.arel_table[:sent_to_lab_at].gt(Date.parse("2011-08-17"))).count
#		1082

#	cat gegl/lab_yield.ccls.txt | awk '{print $2}' | awk -F_ '{print $1}' | sort | grep -vs location | uniq | wc -l
#    1014

#	20160418 - Commented out to avoid accidental usage.
#	#	20140916
#	task :gegl_expected_sampleid_comparison_by_location_and_date => :environment do
#		odms_sampleids = Sample.where(:organization_id => 17).where(Sample.arel_table[:sent_to_lab_at].gt(Date.parse("2011-08-17"))).collect(&:sampleid).collect(&:to_i).sort
#		gegl_sampleids = []
#		CSV.open( 'gegl/lab_yield.ccls.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|
#			gegl_sampleids.push( line['locations_sampleid'].split(/\D/).first.to_i )
#		end
#		gegl_sampleids.uniq!
#		gegl_sampleids.sort!
#
#		puts "In ODMS"
#		puts odms_sampleids.inspect
#		puts "In GEGL"
#		puts gegl_sampleids.inspect
#
#		puts "In ODMS and not GEGL"
#		puts (odms_sampleids-gegl_sampleids).length
#		puts (odms_sampleids-gegl_sampleids).sort.inspect
#		puts "In GEGL and not ODMS"
#		puts (gegl_sampleids-odms_sampleids).length
#		puts (gegl_sampleids-odms_sampleids).sort.inspect
#	end	#	task :gegl_expected_sampleid_comparison => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20140916
#	task :gegl_expected_sampleid_comparison_by_location => :environment do
#		odms_sampleids = Sample.where(:organization_id => 17).collect(&:sampleid).collect(&:to_i).sort
#		gegl_sampleids = []
#		CSV.open( 'gegl/lab_yield.ccls.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|
#			gegl_sampleids.push( line['locations_sampleid'].split(/\D/).first.to_i )
#		end
#		gegl_sampleids.uniq!
#		gegl_sampleids.sort!
#
#		puts "In ODMS"
#		puts odms_sampleids.inspect
#		puts "In GEGL"
#		puts gegl_sampleids.inspect
#
#		puts "In ODMS and not GEGL"
#		puts (odms_sampleids-gegl_sampleids).length
#		puts (odms_sampleids-gegl_sampleids).sort.inspect
#		puts "In GEGL and not ODMS"
#		puts (gegl_sampleids-odms_sampleids).length
#		puts (gegl_sampleids-odms_sampleids).sort.inspect
#	end	#	task :gegl_expected_sampleid_comparison => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	#	20140916
#	task :gegl_expected_sampleid_comparison_by_date => :environment do
#		odms_sampleids = Sample.where(Sample.arel_table[:sent_to_lab_at].gt(Date.parse("2011-08-17"))).collect(&:sampleid).collect(&:to_i).sort
#		gegl_sampleids = []
#		CSV.open( 'gegl/lab_yield.ccls.txt','rb',{ :col_sep => "\t", :headers => true }).each do |line|
#			gegl_sampleids.push( line['locations_sampleid'].split(/\D/).first.to_i )
#		end
#		gegl_sampleids.uniq!
#		gegl_sampleids.sort!
#
#		puts "In ODMS"
#		puts odms_sampleids.inspect
#		puts "In GEGL"
#		puts gegl_sampleids.inspect
#
#		puts "In ODMS and not GEGL"
#		puts (odms_sampleids-gegl_sampleids).length
#		puts (odms_sampleids-gegl_sampleids).sort.inspect
#		puts "In GEGL and not ODMS"
#		puts (gegl_sampleids-odms_sampleids).length
#		puts (gegl_sampleids-odms_sampleids).sort.inspect
#	end	#	task :gegl_expected_sampleid_comparison => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	task :correct_subject_association => :environment do
#		raise "This task has been run and disabled."
#		CSV.open( 'data/20140422_corrected_subject_sample.csv','rb',{ :headers => true }).each do |line|
#			#	subjectid,corrected_subjectid,sampleid,sample_super_type,sample_type
#			puts line
#			sample = Sample.find(line['sampleid'].to_i)
#			assert_string_equal( sample.sampleid, line['sampleid'], :sampleid)
#			#	assert_string_equal( sample.subjectid, line['subjectid'], :subjectid)
#			assert_string_equal( sample.subjectid, line['corrected_subjectid'], :subjectid)
#			assert_string_equal( sample.sample_type, line['sample_type'], :sample_type)
#			assert_string_equal( sample.sample_type_parent, line['sample_super_type'], :sample_type_parent)
#
#			if line['subjectid'] != line['corrected_subjectid']
#				subject = StudySubject.with_subjectid(line['subjectid']).first
#				puts subject.samples_count
#				#	Sample will automatically reindex as it changes
#				#	BOTH Subjects MAY not as it doesn't change, (the counter does)
#				#	New subject will be triggered, but not the old.
#				#	CounterCaches are only updated in the database so won't trigger reindex.
#				#	Triggering both.
#				correct_subject = StudySubject.with_subjectid(line['corrected_subjectid']).first
#				assert_string_equal( correct_subject.subjectid, line['corrected_subjectid'], :corrected_subjectid)
#				puts correct_subject.samples_count
#				correct_subject.samples << sample
#				puts correct_subject.reload.samples_count
#				correct_subject.update_column(:needs_reindexed, true)
#
#				subject = StudySubject.with_subjectid(line['subjectid']).first
#				assert_string_equal( subject.subjectid, line['subjectid'], :subjectid)
#				puts subject.samples_count
#				subject.update_column(:needs_reindexed, true)
#
#				notes = [sample.notes.presence].compact
#				notes << "Sample moved from child subjectid #{line['subjectid']} to mother #{line['corrected_subjectid']} (20140422)."
#				sample.update_attributes!(:notes => notes.join("\n"))
#				puts sample.notes
#			end
#		end	#	CSV.open( 'data/corrected_subject_sample.csv'
#	end	#	task :correct_subject_association => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	task :merge_overlaps_with_icf_master_id => :environment do
#		raise "This task has been run and disabled."
#		icf_master_ids = {}
#		CSV.open( 'data/statefileno_ccrlp.csv','rb',{ :headers => true }).each do |line|
#			raise "ICF Master ID already used" if icf_master_ids.has_key? line['derived_state_file_no_last6']
#			icf_master_ids[ line['derived_state_file_no_last6'] ] = line['icf_master_id']
#		end
#		columns=csv_columns( 'data/20140303_overlaps.csv')
#		puts "icf_master_id,#{columns.join(',')}"
#		CSV.open( 'data/20140303_overlaps.csv','rb',{ :headers => true }).each do |line|
#			puts "#{icf_master_ids[ line['SFN'] ]},#{line}"
#		end
#	end	#	task :merge_overlaps_with_icf_master_id => :environment do


#	20160418 - Commented out to avoid accidental usage.
#	task :import_overlaps => :environment do
#		raise "This task has been run and disabled."
#		ifile = "data/20140303_overlaps_with_icf_master_ids.csv"
#		ofile = "data/20140303_overlaps_with_icf_master_ids_subjectids_sampleids.csv"
#		mfile = "data/20140305_manifest.csv"
#		csv_out = CSV.open( ofile, 'w')
#		manifest = CSV.open( mfile, 'w')
#		manifest << %w( icf_master_id subjectid sex sampleid gegl_sample_type_id
#			collected_from_subject_at received_by_ccls_at storage_temperature sent_to_lab_at )
#		columns=csv_columns( 'data/20140303_overlaps_with_icf_master_ids.csv')
#		puts "#{columns.join(',')},subjectid,sampleid"
#		csv_out << columns + %w(subjectid sampleid)
#		(csv_in = CSV.open( ifile, 'rb',{ :headers => true })).each do |line|
#			subjects = StudySubject.where(:icf_master_id => line['icf_master_id'])
#			puts "Subject not found with #{sfn}" if subjects.empty?
#			if subjects.length > 1
#				puts "Multiple found with #{sfn}"
#				puts subjects.inspect
#			end
#			subject = subjects.first
#			if line['DOB'] != subject.dob.strftime("%Y%m%d")
#				puts "DOB not the same #{line['DOB']} - #{subject.dob.strftime("%Y%m%d")}"
#			end
#			#	icf_master_id,DOB,SFN,pull,barcode,blindid,c_dob,birth_year,combo_id
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:organization_id => Organization['GEGL'].id,
#				:sample_type_id => SampleType[:guthrie].id,
#				:sample_format => "Guthrie Card",
#				:sample_temperature => "Refrigerated",
#				:received_by_ccls_at => "3/5/2014",
#				:sent_to_lab_at => "3/5/2014",
#				:external_id => line['barcode'],
#				:external_id_source => "20140303_overlaps_with_icf_master_ids.csv",
#				:notes => "Imported from 20140303_overlaps_with_icf_master_ids.csv\n" <<
#					"pull #{line['pull']},\n"<<
#					"barcode #{line['barcode']},\n"<<
#					"blindid #{line['blindid']}"
#			)
#			puts "#{line.to_s.chomp},#{subject.subjectid},#{sample.sampleid}"
#			new_line = line
#			new_line.push(subject.subjectid,sample.sampleid)
#			csv_out << new_line
#			manifest <<	[ sample.study_subject.icf_master_id_to_s,
#				" #{sample.study_subject.subjectid}",
#				sample.study_subject.sex,
#				" #{sample.sampleid}",
#				sample.sample_type.gegl_sample_type_id,nil,
#				"3/5/2014",
#				sample.sample_temperature,
#				"3/5/2014" ]
#		end	#	(csv_in = CSV.open( ifile, 'rb',{ :headers => true })).each do |line|
#		manifest.close
#		csv_out.close
#	end	#	task :overlaps => :environment do


#	task :recheck_original_sample_types => :environment do
#		#ID,Sample_Type_ID,Description,Position,ODMS_sample_type_id,Code,GEGL_type_code
#		sample_types_infile = 'tracking2k/sample_types.csv'
#		#	Sample_Type_ID ... ODMS_sample_type_id
#		sample_types={}
#		(CSV.open( sample_types_infile, 'rb',{ :headers => true })).each do |line|
#			#sample_types[line['Sample_Type_ID']] = line['ODMS_sample_type_id']
#			#	Sample_Type_ID is really the parent sample type
#			sample_types[line['ID']] = line['ODMS_sample_type_id']
#		end
#
#		#	id,sample_ID,subjectID,sample_subtype_id,sample_subtype_id_orig
#		infile = 'tracking2k/samples.csv'
#		total_lines = total_lines(infile)
#		columns = csv_columns(infile)
##		csv_report = CSV.open('tracking2k/samples_report.csv', 'w')
##		csv_report << columns
##		csv_out = CSV.open('tracking2k/samples_out.csv', 'w')
##		columns << 'actual_sample_type_id'
##		csv_out << columns
##		last_sample_subtype_id = nil	#	for rememberin
#		(csv_in = CSV.open( infile, 'rb',{ :headers => true })).each do |line|
#			puts line
#			new_line = line
#			sample = Sample.find(line['id'].to_i)
#			new_line << sample.sample_type_id
#			puts new_line
#
#			##	raise 'differe' if( line['sample_subtype_id'].to_s
#			##		!= line['sample_subtype_id_orig'].to_s )
#			#if( line['sample_subtype_id'].to_s != line['sample_subtype_id_orig'].to_s )
#			#	#	csv_report << new_line
#			#	csv_report << [line['sample_subtype_id'],line['sample_subtype_id_orig'],
#			#		sample.sample_type_id]
#			#end
#
#			# sample_subtype_id seem to occassionally be missing (expect they are '20')
#			# sample_subtype_id_orig seem to be bogus
#
#			#	Not all of the samples that are missing the sample_type are Buccal/Salival
#			#		so can't confirm what these sample types are so can't change them to
#			#		buccal or salival.  Leaving them as is.
#			#		MAYBE leave them as is but add a comment?
#
#			#	  ,6,16
#			#	12,6,16
#			#	13,6,16
#			#	19,6,16
#			#	20,6,16
#			#	sample.sample_type_id should == sample_types[ line['sample_subtype_id'] || 20 ]
#
#			#puts ":#{line['sample_subtype_id']}: -> :#{sample_types[line['sample_subtype_id']]}:"
#			#puts ":#{line['sample_subtype_id_orig']}: -> :#{sample_types[line['sample_subtype_id_orig']]}:"
#			#puts ":#{sample.sample_type_id}:"
#			#puts ":#{sample_types[ line['sample_subtype_id'] || '20' ]}:"
#
#			#	unfortunately, using the previous type when the type is blank doesn't work.
#			#last_sample_subtype_id = sample_subtype_id = ( line['sample_subtype_id'] || last_sample_subtype_id )
#
#
#			notes = [sample.notes].compact
#			if line['sample_subtype_id'].present?
#
#				if( sample.sample_type_id.to_i != sample_types[line['sample_subtype_id']].to_i )
#
#					new_note =  "Sample Type discrepancy found in tracking2k database check and may be incorrect. "
#					new_note << "It was #{line['sample_subtype_id']} in tracking2k, which should've been converted "
#					new_note << "to #{sample_types[line['sample_subtype_id']]} but ODMS had it as "
#					new_note << "#{sample.sample_type_id.to_i}. Changing to "
#					new_note << "#{sample_types[line['sample_subtype_id']]} (20140123)."
#					notes << new_note
#					#
#					#	Don't just do this.  Add some notes to sample. And check if different before update.
#					#	use update_attributes so triggers reindexing
#					sample.update_attributes!(:sample_type_id => sample_types[line['sample_subtype_id']],
#						:notes => notes.join("\n") )
#
#				end
#
#			else
#
#				#		TODO add comment that the sample probably has an incorrect sample type.
#				#	no need to reindex a "notes" change so just use update_column
#				notes << "Sample Type not found in tracking2k database check and may be incorrect (20140123)."
#				sample.update_column(:notes, notes.join("\n") )
#
#			end
#
#			#raise 'awe hell' if( sample.sample_type_id.to_i != sample_types[line['sample_subtype_id']].to_i )
#
##			csv_out << new_line
#		end
##		csv_report.close
##		csv_out.close
#	end
#
#
##	original .... ~/Mounts/SharedFiles/SoftwareDevelopment\(TBD\)/GrantApp/DataMigration/ODMS_samples_xxxxxx.csv
##Subject External Key,Sample External key,Original Index,smp_key,
##		smp_extr_key,sbj_key,sbj_extr_key,smp_type,smp_recvd_date,
##		smp_collected_date,smp_from_location,sbj_sex,,Count
##	20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv
##CCLS_153515,0013528,86,54228,13528,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,1
##CCLS_153515,0013529,87,54229,13529,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,2
##CCLS_153515,0013530,88,54230,13530,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,3
##
##	Subject External Key = CCLS_ child's subjectid or mother's subjectid
##	Sample External key = sample id with leading zero's
##	Original Index = ?
##	smp_key = ?
##	smp_extr_key = sample id
##	sbj_key = not unique
##	sbj_extr_key = CCLS_ child's subjectid or mother's subjectid
##	smp_type = gegl sample type
##	smp_recvd_date =
##	smp_collected_date =
##	smp_from_location = 14?
##	sbj_sex = 1 or 2
##	____ = nothing?
##	Count =
##	
#
#	task :buccal_saliva_list_check_and_update => :environment do
#		(csv_in = CSV.open( 'data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv',
#				'rb',{ :headers => true })).each do |line|
#			puts line
#			sample = Sample.find(line['smp_extr_key'].to_i)
#			if sample.sample_type.gegl_sample_type_id != line['smp_type'][0]
#
#				puts
#				puts sample.sample_type.inspect
#				puts
#				
#				notes = [sample.notes].compact
#				sample_type_id = if line['smp_type'][0] == 'u'
#					SampleType[:otherbuccal].id	#	24
#				elsif line['smp_type'][0] == 's'
#					SampleType[:othersaliva].id	#	21
#				else
#					raise "Confused.  I wasn't expecting that GEGL sample type."
#				end
#				new_note  = "Sample Type discrepancy found in 20131101_14KBuccalSalivaList_ResponseToEmail20131028. "
#				new_note << "The lab says that this sample is GEGL Sample Type #{line['smp_type']} "
#				new_note << "but we have the sample type id as #{sample.sample_type_id} which "
#				new_note << "corresponds to GEGL Sample Type #{sample.sample_type.gegl_sample_type_id}. "
#				new_note << "Changing sample type id to #{sample_type_id} (20140123)."
#				notes << new_note
#					
#				sample.update_attributes!(:sample_type_id => sample_type_id,
#					:notes => notes.join("\n") )
#
#			end
#		end
#	end
#
#	task :buccal_saliva_list_compare => :environment do
#		total_lines = total_lines('data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv')
#		columns = csv_columns('data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv')
#
#		columns += %w{ccls_sampleid ccls_sample_type ccls_subject_type }
#		columns += %w{ccls_familyid ccls_matchingid ccls_subjectid}
#		columns += %w{ccls_childid ccls_studyid ccls_patid ccls_sex ccls_external_id}
#		columns += %w{ccls_sample_type_id ccls_t2k_sample_type_id ccls_gegl_sample_type_id}
#		columns += %w{ccls_subjectid_differ_with_csv_subjectid}
#		columns += %w{ccls_familyid_with_csv_subjectid}
#		columns += %w{ccls_matchingid_with_csv_subjectid}
#		columns += %w{ccls_subjectid_with_csv_subjectid}
#		columns += %w{ccls_childid_with_csv_subjectid}
#		columns += %w{ccls_studyid_with_csv_subjectid}
#		columns += %w{ccls_patid_with_csv_subjectid}
#		columns += %w{ccls_sex_with_csv_subjectid}
#		columns += %w{ccls_subject_type_with_csv_subjectid}
#
#		csv_out = CSV.open('data/20131101_14KBuccalSalivaList_ResponseToEmail20131028_PLUS_OUR_INFO.csv', 'w')
#		csv_out << columns
#
#		(csv_in = CSV.open( 'data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv',
#				'rb',{ :headers => true })).each do |line|
#			puts line
#			new_line = line
#
#			sample = Sample.find(line['smp_extr_key'].to_i)
#			subject = sample.study_subject
#			new_line << sample.sampleid
#			new_line << sample.sample_type
#			new_line << subject.subject_type
#			new_line << subject.familyid
#			new_line << subject.matchingid
#			new_line << subject.subjectid
#			new_line << subject.childid
#			new_line << subject.studyid
#			new_line << subject.patid
#			new_line << subject.sex
#			new_line << sample.external_id
#			new_line << sample.sample_type_id
#			new_line << sample.sample_type.t2k_sample_type_id
#			new_line << sample.sample_type.gegl_sample_type_id
#			csv_subjectid = line['sbj_extr_key'].to_s.split(/_/)[1]
#			new_line << ( ( csv_subjectid == subject.subjectid ) ? 'SAME' : (
#				( StudySubject.with_familyid(subject.familyid).collect(&:subjectid).include?(csv_subjectid) ) ?
#					'FAMILYDIFFER' : (
#				( StudySubject.with_matchingid(subject.matchingid).collect(&:subjectid).include?(csv_subjectid) ) ?
#					'MATCHINGDIFFER' : 'UNKNOWN' ) )
#			)
#			csv_subject = StudySubject.with_subjectid(csv_subjectid).first
#			new_line << csv_subject.familyid
#			new_line << csv_subject.matchingid
#			new_line << csv_subject.subjectid
#			new_line << csv_subject.childid
#			new_line << csv_subject.studyid
#			new_line << csv_subject.patid
#			new_line << csv_subject.sex
#			new_line << csv_subject.subject_type
#
#puts new_line
#
##			puts line['sbj_extr_key'].to_s.split(/_/)[1]
##			puts subject.subjectid
##			puts subject.mother.subjectid
##			assert_string_in( line['sbj_extr_key'].to_s.split(/_/)[1],
##				[subject.subjectid,subject.mother.try(:subjectid)].compact, "subjectid")
##
##	most have matching sampleid/subjectid.
##	some have matching sampleid/subject.mother.subjectid
##	few  have matching sampleid/subject.matching.subjectid ?????
##
##			assert_string_in( line['sbj_extr_key'].to_s.split(/_/)[1],
##				StudySubject.with_matchingid(subject.matchingid).collect(&:subjectid), "subjectid")
#
##Subject External Key,Sample External key,Original Index,smp_key,smp_extr_key,sbj_key,sbj_extr_key,smp_type,smp_recvd_date,smp_collected_date,smp_from_location,sbj_sex,,Count,ccls_sampleid,ccls_sample_type,ccls_subjectid,ccls_childid,ccls_studyid,ccls_sex,ccls_external_id,ccls_sample_type_id,ccls_t2k_sample_type_id,ccls_gegl_sample_type_id
##CCLS_153515,0013528,86,54228,13528,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,1,0013528,archive newborn blood,972069,9502,1487-C-0,M,131402,16,6,bg
#
#			csv_out << new_line
#		end	#	'data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv'
#		csv_out.close
#	end	#	task :buccal_saliva_list_compare => :environment do

#	20160418 - Commented out to avoid accidental usage.
#	task :dematernalize => :environment do
##		%w( momblood momurine ).each do |sample_type_key|
#		{ :momblood => :'13', :momurine => :unspecifiedurine }.each do |sample_type_key,new_type_key|
#			puts sample_type_key
#			puts SampleType[sample_type_key].samples.count
#			SampleType[sample_type_key].samples.each do |sample|
#
#				#	maternal samples are being attached to mother ( only 2 found that aren't )
#				if sample.study_subject.mother.nil?
#					puts "Sample's subject's mother doesn't exist in db. Creating."
#					sample.study_subject.create_mother
#					raise "mother creation failed?" if sample.study_subject.mother.nil?
#				end
#
##				puts sample.study_subject.subject_type
#				if sample.study_subject.subject_type.to_s != 'Mother'
#
##	there are 2 maternal samples, 1 blood, 1 urine that are attached to a case subject
##	this case subject does not have a mother subject
##	all other maternal samples are attached to mothers and as such
##	could easily just be retyped to the non-maternal sample type
##	study subject id 1143
#
##					puts sample.study_subject.inspect
##					puts sample.study_subject.mother.inspect
#
#					puts "moving sample to mother"
#					sample.study_subject = sample.study_subject.mother
#
##					raise "sample move failed?" if sample.reload.study_subject.subject_type.to_s != 'Mother'
#
#				end
#
#				sample.sample_type = SampleType[new_type_key]
#
#				sample.save!
#			end
#
#			#	momblood
#			#	358
#			#	momurine
#			#	1276
#
#		end	#	%w( momblood momurine ).each do |sample_type_key|
#	end	#	task :dematernalize => :environment do


#	task :synchronize_sample_temperature_with_sample_temperature_id => :environment do
#		SampleTemperature.all.each do |sample_temperature|
#			#	only have room temp or refrigerated in db
#			puts "Updating #{Sample.where(:sample_temperature_id => sample_temperature.id).count} " <<
#				"'#{sample_temperature}' samples with :#{sample_temperature.description.titleize}:"
#			Sample.where(:sample_temperature_id => sample_temperature.id)
#				.update_all(:sample_temperature => sample_temperature.description.titleize )
#		end # SampleTemperature.all
#	end	#	task :synchronize_sample_temperature_with_sample_temperature_id => :environment do


#	task :synchronize_sample_format_with_sample_format_id => :environment do
#		SampleFormat.all.each do |sample_format|
#			#	only have guthrie cards in db
#			puts "Updating #{Sample.where(:sample_format_id => sample_format.id).count} " <<
#				"'#{sample_format}' samples with :#{sample_format.description.titleize}:"
#			Sample.where(:sample_format_id => sample_format.id)
#				.update_all(:sample_format => sample_format.description.titleize )
#		end # SampleFormat.all
#	end	#	task :synchronize_sample_format_with_sample_format_id => :environment do

end	#	namespace :samples do
end	#	namespace :app do

__END__

roomtemp:
  id: 1
  key: roomtemp
  description: room temperature
refrigerated:
  id: 2
  key: refrigerated
  description: refrigerated
legacy:
  id: 777
  key: legacy
  description: legacy data import
dk:
  id: 999
  key: unknown
  description: storage temperature unknown


guthrie:
  id:  1
  key:  guthrie
  description:  guthrie card
slide:
  id:  2
  key:  slide
  description:  slide
bag:
  id: 3
  key: bag
  description: vacuum bag
other:
  id:  4
  key:  other
  description:  Other Source
legacy:
  id:  777
  key:  tracking2k
  description:  Migrated from CCLS Legacy Tracking2k database
dk:
  id: 999
  key: unknown
  description:  unknown data source
