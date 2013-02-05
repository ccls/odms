namespace :app do
namespace :abstracts do

	task :compare_negative_childids => :environment do
		csv_contents = []
		(f=CSV.open(ENV['csv_file'], 'rb',{ :headers => true })).each do |line|
			csv_contents.push line.to_hash
		end

		csv_contents.each do |row|
			next unless row['childid'].match(/^-/)
			puts row['childid']
			positive = csv_contents.detect{|c| c['childid'] == row['childid'].gsub(/^-/,'') }
			if positive
				puts positive['childid'] 
				puts positive.differences(row)
			else
				puts "NO POSITIVE FOUND"
			end
		end

	end


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

		#	will be the new names
		new_yndk_attributes = Abstract.validators.detect{|v| 
			v.options[:in] == YNDK.valid_values }.attributes.collect(&:to_s)	

		new_to_old = Abstract.aliased_attributes.invert.with_indifferent_access
		yndk_attributes = new_yndk_attributes.collect{|n| new_to_old[n] }

		Abstract.destroy_all

		error_counting = {}

		f = CSV.open(file_name,'rb')
		total_lines = f.readlines.size	#	includes header, but so does f.lineno
		f.close
		puts "#{total_lines} to process"
		
		negative_childids_file = File.open('abstracts_negative_childids.txt','w')
		error_file = File.open('abstracts_errors.txt','w')	#	overwrite existing
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=CSV.open(file_name, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}/#{total_lines}"

			#	"subjectid","project_id","operational_event_id","occurred_at","description","event_notes"

			#line.to_hash.keys.each do |key|
			#	if line[key].to_s.length > 200
			#long_fields.push(key) unless long_fields.include?(key)
			#		puts "long field #{key} in line #{f.lineno}:#{line[key].to_s.length}"
			##		puts line
			#	end
			#end

			if line['childid'].include?('-') or line['childid'] == '0'
				negative_childids_file.puts line['childid']
				next
			end

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

			#
			#	bugger.  the csv and therefore the line and therefore abstract_fields has
			#		the old cryptic fields while the validations have the new names so
			#		there will never be a match.  the alias_attribute method doesn't link
			#		the two in any fashion that is readable after the fact.
			#
			abstract_fields.keys.each do |key|
				#	convert YNDK fields 9 to 999
				abstract_fields[key] = 999 if abstract_fields[key].to_s == '9' &&
					yndk_attributes.include?(key.to_s)
				#	convert YNDK fields 0 to 2 (used to be true(1) or false(0), now yes(1) or no(2))
				abstract_fields[key] = 2 if abstract_fields[key].to_s == '0' &&
					yndk_attributes.include?(key.to_s)
			end

			#	fc1b / flow_cyto_report_on 
			#	hs2 / histo_report_on
			#	pe12a / dod
			#	bm1b_7 / response_report_on_day_7
			#	bm1b_28 / response_report_on_day_28
			#	bm1b_14 / response_report_on_day_14
			#	fc1b_14 / response_flow_cyto_day_14_on
			#	is either '' or '00:00.0'
			#	kinda expecting a date so DESTROY ALL HUMANS
			%w( fc1b hs2 pe12a bm1b_7 bm1b_28 bm1b_14 fc1b_14 ).each do |f|
				abstract_fields.delete(f)
			end

			#	nd4b / abstracted_on
			#	cbc2 / cbc_report_on
			#	pe2 / h_and_p_reports_on
			#	cbf2 / csf_report_on
			#	bma2 / marrow_biopsy_on
			#	bmb2 / marrow_aspirate_taken_on
			#	cy2 / cytogen_report_on
			#	id6 / diagnosed_on
			#	id8 / treatment_began_on
			#	cim2 / chest_imaging_report_on
			#	pl2 / ploidy_report_on
			#	fc2c / tdt_report_on
			#	is either '' or a date with ' 12:00 AM	'
			#	as this is a date field it is not saving
			%w( nd4b cbc2 pe2 cbf2 bma2 bmb2 cy2 id6 id8 cim2 pl2 fc2c ).each do |f|
				unless abstract_fields[f].blank?
					abstract_fields[f] = Time.parse(abstract_fields[f]).to_date 
				end
			end





#	need to deal with

#	expecting a YNDK code, but all are 14.  What to do?
abstract_fields.delete('_14or28flag')	#	'response_day14or28_flag')			#	TODO

#	alias_attribute :bm1d_7, :response_blasts_day_7
#	response_blasts_day_7 is an int in the database
#	mostly floats in datafile, but also things like ...
# <0.5	<1	<2	<5	<5.0	>50	~10	~60 6-May	
abstract_fields.delete('bm1d_7')
#	28 is same as 7
#	2 myeloid	2-Jan	2.5	2.50%	2.6	2.8	24	25	
#	8-May	<3	<5	no evidence of disease
#	alias_attribute :bm1d_28, :response_blasts_day_28
abstract_fields.delete('bm1d_28')
#	14 is same as 7 and 28
#		alias_attribute :bm1d_14, :response_blasts_day_14
abstract_fields.delete('bm1d_14')
# integers, floats, dates, fractions, equations, string. all of the above





abstract_fields.delete('fab1a')	#	'diagnosis_all_type')			#	TODO
abstract_fields.delete('fab4a')	#	'diagnosis_aml_type')			#	TODO
#abstract_fields.delete('pe12')	#	'vital_status')						#	TODO
abstract_fields.delete('nd4aid')	#	'abstracted_by')				#	TODO
abstract_fields.delete('nd5aid')	#	'reviewed_by')					#	TODO
abstract_fields.delete('nd6aid')	#	'data_entry_by')				#	TODO
abstract_fields.delete('createdby')	#	'created_by')					#	TODO
abstract_fields.delete('nd7')	#	'abstract_version_number')	#	TODO






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

abstract.errors.each do |e|
	error_counting[e] ||= Hash.new(0)
	error_counting[e][abstract.send(e)] += 1
#	puts "#{e}:#{abstract.send(e)}"
end

#
#	This data contains special MS characters like the single char "..."
#	Raises error "\xE2" from ASCII-8BIT to UTF-8
#
				error_file.puts line
				error_file.puts abstract.inspect
				error_file.puts
			else
#puts abstract_fields.inspect
				abstract.reload
#				assert_string_equal abstract.study_subject_id, study_subject.id,
#					"Study Subject"
abstract_fields.keys.each do |key|
##				assert_string_equal abstract.send(key), abstract_fields[key], key
				assert_equal abstract.send(key), abstract_fields[key], key
end
			end

		end	#	(f=CSV.open(file_name,

#puts long_fields.sort

		error_file.close

puts "Abstract count:#{Abstract.count}"

puts "Abstract Error Counts"
puts error_counting.inspect
error_counts_file = File.open('abstracts_error_counts.txt','w')
error_counting.keys.each do |field|
	error_counts_file.puts field
	error_counting[field].each do |k,v|
		error_counts_file.puts "  #{k} : #{v}"
	end
end


negative_childids_file.close


#		exit;	#	MUST EXPLICITLY exit or rake will try to run arguments as tasks
	end	#	task :import => :import_base do

end	#	namespace :abstracts do
end	#	namespace :app do
