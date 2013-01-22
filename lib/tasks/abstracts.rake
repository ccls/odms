namespace :app do
namespace :abstracts do

	task :unused_fields => :environment do
		all_fields = []
		f=CSV.open('abstract_notes/ODMS_Abstracts_xxxxxx.csv', 'rb')
		header_line = f.gets
		f.close
		header_line.each{ |l| all_fields.push( l ) }
		used_fields = []
		(f=CSV.open("abstract_notes/Abstract_fieldsandtypes.csv",'rb',{ 
				:headers => true })).each do |line|
			modified_field_name = line['current_field_name'].downcase
			modified_field_name.gsub!(/\-/,'_')
			modified_field_name.gsub!(/\+/,'_')
			used_fields.push(modified_field_name)
		end

		puts (all_fields - used_fields).sort
		puts (all_fields - used_fields).length

		abstract = Abstract.new
		(all_fields - used_fields).each do |field|
			puts "#{field}:#{abstract.respond_to?(field)}"
		end
	end

	task :field_check => :environment do
# ~236 fields in Abst_DB_New_Var_Names_Aug2010.csv
# ~330 fields in fieldsandtypes.csv
#	 489 columns in ODMS_Abstracts_xxxxxx.csv
#	~342 columns in abstracts table

		all_fields = []
		require 'ostruct'

		#	loop over ODMS_Abstracts_xxxxxx.csv (all old fields)
		f=CSV.open('abstract_notes/ODMS_Abstracts_xxxxxx.csv', 'rb')
		header_line = f.gets
		f.close
		header_line.each{ |l| all_fields.push( OpenStruct.new(:data => l) ) }

		#	find conversion in Abstract_fieldsandtypes.csv
		(f=CSV.open("abstract_notes/Abstract_fieldsandtypes.csv",'rb',{ 
				:headers => true })).each do |line|
			next if line['current_field_name'].blank?
			existing = all_fields.detect{|f| f.data.to_s.downcase == line['current_field_name'].to_s.downcase }
			if existing
				existing.current_field_name = line['current_field_name']
				existing.new_field_name = line['new_field_name']
			else
				all_fields.push(OpenStruct.new(
					:current_field_name => line['current_field_name'],
					:new_field_name => line['new_field_name']) )
			end
		end

		#	save csv
		CSV.open('field_check.csv','wb') do |csv|
			csv << %w( dbtype new_field_name current_field_name DataFile )
			all_fields.sort{|a,b| (a.data||'') <=> (b.data||'') }.each do |field|
				db_name = field.new_field_name.to_s.downcase.gsub(/\+/,'_')
				db_field = Abstract.columns.detect{|c| c.name == db_name }
				csv << [ 
					( db_field.nil? ? nil : db_field.sql_type ),
					field.new_field_name, field.current_field_name, field.data ]
			end	#	all_fields.sort{|a,b| (a.data||'') <=> (b.data||'') }.each do |field|
			(Abstract.column_names - 
				all_fields.collect(&:new_field_name).compact.collect(&:downcase
					).collect{|f|f.gsub(/\+/,'_')} - 
				%w( id study_subject_id entry_1_by_uid entry_2_by_uid 
					merged_by_uid updated_at )).sort.each do |field|
				csv << [ Abstract.columns.detect{|c| c.name == field }.sql_type, field ]
			end

		end	#	CSV.open('field_check.csv','wb') do |csv|

	end	#	task :field_check => :environment do

	task :import => :import_base do

		file_name = ENV['csv_file']
		if file_name.blank?
			puts
			puts "CSV file name is required."
			puts "Usage: rake app:abstracts:import csv_file=some_file_name.csv"
			puts
			exit
		end
		unless File.exists? file_name
			puts
			puts "#{file_name} not found."
			puts
			exit
		end
		
