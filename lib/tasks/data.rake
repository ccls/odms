namespace :app do
namespace :data do

	desc "Show basic data report and counts"
	task :report => :environment do
	end

	desc "Dump some database tables to xml files"
	task :export_to_xml => :environment do
	end

end	#	namespace :data do
end	#	namespace :app do
