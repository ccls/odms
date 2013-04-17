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

		end	#	%w( momblood momurine ).each do |sample_type_key|
	end

end	#	namespace :samples do
end	#	namespace :app do

__END__

momblood
358
momurine
1276
