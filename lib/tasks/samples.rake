require 'csv'

namespace :app do
namespace :samples do

	def csv_columns(csv_file_name)
		f=CSV.open(csv_file_name, 'rb', :headers => false)
		csv_columns = f.gets
		f.close
		csv_columns
	end

	task :correct_subject_association => :environment do
		raise "This task has been run and disabled."
		CSV.open( 'data/20140422_corrected_subject_sample.csv','rb',{ :headers => true }).each do |line|
			#	subjectid,corrected_subjectid,sampleid,sample_super_type,sample_type
			puts line
			sample = Sample.find(line['sampleid'].to_i)
			assert_string_equal( sample.sampleid, line['sampleid'], :sampleid)
			#	assert_string_equal( sample.subjectid, line['subjectid'], :subjectid)
			assert_string_equal( sample.subjectid, line['corrected_subjectid'], :subjectid)
			assert_string_equal( sample.sample_type, line['sample_type'], :sample_type)
			assert_string_equal( sample.sample_type_parent, line['sample_super_type'], :sample_type_parent)

			if line['subjectid'] != line['corrected_subjectid']
				subject = StudySubject.with_subjectid(line['subjectid']).first
				puts subject.samples_count
				#	Sample will automatically reindex as it changes
				#	BOTH Subjects MAY not as it doesn't change, (the counter does)
				#	New subject will be triggered, but not the old.
				#	CounterCaches are only updated in the database so won't trigger reindex.
				#	Triggering both.
				correct_subject = StudySubject.with_subjectid(line['corrected_subjectid']).first
				assert_string_equal( correct_subject.subjectid, line['corrected_subjectid'], :corrected_subjectid)
				puts correct_subject.samples_count
				correct_subject.samples << sample
				puts correct_subject.reload.samples_count
				correct_subject.update_column(:needs_reindexed, true)

				subject = StudySubject.with_subjectid(line['subjectid']).first
				assert_string_equal( subject.subjectid, line['subjectid'], :subjectid)
				puts subject.samples_count
				subject.update_column(:needs_reindexed, true)

				notes = [sample.notes.presence].compact
				notes << "Sample moved from child subjectid #{line['subjectid']} to mother #{line['corrected_subjectid']} (20140422)."
				sample.update_attributes!(:notes => notes.join("\n"))
				puts sample.notes
			end
		end	#	CSV.open( 'data/corrected_subject_sample.csv'
	end	#	task :correct_subject_association => :environment do

	task :merge_overlaps_with_icf_master_id => :environment do
		raise "This task has been run and disabled."
		icf_master_ids = {}
		CSV.open( 'data/statefileno_ccrlp.csv','rb',{ :headers => true }).each do |line|
			raise "ICF Master ID already used" if icf_master_ids.has_key? line['derived_state_file_no_last6']
			icf_master_ids[ line['derived_state_file_no_last6'] ] = line['icf_master_id']
		end
		columns=csv_columns( 'data/20140303_overlaps.csv')
		puts "icf_master_id,#{columns.join(',')}"
		CSV.open( 'data/20140303_overlaps.csv','rb',{ :headers => true }).each do |line|
			puts "#{icf_master_ids[ line['SFN'] ]},#{line}"
		end
	end	#	task :merge_overlaps_with_icf_master_id => :environment do

	task :import_overlaps => :environment do
		raise "This task has been run and disabled."
		ifile = "data/20140303_overlaps_with_icf_master_ids.csv"
		ofile = "data/20140303_overlaps_with_icf_master_ids_subjectids_sampleids.csv"
		mfile = "data/20140305_manifest.csv"
		csv_out = CSV.open( ofile, 'w')
		manifest = CSV.open( mfile, 'w')
		manifest << %w( icf_master_id subjectid sex sampleid gegl_sample_type_id
			collected_from_subject_at received_by_ccls_at storage_temperature sent_to_lab_at )
		columns=csv_columns( 'data/20140303_overlaps_with_icf_master_ids.csv')
		puts "#{columns.join(',')},subjectid,sampleid"
		csv_out << columns + %w(subjectid sampleid)
		(csv_in = CSV.open( ifile, 'rb',{ :headers => true })).each do |line|
			subjects = StudySubject.where(:icf_master_id => line['icf_master_id'])
			puts "Subject not found with #{sfn}" if subjects.empty?
			if subjects.length > 1
				puts "Multiple found with #{sfn}" 
				puts subjects.inspect
			end
			subject = subjects.first
			if line['DOB'] != subject.dob.strftime("%Y%m%d")
				puts "DOB not the same #{line['DOB']} - #{subject.dob.strftime("%Y%m%d")}"
			end
			#	icf_master_id,DOB,SFN,pull,barcode,blindid,c_dob,birth_year,combo_id
			sample = subject.samples.create!(
				:project_id => Project[:ccls].id,
				:location_id => Organization['GEGL'].id,
				:sample_type_id => SampleType[:guthrie].id,
				:sample_format => "Guthrie Card",
				:sample_temperature => "Refrigerated",
				:received_by_ccls_at => "3/5/2014",
				:sent_to_lab_at => "3/5/2014",
				:external_id => line['barcode'],
				:external_id_source => "20140303_overlaps_with_icf_master_ids.csv",
				:notes => "Imported from 20140303_overlaps_with_icf_master_ids.csv\n" <<
					"pull #{line['pull']},\n"<<
					"barcode #{line['barcode']},\n"<<
					"blindid #{line['blindid']}"
			)
			puts "#{line.to_s.chomp},#{subject.subjectid},#{sample.sampleid}"
			new_line = line
			new_line.push(subject.subjectid,sample.sampleid)
			csv_out << new_line
			manifest <<	[ sample.study_subject.icf_master_id_to_s,
				" #{sample.study_subject.subjectid}",
				sample.study_subject.sex,
				" #{sample.sampleid}",
				sample.sample_type.gegl_sample_type_id,nil,
				"3/5/2014",
				sample.sample_temperature,
				"3/5/2014" ]
		end	#	(csv_in = CSV.open( ifile, 'rb',{ :headers => true })).each do |line|
		manifest.close
		csv_out.close
	end	#	task :overlaps => :environment do

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

	task :dematernalize => :environment do
