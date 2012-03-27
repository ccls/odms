class Hash
	#	From http://snippets.dzone.com/posts/show/5811
  # Renaming and replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
  # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
  def to_ordered_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v|   # <-- here's my addition (the 'sort')
#	The above sort, sorts the main yaml 'keys' or fixture labels.
#	k is a fixture label here, eg. "pages_001"
#	v is the attributes hash
#	The hash attributes are NOT sorted, unfortunately.
#	Still working on that one.
          map.add( k, v )


#pages_001:
#  position: 1
#  menu_en: CCLS
#  body_es:
        end
      end
    end
  end
end

namespace :app do
namespace :db do

	desc "Create yml fixtures for given model in database\n" <<
	     "rake app:db:extract_fixtures_from pages"
	task :extract_fixtures_from => :environment do
		me = $*.shift
		while( table_name = $*.shift )
#			File.open("#{RAILS_ROOT}/db/#{table_name}.yml", 'w') do |file|
			File.open("#{Rails.root}/db/#{table_name}.yml", 'w') do |file|
#				data = table_name.singularize.capitalize.constantize.find(
#				data = table_name.singularize.classify.constantize.find(
#					:all).collect(&:attributes)
#	Added unscoped to break any default scope and sort by id to add some order.
#	Doesn't seem to actually work though.  Still not sorted properly.
#	Cause the result is an unordered hash. Bummer
#	Still use unscoped, just in case there is a default scope with a limit.
#	
				data = table_name.singularize.classify.constantize.unscoped.order(
					'id asc').collect(&:attributes)
				file.write data.inject({}) { |hash, record|
					record.delete('created_at')
					record.delete('updated_at')
					#	so that it is really string sortable, add leading zeros
					hash["#{table_name}_#{sprintf('%03d',record['id'])}"] = record
					hash
				}.to_ordered_yaml
			end
		end
		exit
	end

	desc "Dump MYSQL table descriptions."
	task :describe => :environment do
		puts
		puts "FYI: This task ONLY works on MYSQL databases."
		puts
		config = ActiveRecord::Base.connection.instance_variable_get(:@config)
#=> {:adapter=>"mysql", :host=>"localhost", :password=>nil, :username=>"root", :database=>"my_development", :encoding=>"utf8"}

		tables = ActiveRecord::Base.connection.execute('show tables;')
		while( table = tables.fetch_row ) do
			puts "Table: #{table}"

			#	may have to include host and port
			system("mysql --table=true " <<
				"--user=#{config[:username]} " <<
				"--password='#{config[:password]}' " <<
				"--execute='describe #{table}' " <<
				config[:database]);

			#
			#	mysql formats the table well so doing it by hand is something that
			#	will have to wait until I feel like wasting my time
			#
			#	columns = ActiveRecord::Base.connection.execute("describe #{table};")
			#	while( column = columns.fetch_hash ) do
			#		puts column.keys Extra Default Null Type Field Key
			#	end
		end
	end

end	#	namespace :db do
end	#	namespace :app do
