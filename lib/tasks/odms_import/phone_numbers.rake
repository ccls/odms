namespace :odms_import do

	desc "Import data from phone numbers csv file"
	task :phone_numbers => :odms_import_base do 
		puts "Destroying phone_numbers"
		PhoneNumber.destroy_all
		puts "Importing phone_numbers"

		error_file = File.open('phone_numbers_errors.txt','w')	#	overwrite existing

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open(PHONENUMBERS_CSV, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line

#"subjectid","data_source_id","external_address_id","created_at","phone_number","is_primary","current_phone","phone_type_id"

			if line['subjectid'].blank?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: subjectid blank."
				error_file.puts line
				error_file.puts
				next
			end
			study_subject = StudySubject.where(:subjectid => line['subjectid']).first
			unless study_subject
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: subjectid #{line['subjectid']} not found."
				error_file.puts line
				error_file.puts
				next
			end

			#
			#	Only study_subject_id protected so block creation not needed.
			#
			phone_number = study_subject.phone_numbers.create({
				:phone_type_id    => line["phone_type_id"],
				:data_source_id   => line['data_source_id'],
				:phone_number     => line["phone_number"],
				:is_primary       => line["is_primary"],         #	boolean
				:current_phone    => line["current_phone"],      #	yndk integer
				:created_at       => line['created_at'].to_nil_or_time
			})

			if phone_number.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: #{phone_number.errors.full_messages.to_sentence}"
				error_file.puts line
				error_file.puts
			else
				phone_number.reload
				assert phone_number.study_subject_id == study_subject.id, 
					"Study Subject mismatch"
				assert phone_number.phone_type_id == line["phone_type_id"].to_nil_or_i,
					"phone_type_id mismatch:#{phone_number.phone_type_id}:" <<
						"#{line["phone_type_id"]}:"
				assert phone_number.data_source_id == line["data_source_id"].to_nil_or_i,
					"data_source_id mismatch:#{phone_number.data_source_id}:" <<
						"#{line["data_source_id"]}:"
				#	import will change format of phone number (adds () and - )
				assert phone_number.phone_number.only_numeric == line["phone_number"].only_numeric,
					"phone_number mismatch:#{phone_number.phone_number}:" <<
						"#{line["phone_number"]}:"
				assert phone_number.current_phone == line["current_phone"].to_nil_or_i,
					"current_phone mismatch:#{phone_number.current_phone}:" <<
						"#{line["current_phone"]}:"
				assert phone_number.is_primary       == line["is_primary"].to_nil_or_boolean, 
					"is_primary mismatch:#{phone_number.is_primary}:" <<
						"#{line["is_primary"]}:"
			end

		end	#	).each do |line|
		error_file.close
	end

end
