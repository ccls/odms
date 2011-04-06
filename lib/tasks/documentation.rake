namespace :doc do	|doc|

	desc "Tables to CSV"
	task :tables_to_csv => :environment do
		puts ',"Home Exposures Metadata",,,,,,,,,,'
		puts ',,,,,,,,,,,'
		puts ',"Source Table Info",,,,"Destination Table Info",,,,,,'
		puts ',"Source Table","Fieldname","Data Type","Length","Destination Table",,"Fieldname","Data Type","Length","Data Source","Notes"'

		#	in development, by default, the models are eager loaded,
		#	so we need to load them manually.
#		%w( vendor/plugins/surveyor/app/models ).each do |load_path|
		%w( app/models ).each do |load_path|
			matcher = /\A#{Regexp.escape(load_path)}(.*)\.rb\Z/
			Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
				require_dependency file.sub(matcher, '\1')
			end
		end

		skip = %w( Import Export BdrbJobQueue )
		Object.subclasses_of(ActiveRecord::Base).sort_by{|a|a.name}.each do |ar|
			next if skip.include?(ar.name)
			table_name = ar.table_name
			ar.columns.each do |c|
				puts ",,,,,\"#{table_name}\",,\"#{c.name}\",\"#{c.type}\",\"#{c.sql_type}\""
			end
		end

	end

end
