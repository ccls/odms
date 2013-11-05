namespace :app do
namespace :phone_numbers do

	task :synchronize_phone_type_with_phone_type_id => :environment do
		PhoneType.all.each do |phone_type|
			puts "Updating #{PhoneNumber.where(:phone_type_id => phone_type.id).count} " <<
				"'#{phone_type}' phone numbers with :#{phone_type.key.titleize}:"
			# use KEY instead of DESCRIPTION for phone type (actually they are the same)
			PhoneNumber.where(:phone_type_id => phone_type.id)
				.update_all(:phone_type => phone_type.key.titleize )
		end	#	PhoneType.all
	end

	task :synchronize_data_source_with_data_source_id => :environment do
		DataSource.all.each do |data_source|
			puts "Updating #{PhoneNumber.where(:data_source_id => data_source.id).count} " <<
				"'#{data_source}' phone numbers with :#{data_source.description}:"
			#	Don't titleize this
			PhoneNumber.where(:data_source_id => data_source.id)
				.update_all(:data_source => data_source.description )
		end	#	DataSource.all
	end

end	#	namespace :phone_numbers do
end	#	namespace :app do
__END__
home:
  id: 1
  position: 1
  key: home
  description: home
mobile:
  id: 2
  position: 2
  key: mobile
  description: mobile
work:
  id: 3
  position: 3
  key: work
  description: work
dk:
  id: 999
  position: 4
  key: unknown
  description: unknown

raf:
  id:  1
  key:  raf
  description:  RAF (CCLS Rapid Ascertainment Form)
consent:
  id:  2
  key:  consent
  description:  Study Consent Form
interview:
  id:  3
  key:  interview
  description:  Interview with Subject
usps:
  id:  4
  key:  usps
  description:  USPS Address Service
other:
  id:  5
  key:  other
  description:  Other Source
legacy:
  id:  777
  key:  tracking2k
  description:  Migrated from Tracking2k database
dk:
  id: 999
  key: unknown
  description:  unknown data source
src:
  id:  7
  key:  src
  description:  Provided by Survey Research Center ("SRC")
icf:
  id: 8
  key: icf
  description:  Provided to CCLS by ICF
birth:
  id: 9
  key: birthdata
  description:  Live Birth data from USC