#		%w( momblood momurine ).each do |sample_type_key|
		{ :momblood => :'13', :momurine => :unspecifiedurine }.each do |sample_type_key,new_type_key|
			puts sample_type_key
			puts SampleType[sample_type_key].samples.count
			SampleType[sample_type_key].samples.each do |sample|

				#	maternal samples are being attached to mother ( only 2 found that aren't )
				if sample.study_subject.mother.nil?
					puts "Sample's subject's mother doesn't exist in db. Creating."
					sample.study_subject.create_mother 
					raise "mother creation failed?" if sample.study_subject.mother.nil?
				end

#				puts sample.study_subject.subject_type
				if sample.study_subject.subject_type.to_s != 'Mother'

#	there are 2 maternal samples, 1 blood, 1 urine that are attached to a case subject
#	this case subject does not have a mother subject
#	all other maternal samples are attached to mothers and as such
#	could easily just be retyped to the non-maternal sample type
#	study subject id 1143

#					puts sample.study_subject.inspect
#					puts sample.study_subject.mother.inspect

					puts "moving sample to mother"
					sample.study_subject = sample.study_subject.mother

#					raise "sample move failed?" if sample.reload.study_subject.subject_type.to_s != 'Mother'

				end

				sample.sample_type = SampleType[new_type_key]

				sample.save!
			end

			#	momblood
			#	358
			#	momurine
			#	1276

		end	#	%w( momblood momurine ).each do |sample_type_key|
	end	#	task :dematernalize => :environment do

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
