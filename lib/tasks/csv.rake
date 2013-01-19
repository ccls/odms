require 'csv'
namespace :csv do

	desc "Show given columns values in each row of csv file"
	task :show_column_values => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		env_required('columns','is required comma separated list')
		columns = ENV['columns'].split(/\s*,\s*/)

		f=CSV.open( ENV['csv_file'], 'rb')
		header_line = f.gets
		f.close

		columns.each do |c|
			unless header_line.include?(c)
				puts
				puts "'#{c}' is not a valid column"
				puts "Columns are #{header_line.join(', ')}"
				puts
				exit
			end
		end

		columns_hash = {}

		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
#			columns.each { |c| printf("%s\t",line[c]) }
			columns.each do |column|
				columns_hash[column] ||= {}
				if columns_hash[column].has_key?(line[column])
					columns_hash[column][line[column]] += 1
				else
					columns_hash[column][line[column]] = 1
				end
			end	#	columns.each do |column|
		end	#	(f=CSV.open( ENV['csv_file'], 'rb',{
		columns.each do |column|
			puts column
			columns_hash[column].each do |k,v|
				puts "   :#{k}:#{v}"
			end
			puts
		end
	end	#	task :show_column_values => :environment do

	desc "Show given columns in each row of csv file"
	task :show_columns => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		env_required('columns','is required comma separated list')
		columns = ENV['columns'].split(/\s*,\s*/)

		f=CSV.open( ENV['csv_file'], 'rb')
		header_line = f.gets
		f.close

		columns.each do |c|
			unless header_line.include?(c)
				puts
				puts "'#{c}' is not a valid column"
				puts "Columns are #{header_line.join(', ')}"
				puts
				exit
			end
		end

		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
			columns.each { |c| printf("%s\t",line[c]) }
			puts
		end
	end

	desc "Count columns in each row of csv file"
	task :count_columns => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])

		counts = Hash.new(0)
		(f=CSV.open( ENV['csv_file'], 'rb' )).each do |line|
			counts[line.length] += 1
		end

		counts.each do |k,v|
			puts "#{v} rows have #{k} columns"
		end
	end

end

def env_required(var,msg='is required')
	if ENV[var].blank?
		puts
		puts "'#{var}' is not set and #{msg}"
		puts "Rerun with #{var}=something"
		puts
		exit
	end
end
def file_required(filename,msg='is required')
	unless File.exists?(filename)
		puts
		puts "File '#{filename}' was not found and #{msg}"
		puts
		exit
	end
end
