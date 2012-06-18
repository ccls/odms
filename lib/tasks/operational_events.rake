namespace :app do
namespace :operational_events do

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

		expected_column_names = ["subjectid","project_id","operational_event_id","occurred_at","description","event_notes"]
		if column_names != expected_column_names
			puts
			puts "CSV file does not contain expected column names."
			puts "Expected: #{expected_column_names.inspect}"
			puts "Given: #{column_names.inspect}"
			puts
			exit
		end
		
		error_file = File.open('operational_events_errors.txt','w')	#	overwrite existing
		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=CSV.open(file_name, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}:#{line}"

#	"subjectid","project_id","operational_event_id","occurred_at","description","event_notes"

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
			operational_event = study_subject.operational_events.create({
				:project_id  => line['project_id'],
				:operational_event_type_id => line['operational_event_id'],	#	NOTE misnamed field
				:occurred_at => line['occurred_at'].to_nil_or_time,
				:description => line['description'],
				:event_notes => line['event_notes']
			})

			if operational_event.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: " <<
					"#{operational_event.errors.full_messages.to_sentence}"
				error_file.puts line
				error_file.puts
			else
				operational_event.reload
				assert_string_equal operational_event.study_subject_id, study_subject.id,
					"Study Subject"
				assert_string_equal operational_event.project_id, line['project_id'],
					"Project"
				assert_string_equal operational_event.operational_event_type_id, 
					line['operational_event_id'],
					"operational_event_type"
				assert operational_event.occurred_at == line['occurred_at'].to_nil_or_time,
					"occurred_at mismatch:#{operational_event.occurred_at}:" <<
						"#{line["occurred_at"]}:"
				assert_string_equal operational_event.description,
					line['description'],
					"description"
				assert_string_equal operational_event.event_notes, 
					line['event_notes'],
					"event_notes"
			end

		end	#	(f=CSV.open(file_name,
		error_file.close
		exit;	#	MUST EXPLICITLY exit or rake will try to run arguments as tasks
	end

end
end
