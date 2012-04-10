require 'fastercsv'

namespace :app do
namespace :zip_codes do

	task :destroy_all => :environment do
#	uses the default scope limit of 10 so doesn't destroy ALL. 
#		ZipCode.destroy_all	
		ZipCode.unscoped.destroy_all	
	end

	task :import_all => :destroy_all do
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open("production/fixtures/zip_codes.csv", 
				'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}:#{line}"
#"id","zip_code","city","state","zip_class","county_id"
#1,"00501","HOLTSVILLE","NY","UNIQUE",1735
#2,"00544","HOLTSVILLE","NY","UNIQUE",1735

			zip_code = ZipCode.create! do |z|
#
#	I don't think that anything references a zip code id,
#	but since I have one, there is no reason not to copy it.
#
				z.id = line['id']
				z.zip_code = line['zip_code']
				z.city = line['city']
				z.state = line['state']
				z.zip_class = line['zip_class']
				z.county_id = line['county_id']
			end


			if zip_code.id != line['id'].to_i
				raise "ZipCode id mismatch."
			end


		end
	end

end
end
