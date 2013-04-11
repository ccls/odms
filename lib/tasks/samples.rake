namespace :app do
namespace :samples do

	task :dematernalize => :environment do
		%w( momblood momurine ).each do |sample_type_key|
			puts sample_type_key
			puts SampleType[sample_type_key].samples.count
			SampleType[sample_type_key].samples.each do |sample|

				puts sample.study_subject.subject_type
				if sample.study_subject.subject_type.to_s != 'Mother'

#	there are 2 maternal samples, 1 blood, 1 urine that are attached to a case subject
#	this case subject does not have a mother subject
#	all other maternal samples are attached to mothers and as such
#	could easily just be retyped to the non-maternal sample type
#	study subject id 1143

					puts sample.study_subject.inspect
					puts sample.study_subject.mother.inspect

				end

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
