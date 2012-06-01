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

#"id","childid","subjectID","parent_sample_id","sample_type_id","project_id","location_id","storage_temp","aliquot_or_sample_on_receipt","received_by_ccls_at","originally_received_at","external_id","external_id_source"

#			if line['subjectID'].blank?	#	NOTE misnamed field
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid blank."
#				error_file.puts line
#				error_file.puts
#				next
#			end
			study_subject = StudySubject.where(:subjectid => line['subjectID']).first
#			unless study_subject
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid #{line['subjectID']} not found."
#				error_file.puts line
#				error_file.puts
#				next
#			end

			project_id = if line['project_id'].blank? or line['project_id'].to_s == '0'
				Project['ccls'].id
			else
				line['project_id']
			end
			sample_temperature_id = if line['storage_temp'].blank?
				nil
			elsif line['storage_temp'] == 'Refrigerator'
				SampleTemperature['refrigerated'].id
			elsif line['storage_temp'] == 'Room Temperature'
				SampleTemperature['roomtemp'].id
			else
				0	#	should crash
			end

#			sample = study_subject.samples.create do |s|
			sample = Sample.create do |s|


				s.study_subject_id = study_subject.try(:id)


				s.id = line['id']	#	THIS IS ACTUALLY REALLY REALLY IMPORTANT!



				s.project_id = project_id

				s.parent_sample_id = line['parent_sample_id']
				s.sample_type_id = line['sample_type_id']
				unless line['location_id'].blank?
					s.location_id = line['location_id']
				end

				s.sample_temperature_id = sample_temperature_id

				unless line['aliquot_or_sample_on_receipt'].blank?
					s.aliquot_or_sample_on_receipt = line['aliquot_or_sample_on_receipt']
				end

				s.received_by_ccls_at = line['received_by_ccls_at'].to_nil_or_time


#	created_at ???
				s.created_at         = line['originally_received_at'].to_nil_or_time


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
				assert sample.study_subject_id == study_subject.try(:id),
					'Study Subject mismatch'
				assert_string_equal sample.project_id, project_id,
					'project_id'
				assert_string_equal sample.parent_sample_id, line["parent_sample_id"], 
					'parent_sample_id'
				assert_string_equal sample.sample_type_id, line["sample_type_id"], 
					'sample_type_id'
				assert_string_equal sample.external_id, line["external_id"], 
					'external_id'
				assert_string_equal sample.external_id_source, line["external_id_source"], 
					'external_id_source'
				assert_string_equal sample.sample_temperature_id, sample_temperature_id,
					'sample_temperature_id'

				unless line['created_at'].blank?
					assert !sample.created_at.nil?, 'created_at is nil'
					assert sample.created_at == Time.parse(line['originally_received_at']),
						"created_at mismatch :" <<
							"#{sample.created_at}:" <<
							"#{Time.parse(line['originally_received_at'])}:"
				end

				if line['received_by_ccls_at'].blank?
					assert sample.received_by_ccls_at.nil?, 'received_by_ccls_at not nil'
				else
					assert !sample.received_by_ccls_at.nil?, 'received_by_ccls_at is nil'
					assert sample.received_by_ccls_at == Time.parse(line['received_by_ccls_at']),
						"received_by_ccls_at mismatch :" <<
							"#{sample.received_by_ccls_at}:" <<
							"#{Time.parse(line['received_by_ccls_at'])}:"
				end

#	defaults
#       self.aliquot_or_sample_on_receipt ||= 'Sample'
#       self.order_no ||= 1
#       self.location_id ||= Organization['CCLS'].id

				if line['aliquot_or_sample_on_receipt'].blank?
					assert_string_equal sample.aliquot_or_sample_on_receipt, 'Sample',
						'aliquot_or_sample_on_receipt(blank)'
				else
					assert_string_equal sample.aliquot_or_sample_on_receipt, 
						line['aliquot_or_sample_on_receipt'],
							'aliquot_or_sample_on_receipt(!blank)'
				end

				assert_string_equal sample.order_no, '1',

				if line['location_id'].blank?
					assert_string_equal sample.location_id, Organization['CCLS'].id,
						'location_id(blank)'
				else
					assert_string_equal sample.location_id, 
						line['location_id'],
							'location_id(!blank)'
				end

			end

		end	#	).each do |line|
		error_file.close
	end

end
