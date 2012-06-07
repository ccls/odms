#namespace :odms_import do
#
#	desc "Import data from operational events csv file"
#	task :operational_events => :odms_import_base do 
##	Can't destroy them as there will be some already
##	Actually, this seems to include the subject creation event
##		so destruction may be just fine.
#		puts "Destroying operational_events"
#		OperationalEvent.destroy_all
#		puts "Importing operational_events"
#
#		error_file = File.open('operational_events_errors.txt','w')	#	overwrite existing
#
#		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
#		(f=FasterCSV.open(EVENTS_CSV, 'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{f.lineno}"
#			puts line
#
##"subjectID","project_id","operational_event_id","occurred_on","description","enrollment_id","event_notes"
#
#			study_subject = StudySubject.where(:subjectid => line['subjectID']).first
#			unless study_subject
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid #{line['subjectID']} not found."
#				error_file.puts line
#				error_file.puts
#				next
#			end
#
#			#
#			#	Only study_subject_id protected so block creation not needed.
#			#
#			operational_event = study_subject.operational_events.create({
#				:project_id  => line['project_id'],
#				:operational_event_type_id => line['operational_event_id'],	#	NOTE misnamed field
#				:occurred_on => Time.parse(line['occurred_on']).to_date,
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
#				assert operational_event.study_subject_id == study_subject.id,
#					"Study Subject mismatch"
#				assert operational_event.project_id == line['project_id'].to_i,
#					"Project mismatch"
#				assert operational_event.operational_event_type_id == line['operational_event_id'].to_nil_or_i, 
#					"operational_event_type mismatch:" <<
#						"#{operational_event.operational_event_type_id}:" <<
#						"#{line["operational_event_id"]}:"
#				assert operational_event.occurred_on == Time.parse(line['occurred_on']).to_date,
#					"occurred_on mismatch:#{operational_event.occurred_on}:" <<
#						"#{line["occurred_on"]}:"
#				assert operational_event.description == line['description'],
#					"description mismatch:#{operational_event.description}:" <<
#						"#{line["description"]}:"
#				assert operational_event.event_notes == line['event_notes'],
#					"event_notes mismatch:#{operational_event.event_notes}:" <<
#						"#{line["event_notes"]}:"
#			end
#		end	#	).each do |line|
#		error_file.close
#	end
#
#end
