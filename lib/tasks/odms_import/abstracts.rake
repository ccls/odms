namespace :odms_import do

	desc "Import data from abstracts csv file"
	task :abstracts => :odms_import_base do 
#		puts "Destroying phone_numbers"
#		PhoneNumber.destroy_all
#		puts "Importing phone_numbers"

		error_file = File.open('abstracts_errors.txt','w')	#	overwrite existing

		translation_table = {}
		(f=FasterCSV.open("Abst_DB_New_Var_Names_Aug2010.csv",'rb',{ 
			:headers => true })).each do |line|
			next if line['current_field_name'].blank?
			translation_table[line['current_field_name'].upcase] = line['new_field_name']
		end

		initial_translation_keys_count = translation_table.keys.length

		f=FasterCSV.open(ABSTRACTS_CSV, 'rb')	#,{ :headers => true })
		column_names = f.readline
		f.close

		puts column_names
		column_names.each do |name|
			if translation_table[name.upcase]
#				puts "#{name} translates to #{translation_table[name]}"
				translation_table.delete(name.upcase)
			else
				puts "---HELP :#{name}: NOT FOUND"
			end
		end

		puts translation_table.inspect

		puts "Translatable keys: #{initial_translation_keys_count}"
		puts "CSV Columns: #{column_names.length}"

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
#		(f=FasterCSV.open(ABSTRACTS_CSV, 'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{f.lineno}"
#			puts line
#
#"subjectid","data_source_id","external_address_id","created_at","phone_number","is_primary","current_phone","phone_type_id"

#			if line['subjectid'].blank?
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid blank."
#				error_file.puts line
#				error_file.puts
#				next
#			end
#			study_subject = StudySubject.where(:subjectid => line['subjectid']).first
#			unless study_subject
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid #{line['subjectid']} not found."
#				error_file.puts line
#				error_file.puts
#				next
#			end
#
#			#
#			#	Only study_subject_id protected so block creation not needed.
#			#
#			phone_number = study_subject.phone_numbers.create({
#				:phone_type_id    => line["phone_type_id"],
#				:data_source_id   => line['data_source_id'],
#				:phone_number     => line["phone_number"],
#				:is_primary       => line["is_primary"],         #	boolean
#				:current_phone    => line["current_phone"],      #	yndk integer
#				:created_at       => line['created_at'].to_nil_or_time
#			})
#
#			if phone_number.new_record?
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: #{phone_number.errors.full_messages.to_sentence}"
#				error_file.puts line
#				error_file.puts
#			else
#				phone_number.reload
#				assert phone_number.study_subject_id == study_subject.id, 
#					"Study Subject mismatch"
#				assert phone_number.phone_type_id == line["phone_type_id"].to_nil_or_i,
#					"phone_type_id mismatch:#{phone_number.phone_type_id}:" <<
#						"#{line["phone_type_id"]}:"
#				assert phone_number.data_source_id == line["data_source_id"].to_nil_or_i,
#					"data_source_id mismatch:#{phone_number.data_source_id}:" <<
#						"#{line["data_source_id"]}:"
#				#	import will change format of phone number (adds () and - )
#				assert phone_number.phone_number.only_numeric == line["phone_number"].only_numeric,
#					"phone_number mismatch:#{phone_number.phone_number}:" <<
#						"#{line["phone_number"]}:"
#				assert phone_number.current_phone == line["current_phone"].to_nil_or_i,
#					"current_phone mismatch:#{phone_number.current_phone}:" <<
#						"#{line["current_phone"]}:"
#				assert phone_number.is_primary       == line["is_primary"].to_nil_or_boolean, 
#					"is_primary mismatch:#{phone_number.is_primary}:" <<
#						"#{line["is_primary"]}:"
#			end
#
#		end	#	).each do |line|
		error_file.close
	end

end
