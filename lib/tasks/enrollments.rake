namespace :app do
namespace :enrollments do

	task :synchronize_tracing_status_with_tracing_status_id => :environment do
		TracingStatus.all.each do |tracing_status|
			puts "Updating #{Enrollment.where(:tracing_status_id => tracing_status.id).count}" <<
				" '#{tracing_status}' enrollments with :#{tracing_status.description.titleize}:"
#			Enrollment.where(:tracing_status_id => tracing_status.id)
#				.update_all(:tracing_status => tracing_status.description.titleize )
		end	#	TracingStatus.all
	end

end	#	namespace :phone_numbers do
end	#	namespace :app do
__END__

tracing:
  id: 1
  position: 1
  key: tracing
  description: subject tracing in progress
found:
  id: 2
  position: 2
  key: found
  description: subject found
utl:
  id: 3
  position: 3
  key: UTL
  description: unable to locate
dk:
  id: 999
  position: 4
  key: unknown
  description: unknown tracing status
