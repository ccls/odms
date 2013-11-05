namespace :app do
namespace :addressings do

	task :synchronize_data_source_with_data_source_id => :environment do
		DataSource.all.each do |data_source|
			puts "Updating #{Addressing.where(:data_source_id => data_source.id).count} " <<
				"'#{data_source}' phone numbers with :#{data_source.description}:"
			#	Don't titleize this
#			Addressing.where(:data_source_id => data_source.id)
#				.update_all(:data_source => data_source.description )
		end	#	DataSource.all
	end

end	#	namespace :addressings do
end	#	namespace :app do
__END__

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