#		f=CSV.open(file_name, 'rb')
#		column_names = f.readline
#		f.close
#
##		expected_column_names = ["subjectid","project_id","operational_event_id","occurred_at","description","event_notes"]
##		if column_names != expected_column_names
##			puts
##			puts "CSV file does not contain expected column names."
##			puts "Expected: #{expected_column_names.inspect}"
##			puts "Given: #{column_names.inspect}"
##			puts
##			exit
##		end
#
#
## ~236 fields in Abst_DB_New_Var_Names_Aug2010.csv
## ~330 fields in fieldsandtypes.csv
##	 489 columns in ODMS_Abstracts_xxxxxx.csv
##	~342 columns in abstracts table
#
#
#		translation_table = {}
##		(f=CSV.open("Abst_DB_New_Var_Names_Aug2010.csv",'rb',{ 
#		(f=CSV.open("fieldsandtypes.csv",'rb',{ 
#			:headers => true })).each do |line|
#			next if line['current_field_name'].blank?
#			translation_table[line['current_field_name'].upcase] = line['new_field_name']
#		end
#
#		initial_translation_keys_count = translation_table.keys.length
#
###		puts column_names
#		column_names.each do |name|
#			if translation_table[name.upcase]
####				puts "#{name} translates to #{translation_table[name]}"
#				translation_table.delete(name.upcase)
#			else
#				puts "--- CSV Column Name :#{name}: NOT FOUND in translation table"
#			end
#		end
#
#		puts "--- Translation table not used in csv file."
#		puts translation_table.inspect
#
#		puts "Translatable keys: #{initial_translation_keys_count}"
#		puts "CSV Columns: #{column_names.length}"
#
##exit

#long_fields = []


Abstract.destroy_all
		
		error_file = File.open('abstracts_errors.txt','w')	#	overwrite existing
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=CSV.open(file_name, 'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{f.lineno}:#{line}"

#	"subjectid","project_id","operational_event_id","occurred_at","description","event_notes"

#line.to_hash.keys.each do |key|
#	if line[key].to_s.length > 200
#long_fields.push(key) unless long_fields.include?(key)
#		puts "long field #{key} in line #{f.lineno}:#{line[key].to_s.length}"
##		puts line
#	end
#end

			study_subject = StudySubject.where(:childid => line['childid']).first
			unless study_subject
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: childid #{line['childid']} not found."
				error_file.puts line
				error_file.puts
				next
			end


abstract_fields = line.to_hash
abstract_fields.delete('id')
abstract_fields.delete('childid')
abstract_fields.keys.each do |key|
	abstract_fields.delete(key) if abstract_fields[key].blank?
end





#	need to deal with

abstract_fields.delete('fab1a')	#	'diagnosis_all_type')
abstract_fields.delete('fab4a')	#	'diagnosis_aml_type')
abstract_fields.delete('pe12')	#	'vital_status')
abstract_fields.delete('nd4aid')	#	'abstracted_by')
abstract_fields.delete('nd5aid')	#	'reviewed_by')
abstract_fields.delete('nd6aid')	#	'data_entry_by')
abstract_fields.delete('createdby')	#	'created_by')
abstract_fields.delete('nd7')	#	'abstract_version_number')






#
#	Tried to add all of the leftover legacy fields.
#	Discovered that there is a limit to a row in a mysql table.
#	It is 65535.  Assuming that this is bytes.  Now you know.
#Mysql2::Error: Row size too large. The maximum row size for the used table type, not counting BLOBs, is 65535. You have to change some columns to TEXT or BLOBs: ALTER TABLE `abstracts` ADD `cy_diag_fish` varchar(255)
#
#	So.  What to do?
#	Create a LegacyFieldsAbstract model and table?
#	
#	Only added those that had data in them.
#	Used smaller strings and other data types
#




			abstract = study_subject.abstracts.create(abstract_fields) do |a|
				a.entry_1_by_uid = 859908	#	protected
				a.entry_2_by_uid = 859908	#	protected
				a.merged_by_uid  = 859908	#	protected
			end

			if abstract.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: " <<
					"#{abstract.errors.full_messages.to_sentence}"

#
#	This data contains special MS characters like the single char "..."
#	
#
#				error_file.puts line
				error_file.puts abstract.inspect
				error_file.puts
			else
				abstract.reload
				assert_string_equal abstract.study_subject_id, study_subject.id,
					"Study Subject"
abstract_fields.keys.each do |key|
				assert_string_equal abstract.send(key), abstract_fields[key]
end
			end

		end	#	(f=CSV.open(file_name,

#puts long_fields.sort

		error_file.close

puts "Abstract count:#{Abstract.count}"

#		exit;	#	MUST EXPLICITLY exit or rake will try to run arguments as tasks
	end	#	task :import => :import_base do

end	#	namespace :abstracts do
end	#	namespace :app do
