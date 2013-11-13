namespace :app do
namespace :addressings do

#	task :synchronize_data_source_with_data_source_id => :environment do
#		DataSource.all.each do |data_source|
#			puts "Updating #{Addressing.where(:data_source_id => data_source.id).count} " <<
#				"'#{data_source}' phone numbers with :#{data_source.description}:"
#			#	Don't titleize this
#			Addressing.where(:data_source_id => data_source.id)
#				.update_all(:data_source => data_source.description )
#		end	#	DataSource.all
#	end

	task :import_address_data => :environment do
		puts count = Addressing.count
		#	need to add a temp definition for Address as it has been archived.
		class Address < ActiveRecord::Base; end
		Addressing.all.each do |addressing|
			puts "#{addressing.id}/#{count}"
			address = Address.find(addressing.address_id)
			Addressing.where(:id => addressing.id).update_all({
				:line_1 => address.line_1,
				:line_2 => address.line_2,
				:city => address.city,
				:state => address.state,
				:zip => address.zip,
				:external_address_id => address.external_address_id,
				:county => address.county,
				:unit => address.unit,
				:country => address.country,
				:needs_geocoded => address.needs_geocoded,
				:geocoding_failed => address.geocoding_failed,
				:longitude => address.longitude,
				:latitude => address.latitude,
				:geocoding_response => address.geocoding_response,
				:address_type => address.address_type,
			}) if address.present?
		end
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
