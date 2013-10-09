namespace :automate do
	task :geocode => :environment do
		puts Time.zone.now

		Geocoder.configure(:always_raise => [Geocoder::OverQueryLimitError], 
			:use_https => true)

		Address.needs_geocoded.not_geocoding_failed.limit(1000).each do |address|
#		Address.needs_geocoded.limit(1000).each do |address|

			puts "Geocoding ... #{address.full}"
			zip = address.zip[0..4]

			results = Geocoder.search(address.full)

#	This will print ...
#	Google Geocoding API error: over query limit.
#	... if over limit, but doesn't set any flags anywhere.
#	How to catch this and stop?

#			puts results.inspect

			#	find first with matching (first 5 in) zip code?
			result = results.detect{|result| result.postal_code == zip }

			address.update_column(:geocoding_response, Marshal.dump(results) )

			if result.blank?
				address.update_column(:geocoding_failed, true)

#				puts
#				puts
				puts "Hmm.  No google results?"
#				puts
#				puts

			else

#				puts result.inspect

#				puts result.latitude
#				puts result.longitude
				puts "Closest google address ... #{result.address}"
#				puts result.city
#				puts result.state
#				puts result.postal_code

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
end
