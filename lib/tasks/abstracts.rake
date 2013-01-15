namespace :app do
namespace :abstracts do

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
				existing.current_fieldsandtypes = line['current_field_name']
				existing.new_fieldsandtypes = line['new_field_name']
			else
				all_fields.push(OpenStruct.new(
					:current_fieldsandtypes => line['current_field_name'],
					:new_fieldsandtypes => line['new_field_name']) )
			end
		end

#		#	find conversion in Abst_DB_New_Var_Names_Aug2010
#		(f=CSV.open("abstract_notes/Abst_DB_New_Var_Names_Aug2010.csv",'rb',{ 
#				:headers => true })).each do |line|
##next if %w(Createdby Fc1C5b Fc1D5b Fc1E5b CY_Tri4_gBand CY_Tri10_gBand CY_Tri17_gBand CY_Tri21_gBand).include?(line['current_field_name'])
#
#			next if line['current_field_name'].blank?
#			existing = all_fields.detect{|f| f.data.to_s.downcase == line['current_field_name'].to_s.downcase }
#			if existing
##puts "Hell no match - #{line['current_field_name']}:#{existing.current_fieldsandtypes}:#{line['new_field_name']}:#{existing.new_fieldsandtypes}" if existing.new_fieldsandtypes != line['new_field_name']
#				existing.current_Abst_DB = line['current_field_name']
#				existing.new_Abst_DB = line['new_field_name']
#			else
##puts "Hell no exists :#{line['current_field_name']}"
#				all_fields.push(OpenStruct.new(
#					:current_Abst_DB => line['current_field_name'],
#					:new_Abst_DB => line['new_field_name']) )
#			end
#		end

#		#	find field in Abstract
#		(Abstract.column_names - %w(id entry_1_by_uid entry_2_by_uid 
#			merged_by_uid study_subject_id created_at updated_at)).each do |column|
#
#		end

		#	save csv
		CSV.open('field_check.csv','wb') do |csv|
#			csv << %w( DataFile fieldsandtypes Abst_DB )
#			csv << %w( new_in_db1 new_fieldsandtypes current_fieldsandtypes DataFile current_Abst new_Abst_DB new_in_db2 )
			csv << %w( new_in_db1 new_fieldsandtypes current_fieldsandtypes DataFile )
			all_fields.sort{|a,b| (a.data||'') <=> (b.data||'') }.each do |field|
#				csv << [field.data, field.fieldsandtypes, field.Abst_DB_New_Var_Names_Aug2010]
#				csv << [ 
#					(Abstract.column_names.include?(field.new_fieldsandtypes.to_s.downcase)? 'XXX' : nil),
#					field.new_fieldsandtypes, field.current_fieldsandtypes, 
#					field.data, field.current_Abst_DB, 
#					field.new_Abst_DB,
#					(Abstract.column_names.include?(field.new_Abst_DB.to_s.downcase)? 'XXX' : nil)
#				 ]
				csv << [ 
					(Abstract.column_names.include?(
						field.new_fieldsandtypes.to_s.downcase.gsub(/\+/,'_'))? 'XXX' : nil),
					field.new_fieldsandtypes, field.current_fieldsandtypes, field.data ]
			end	#	all_fields.sort{|a,b| (a.data||'') <=> (b.data||'') }.each do |field|
			(Abstract.column_names - 
				all_fields.collect(&:new_fieldsandtypes).compact.collect(&:downcase
					).collect{|f|f.gsub(/\+/,'_')} - 
				%w( id study_subject_id entry_1_by_uid entry_2_by_uid 
					merged_by_uid updated_at )).sort.each do |field|
				csv << [ 'XXX', field ]
			end

		end	#	CSV.open('field_check.csv','wb') do |csv|

	end	#	task :field_check => :environment do

	task :import => :import_base do
		this_task_name = $*.shift	

		file_name = $*.shift
		if file_name.blank?
			puts
			puts "CSV file name is required."
			puts "Usage: rake #{this_task_name} some_file_name.csv"
			puts
			exit
		end
		unless File.exists? file_name
			puts
			puts "#{file_name} not found."
			puts
			exit
		end
		
		f=CSV.open(file_name, 'rb')
		column_names = f.readline
		f.close

#		expected_column_names = ["subjectid","project_id","operational_event_id","occurred_at","description","event_notes"]
#		if column_names != expected_column_names
#			puts
#			puts "CSV file does not contain expected column names."
#			puts "Expected: #{expected_column_names.inspect}"
#			puts "Given: #{column_names.inspect}"
#			puts
#			exit
#		end


# ~236 fields in Abst_DB_New_Var_Names_Aug2010.csv
# ~330 fields in fieldsandtypes.csv
#	 489 columns in ODMS_Abstracts_xxxxxx.csv
#	~342 columns in abstracts table


		translation_table = {}
#		(f=CSV.open("Abst_DB_New_Var_Names_Aug2010.csv",'rb',{ 
		(f=CSV.open("fieldsandtypes.csv",'rb',{ 
			:headers => true })).each do |line|
			next if line['current_field_name'].blank?
			translation_table[line['current_field_name'].upcase] = line['new_field_name']
		end

		initial_translation_keys_count = translation_table.keys.length

##		puts column_names
		column_names.each do |name|
			if translation_table[name.upcase]
###				puts "#{name} translates to #{translation_table[name]}"
				translation_table.delete(name.upcase)
			else
				puts "--- CSV Column Name :#{name}: NOT FOUND in translation table"
			end
		end

		puts "--- Translation table not used in csv file."
		puts translation_table.inspect

		puts "Translatable keys: #{initial_translation_keys_count}"
		puts "CSV Columns: #{column_names.length}"

#exit


		
		error_file = File.open('abstracts_errors.txt','w')	#	overwrite existing
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=CSV.open(file_name, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}:#{line}"

#	"subjectid","project_id","operational_event_id","occurred_at","description","event_notes"

			study_subject = StudySubject.where(:childid => line['ChildID']).first
			unless study_subject
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: childid #{line['ChildID']} not found."
				error_file.puts line
				error_file.puts
				next
			end

			#
			#	Only study_subject_id protected so block creation not needed.
			#
#			abstract = study_subject.abstracts.new({
#				:project_id  => line['project_id'],
#				:operational_event_type_id => line['operational_event_id'],	#	NOTE misnamed field
#				:occurred_at => line['occurred_at'].to_nil_or_time,
#				:description => line['description'],
#				:event_notes => line['event_notes']
#			})

#			if operational_event.new_record?
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: " <<
#					"#{operational_event.errors.full_messages.to_sentence}"
#				error_file.puts line
#				error_file.puts
#			else
#				operational_event.reload
#				assert_string_equal operational_event.study_subject_id, study_subject.id,
#					"Study Subject"
#				assert_string_equal operational_event.project_id, line['project_id'],
#					"Project"
#				assert_string_equal operational_event.operational_event_type_id, 
#					line['operational_event_id'],
#					"operational_event_type"
#				assert operational_event.occurred_at == line['occurred_at'].to_nil_or_time,
#					"occurred_at mismatch:#{operational_event.occurred_at}:" <<
#						"#{line["occurred_at"]}:"
#				assert_string_equal operational_event.description,
#					line['description'],
#					"description"
#				assert_string_equal operational_event.event_notes, 
#					line['event_notes'],
#					"event_notes"
#			end

		end	#	(f=CSV.open(file_name,
		error_file.close
		exit;	#	MUST EXPLICITLY exit or rake will try to run arguments as tasks
	end

end
end
