namespace :app do
namespace :study_subjects do

	task :synchronize_counter_caches => :environment do
		StudySubject.find_each do |study_subject|
			puts "Updating #{study_subject}"
			StudySubject.reset_counters( study_subject.id,
				:samples, :operational_events, :addressings, :phone_numbers, 
				:birth_data, :interviews )
		end
	end

	task :add_cdcids_from_anand => :environment do
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
