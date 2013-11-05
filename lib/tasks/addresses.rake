namespace :app do
namespace :addresses do

#	task :synchronize_address_type_with_address_type_id => :environment do
#		AddressType.all.each do |address_type|
#			puts "Updating #{Address.where(:address_type_id => address_type.id).count} " <<
#				"'#{address_type}' addresses with :#{address_type.key.titleize}:"
#			#	use KEY instead of DESCRIPTION for address type
#			Address.where(:address_type_id => address_type.id)
#				.update_all(:address_type => address_type.key.titleize )
#		end	#	AddressType.all
#	end

	task :geocode => :environment do
		puts Time.zone.now
		puts "Address.needs_geocoded ... #{Address.needs_geocoded.count}"
		puts "Address.geocoding_failed ... #{Address.geocoding_failed.count}"

		Geocoder.configure(
			:always_raise => [Geocoder::OverQueryLimitError], 
			:use_https => true)

		Address.needs_geocoded.not_geocoding_failed.limit(1000).each do |address|
#		Address.needs_geocoded.limit(1000).each do |address|

			puts "Geocoding ... #{address.full}"
			zip = address.zip[0..4]

			results = Geocoder.search(address.full)

			#	find first with matching (first 5 in) zip code?
			result = results.detect{|result| result.postal_code == zip }

			address.update_column(:geocoding_response, Marshal.dump(results) )

			if result.blank?
				address.update_column(:geocoding_failed, true)
				puts "Hmm.  No google results?"
			else
				puts "Closest google address ... #{result.address}"
				address.update_column(:geocoding_failed, false)
				address.update_column(:needs_geocoded, false)
				address.update_column(:latitude, result.latitude )
				address.update_column(:longitude, result.longitude )
				if address.study_subject #	not all have (dirty data from import)
					#	this is really only true if it is the subject's primary
					#	address used in the index, but alas, I won't know.
					#
					#	latlon column not set up yet so no need
					#
					address.study_subject.update_column(:needs_reindexed, true) 
				end
			end

			#	This will go faster than Google permits resulting in ...
			#	results = []
			#	result  = nil
			#	geocoding_response = "[]nil"
			sleep 1
		end
	end	#	task :geocode => :environment do

end	#	namespace :addresses do
end	#	namespace :app do
__END__
residence:
  id: 1
  key: residence
  description: home address
mailing:
  id: 2
  key: mailing
  description: mailing address (PO Box, APO, etc.)
business:
  id: 3
  key: business
  description: business address
other:
  id: 4
  key: other
  description: some other address type
dk:
  id: 999
  key: unknown
  description: address type unknown
