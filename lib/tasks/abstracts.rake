namespace :app do
namespace :abstracts do

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
