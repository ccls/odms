require 'csv'

namespace :app do
namespace :samples do

	def csv_columns(csv_file_name)
		f=CSV.open(csv_file_name, 'rb', :headers => false)
		csv_columns = f.gets
		f.close
		csv_columns
	end

	def assert(expression,message = 'Assertion failed.')
		raise "#{message} :\n #{caller[0]}" unless expression
	#puts "AAAAAAAAAAAAAAAA" unless expression
	end

	def assert_string_equal(a,b,field)
		assert a.to_s == b.to_s, "#{field} mismatch:#{a}:#{b}:"
	end

	def assert_string_in(a,b,field)
		assert b.include?(a.to_s), "#{field} value #{a} not included in:#{b}:"
	end

	task :recheck_original_sample_types => :environment do
		#ID,Sample_Type_ID,Description,Position,ODMS_sample_type_id,Code,GEGL_type_code
		sample_types_infile = 'tracking2k/sample_types.csv'
		#	Sample_Type_ID ... ODMS_sample_type_id
		sample_types={}
		(CSV.open( sample_types_infile, 'rb',{ :headers => true })).each do |line|
			#sample_types[line['Sample_Type_ID']] = line['ODMS_sample_type_id']
			#	Sample_Type_ID is really the parent sample type
			sample_types[line['ID']] = line['ODMS_sample_type_id']
		end



		#	id,sample_ID,subjectID,sample_subtype_id,sample_subtype_id_orig
		infile = 'tracking2k/samples.csv'
		total_lines = total_lines(infile)
		columns = csv_columns(infile)
#		csv_report = CSV.open('tracking2k/samples_report.csv', 'w')
#		csv_report << columns
#		csv_out = CSV.open('tracking2k/samples_out.csv', 'w')
#		columns << 'actual_sample_type_id'
#		csv_out << columns
		(csv_in = CSV.open( infile, 'rb',{ :headers => true })).each do |line|
			puts line
			new_line = line
			sample = Sample.find(line['id'].to_i)
			new_line << sample.sample_type_id
			puts new_line

			##	raise 'differe' if( line['sample_subtype_id'].to_s
			##		!= line['sample_subtype_id_orig'].to_s )
			#if( line['sample_subtype_id'].to_s != line['sample_subtype_id_orig'].to_s )
			#	#	csv_report << new_line
			#	csv_report << [line['sample_subtype_id'],line['sample_subtype_id_orig'],
			#		sample.sample_type_id]
			#end

			# sample_subtype_id seem to occassionally be missing (expect they are '20')
			# sample_subtype_id_orig seem to be bogus

			#	  ,6,16
			#	12,6,16
			#	13,6,16
			#	19,6,16
			#	20,6,16
			#	sample.sample_type_id should == sample_types[ line['sample_subtype_id'] || 20 ]



			puts ":#{line['sample_subtype_id']}: -> :#{sample_types[line['sample_subtype_id']]}:"
			puts ":#{line['sample_subtype_id_orig']}: -> :#{sample_types[line['sample_subtype_id_orig']]}:"
			puts ":#{sample.sample_type_id}:"
			puts ":#{sample_types[ line['sample_subtype_id'] || '20' ]}:"


#			assert_string_equal(sample.sample_type_id,
#				sample_types[ line['sample_subtype_id'] ],'type_id')



#			raise 'awe hell' if( sample.sample_type_id.to_i != sample_types[line['sample_subtype_id']].to_i )

			#raise "found a 13" if ( ( line['sample_subtype_id'].to_i == 13 ) || (sample.sample_type_id.to_i == 13 ) || ( line['sample_subtype_id_orig'].to_i == 13 ) )
			#	none are the same
			#raise "i'm confused" if( ( sample.sample_type_id.to_s == line['sample_subtype_id'].to_s ) || (sample.sample_type_id.to_s == line['sample_subtype_id_orig'].to_s ) )
#			csv_out << new_line
		end
#		csv_report.close
#		csv_out.close
	end





