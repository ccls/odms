require 'fastercsv'

namespace :app do
namespace :counties do

	task :destroy_all => :environment do
		#	No limiting scope, but just in case
		County.unscoped.destroy_all	
	end

	task :import_all => :destroy_all do
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open("production/fixtures/counties.csv", 
				'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}:#{line}"

#"id","name","fips_code","state_abbrev"
#1,"Autauga","1001","AL"
#2,"Baldwin","1003","AL"
#3,"Barbour","1005","AL"
#4,"Bibb","1007","AL"

#	as the csv and db columns are the same
#	this could be simpler. Except for id and any
#	other mass-assignment restrictions

			county = County.create! do |c|
				c.id = line['id']
				c.name = line['name']
				c.fips_code = line['fips_code']
				c.state_abbrev = line['state_abbrev']
			end


			if county.id != line['id'].to_i
				raise "County id mismatch."
			end

		end
	end

end
end
