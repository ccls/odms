namespace :odms_import do

	desc "Import data from addressings csv file"
	task :addressings => :odms_import_base do 
		puts "Destroying addressings"
		Addressing.destroy_all
		puts "Importing addressings"

		error_file = File.open('addressings_errors.txt','w')	#	overwrite existing

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open( ADDRESSINGS_CSV, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line

#"subjectid","external_address_id","current_address","address_at_diagnosis","valid_from","valid_to","data_source_id","created_at"


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
			#	Addresses must exist before the addressings can be made.
			#
			address = Address.where(:external_address_id => line['external_address_id']).first
			unless address
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: address with external id #{line['external_address_id']} not found."
				error_file.puts line
				error_file.puts
				next
			end

			#
			#	Only study_subject_id is attr_protected so don't need block creation.
			#
			addressing = study_subject.addressings.create({
				:address_id       => address.id,
				:current_address  => line["current_address"],           # yndk integer
				:address_at_diagnosis => line["address_at_diagnosis"],  # yndk integer
				:valid_from       => (( line['valid_from'].blank? ) ?
														nil : Time.parse(line['valid_from']).to_date ),
				:valid_to         => (( line['valid_to'].blank? ) ?
														nil : Time.parse(line['valid_to']).to_date ),
				:data_source_id   => line["data_source_id"],
				:created_at       => (( line['created_at'].blank? ) ?
														nil : Time.parse(line['created_at']) )
			})

			if addressing.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: #{addressing.errors.full_messages.to_sentence}"
				error_file.puts line
				error_file.puts
			else
				addressing.reload
				assert addressing.study_subject_id == study_subject.id,
					'Study Subject mismatch'
				assert addressing.address_id       == address.id,
					'Address mismatch'
				assert addressing.current_address  == line["current_address"].to_nil_or_i,
					'Current Address mismatch'
				assert addressing.address_at_diagnosis == line["address_at_diagnosis"].to_nil_or_i,
					'Address at Diagnosis mismatch'
				assert addressing.data_source_id == line["data_source_id"].to_nil_or_i,
					'Data Source mismatch'
				if line['valid_from'].blank?
					assert addressing.valid_from.nil?, 'Valid From not nil'
				else
					assert !addressing.valid_from.nil?, 'Valid From is nil'
					assert addressing.valid_from == Time.parse(line['valid_from']).to_date,
						"Valid From mismatch"
				end
				if line['valid_to'].blank?
					assert addressing.valid_to.nil?, 'Valid To not nil'
				else
					assert !addressing.valid_to.nil?, 'Valid To is nil'
					assert addressing.valid_to == Time.parse(line['valid_to']).to_date,
						"Valid To mismatch"
				end
			end

		end
		error_file.close
	end

end
