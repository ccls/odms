require 'tasks/odms_import/base'

namespace :odms_import do

	desc "Import data from samples csv file"
	task :samples => :odms_import_base do 
		puts "Destroying samples"
		Sample.destroy_all
		puts "Importing samples"

		error_file = File.open('samples_errors.txt','w')	#	overwrite existing

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open(SAMPLES_CSV, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line

#"id","childid","subjectID","parent_sample_id","ODMS_sample_type_id","project_id","location_id","storage_temp","aliquot_or_sample_on_receipt","received_by_ccls_at","originally_received_at","external_id","external_id_source"

			if line['subjectID'].blank?	#	NOTE misnamed field
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: subjectid blank."
				error_file.puts line
				error_file.puts
				next
			end
			study_subject = StudySubject.where(:subjectid => line['subjectID']).first
			unless study_subject
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: subjectid #{line['subjectID']} not found."
				error_file.puts line
				error_file.puts
				next
			end

			sample = study_subject.samples.create do |s|

				s.id = line['id']	#	THIS IS ACTUALLY IMPORTANT!

				s.project_id = if line['project_id'].blank? or line['project_id'].to_s == '0'
					Project['ccls'].id
				else
					line['project_id']
				end

				s.parent_sample_id = line['parent_sample_id']
				s.sample_type_id = line['ODMS_sample_type_id']
				s.location_id = line['location_id']

				s.sample_temperature_id = if line['storage_temp'].blank?
					nil
				elsif line['storage_temp'] == 'Refrigerator'
					SampleTemperature['refrigerated'].id
				elsif line['storage_temp'] == 'Room Temperature'
					SampleTemperature['roomtemp'].id
				else
					0	#	should crash
				end

				s.aliquot_or_sample_on_receipt = line['aliquot_or_sample_on_receipt']

				s.received_by_ccls_at = (( line['received_by_ccls_at'].blank? ) ?
														nil : Time.parse(line['received_by_ccls_at']))

#				:UNKNOWN         => (( line['originally_received_at'].blank? ) ?
#														nil : Time.parse(line['originally_received_at']) ),

				s.external_id        = line["external_id"]
				s.external_id_source = line["external_id_source"]
			end

			if sample.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: #{sample.errors.full_messages.to_sentence}"
				error_file.puts line
				error_file.puts
			else
				sample.reload
				assert_string_equal sample.id, line["id"], 
					'id'
				assert sample.study_subject_id == study_subject.id,
					'Study Subject mismatch'
				assert_string_equal sample.parent_sample_id, line["parent_sample_id"], 
					'parent_sample_id'
				assert_string_equal sample.sample_type_id, line["ODMS_sample_type_id"], 
					'sample_type_id'
				assert_string_equal sample.external_id, line["external_id"], 
					'external_id'
				assert_string_equal sample.external_id_source, line["external_id_source"], 
					'external_id_source'


#	TODO compare project_id
#	TODO compare aliquot_or_sample_on_receipt
#	TODO compare storage_temp
#				if line['valid_to'].blank?
#					assert addressing.valid_to.nil?, 'Valid To not nil'
#				else
#					assert !addressing.valid_to.nil?, 'Valid To is nil'
#					assert addressing.valid_to == Time.parse(line['valid_to']).to_date,
#						"Valid To mismatch"
#				end
#	NOTE, this won't work due to defaults
#				assert sample.aliquot_or_sample_on_receipt == line["aliquot_or_sample_on_receipt"],
#					'aliquot_or_sample_on_receipt mismatch'

#				assert sample.location_id == line["location_id"],
#					"location_id mismatch"
#				assert sample.location_id == line["location_id"],

			end

		end	#	).each do |line|
		error_file.close
	end

end
