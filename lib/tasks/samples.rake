namespace :app do
namespace :samples do

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

	task :synchronize_sample_temperature_with_sample_temperature_id => :environment do
		SampleTemperature.all.each do |sample_temperature|
			#	only have room temp or refrigerated in db
			puts "Updating #{Sample.where(:sample_temperature_id => sample_temperature.id).count} " <<
				"'#{sample_temperature}' samples with :#{sample_temperature.description.titleize}:"
#			Sample.where(:sample_temperature_id => sample_temperature.id)
#				.update_all(:sample_temperature => sample_temperature.description.titleize )
		end # SampleTemperature.all
	end	#	task :synchronize_sample_temperature_with_sample_temperature_id => :environment do

	task :synchronize_sample_format_with_sample_format_id => :environment do
		SampleFormat.all.each do |sample_format|
			#	only have guthrie cards in db
			puts "Updating #{Sample.where(:sample_format_id => sample_format.id).count} " <<
				"'#{sample_format}' samples with :#{sample_format.description.titleize}:"
#			Sample.where(:sample_format_id => sample_format.id)
#				.update_all(:sample_format => sample_format.description.titleize )
		end # SampleFormat.all
	end	#	task :synchronize_sample_format_with_sample_format_id => :environment do

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
