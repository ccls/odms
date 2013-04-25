namespace :app do
namespace :study_subjects do

	task :synchronize_subject_type_with_subject_type_id => :environment do
		SubjectType.all.each do |subject_type|

			StudySubject.where(:subject_type_id => subject_type.id)
				.update_all(:subject_type => subject_type.to_s )

		end	#	SubjectType.all
	end

end	#	namespace :study_subjects do
end	#	namespace :app do
__END__
