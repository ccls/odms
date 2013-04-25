namespace :app do
namespace :study_subjects do

	task :synchronize_subject_type_with_subject_type_id => :environment do
		SubjectType.all.each do |subject_type|
			puts "Updating #{subject_type} subjects"
			StudySubject.where(:subject_type_id => subject_type.id)
				.update_all(:subject_type => subject_type.to_s )
		end	#	SubjectType.all
	end

	task :synchronize_vital_status_with_vital_status_id => :environment do
		VitalStatus.all.each do |vital_status|
			puts "Updating #{vital_status} subjects"
#			StudySubject.where(:vital_status_id => vital_status.id)
			StudySubject.where(:vital_status_code => vital_status.code)
				.update_all(:vital_status => vital_status.to_s )
		end	#	VitalStatus.all
	end

end	#	namespace :study_subjects do
end	#	namespace :app do
__END__
