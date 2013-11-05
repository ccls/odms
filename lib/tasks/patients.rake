namespace :app do
namespace :patients do

#	task :synchronize_diagnosis_with_diagnosis_id => :environment do
#		Diagnosis.all.each do |diagnosis|
#			puts "Updating #{Patient.where(:diagnosis_id => diagnosis.id).count} " <<
#				"'#{diagnosis}' patients with :#{diagnosis.description}:"
#			#	don't titleize this
#			Patient.where(:diagnosis_id => diagnosis.id)
#				.update_all(:diagnosis => diagnosis.description )
#		end	#	Diagnosis.all
#	end

end	#	namespace :phone_numbers do
end	#	namespace :app do
__END__
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