#	original .... ~/Mounts/SharedFiles/SoftwareDevelopment\(TBD\)/GrantApp/DataMigration/ODMS_samples_xxxxxx.csv
#Subject External Key,Sample External key,Original Index,smp_key,
#		smp_extr_key,sbj_key,sbj_extr_key,smp_type,smp_recvd_date,
#		smp_collected_date,smp_from_location,sbj_sex,,Count
#	20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv
#CCLS_153515,0013528,86,54228,13528,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,1
#CCLS_153515,0013529,87,54229,13529,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,2
#CCLS_153515,0013530,88,54230,13530,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,3
#
#	Subject External Key = CCLS_ child's subjectid or mother's subjectid
#	Sample External key = sample id with leading zero's
#	Original Index = ?
#	smp_key = ?
#	smp_extr_key = sample id
#	sbj_key = not unique
#	sbj_extr_key = CCLS_ child's subjectid or mother's subjectid
#	smp_type = gegl sample type
#	smp_recvd_date = 
#	smp_collected_date =
#	smp_from_location = 14?
#	sbj_sex = 1 or 2
#	____ = nothing?
#	Count = 
#	

	task :buccal_saliva_list_compare => :environment do
		total_lines = total_lines('data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv')
		columns = csv_columns('data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv')

		columns += %w{ccls_sampleid ccls_sample_type ccls_subject_type }
		columns += %w{ccls_familyid ccls_matchingid ccls_subjectid}
		columns += %w{ccls_childid ccls_studyid ccls_patid ccls_sex ccls_external_id}
		columns += %w{ccls_sample_type_id ccls_t2k_sample_type_id ccls_gegl_sample_type_id}
		columns += %w{ccls_subjectid_differ_with_csv_subjectid}
		columns += %w{ccls_familyid_with_csv_subjectid}
		columns += %w{ccls_matchingid_with_csv_subjectid}
		columns += %w{ccls_subjectid_with_csv_subjectid}
		columns += %w{ccls_childid_with_csv_subjectid}
		columns += %w{ccls_studyid_with_csv_subjectid}
		columns += %w{ccls_patid_with_csv_subjectid}
		columns += %w{ccls_sex_with_csv_subjectid}
		columns += %w{ccls_subject_type_with_csv_subjectid}

		csv_out = CSV.open('data/20131101_14KBuccalSalivaList_ResponseToEmail20131028_PLUS_OUR_INFO.csv', 'w')
		csv_out << columns

		(csv_in = CSV.open( 'data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv',
				'rb',{ :headers => true })).each do |line|
			puts line
			new_line = line

			sample = Sample.find(line['smp_extr_key'].to_i)
			subject = sample.study_subject
			new_line << sample.sampleid
			new_line << sample.sample_type
			new_line << subject.subject_type
			new_line << subject.familyid
			new_line << subject.matchingid
			new_line << subject.subjectid
			new_line << subject.childid
			new_line << subject.studyid
			new_line << subject.patid
			new_line << subject.sex
			new_line << sample.external_id
			new_line << sample.sample_type_id
			new_line << sample.sample_type.t2k_sample_type_id
			new_line << sample.sample_type.gegl_sample_type_id
			csv_subjectid = line['sbj_extr_key'].to_s.split(/_/)[1]
			new_line << ( ( csv_subjectid == subject.subjectid ) ? 'SAME' : (
				( StudySubject.with_familyid(subject.familyid).collect(&:subjectid).include?(csv_subjectid) ) ? 
					'FAMILYDIFFER' : (
				( StudySubject.with_matchingid(subject.matchingid).collect(&:subjectid).include?(csv_subjectid) ) ? 
					'MATCHINGDIFFER' : 'UNKNOWN' ) )
			)
			csv_subject = StudySubject.with_subjectid(csv_subjectid).first
			new_line << csv_subject.familyid
			new_line << csv_subject.matchingid
			new_line << csv_subject.subjectid
			new_line << csv_subject.childid
			new_line << csv_subject.studyid
			new_line << csv_subject.patid
			new_line << csv_subject.sex
			new_line << csv_subject.subject_type

puts new_line

#			puts line['sbj_extr_key'].to_s.split(/_/)[1]
#			puts subject.subjectid
#			puts subject.mother.subjectid
#			assert_string_in( line['sbj_extr_key'].to_s.split(/_/)[1],
#				[subject.subjectid,subject.mother.try(:subjectid)].compact, "subjectid")
#
#	most have matching sampleid/subjectid.
#	some have matching sampleid/subject.mother.subjectid
#	few  have matching sampleid/subject.matching.subjectid ?????
#
#			assert_string_in( line['sbj_extr_key'].to_s.split(/_/)[1],
#				StudySubject.with_matchingid(subject.matchingid).collect(&:subjectid), "subjectid")

#Subject External Key,Sample External key,Original Index,smp_key,smp_extr_key,sbj_key,sbj_extr_key,smp_type,smp_recvd_date,smp_collected_date,smp_from_location,sbj_sex,,Count,ccls_sampleid,ccls_sample_type,ccls_subjectid,ccls_childid,ccls_studyid,ccls_sex,ccls_external_id,ccls_sample_type_id,ccls_t2k_sample_type_id,ccls_gegl_sample_type_id
#CCLS_153515,0013528,86,54228,13528,22582,CCLS_153515,s,2011-02-22,2007-08-11,14,2,,1,0013528,archive newborn blood,972069,9502,1487-C-0,M,131402,16,6,bg

			csv_out << new_line
		end	#	'data/20131101_14KBuccalSalivaList_ResponseToEmail20131028.csv'
		csv_out.close
	end	#	task :buccal_saliva_list_compare => :environment do

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
