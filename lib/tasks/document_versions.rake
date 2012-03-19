require 'fastercsv'

namespace :app do
namespace :document_versions do

	task :destroy_all => :environment do
#		ZipCode.destroy_all
	end

	task :import_all => :destroy_all do
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open("production/fixtures/document_versions.csv", 
				'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line
		end
	end

end
end
