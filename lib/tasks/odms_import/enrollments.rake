#namespace :odms_import do
#
#	desc "Import data from enrollments csv file"
#	task :enrollments => :odms_import_base do
#		puts "Importing enrollments"
#
#		error_file = File.open('enrollments_errors.txt','w')	#	overwrite existing
#
#		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
#		(f=FasterCSV.open(ENROLLMENTS_CSV, 'rb',{ :headers => true })).each do |line|
#
##	skip until ...
##			next if f.lineno <= 10619
#
#			puts "Processing line #{f.lineno}"
#			puts line
#
##	Don't need all of this and don't know exactly what to do with the DeclineReasons
##	also is_eligible changed and ineligible_reason_id added
##"subjectType-donotimprot","ChildId","project_id","subjectID","consented","consented_on","tPatientInfo_DeclineReason","tlDeclineReasons_DeclineReason","refusal_reason_id","document_version_id","is_eligible","ineligible_reason_id"
#
#			if line['subjectID'].blank?
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid blank."
#				error_file.puts line
#				error_file.puts
#				next
#			end
#			study_subject = StudySubject.where(:subjectid => line['subjectID']).first
#			unless study_subject
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: subjectid #{line['subjectID']} not found."
#				error_file.puts line
#				error_file.puts
#				next
#			end
#
#			enrollment = study_subject.enrollments.find_or_create_by_project_id(
#				line['project_id'])
#
#			#	TEMPORARY "FIXES" to get most enrollments imported
#
#			consented           = line['consented']
##			consented_on        = (( line['consented_on'].blank? ) ?
##					nil : Time.parse(line['consented_on']).to_date )
#			consented_on        = line['consented_on'].to_nil_or_date
#			refusal_reason_id   = line['refusal_reason_id']
#			document_version_id = line['document_version_id']
#
#			#
#			#	Only study_subject_id is protected, so no need for block creation.
#			#
#			saved = enrollment.update_attributes(
#				:consented           => consented,
#				:consented_on        => consented_on,
#				:refusal_reason_id   => refusal_reason_id,
##	Including this raises this ... times.
##Line #:495: Other refusal reason not allowed unless consented is No
##				:other_refusal_reason => line['tlDeclineReasons_DeclineReason'],
#				:document_version_id => document_version_id,
#				:is_eligible         => line['is_eligible'],
#				:ineligible_reason_id => line['ineligible_reason_id']
#			)
#			unless saved
#				error_file.puts 
#				error_file.puts "Line #:#{f.lineno}: #{enrollment.errors.full_messages.to_sentence}"
#				error_file.puts line
#				error_file.puts enrollment.inspect
#				error_file.puts
#			else
#				enrollment.reload
#				assert enrollment.consented == line['consented'].to_nil_or_i,
#					"consented mismatch:#{enrollment.consented}:#{line["consented"]}:"
#				assert enrollment.consented_on        == consented_on,
#					"consented_on mismatch:#{enrollment.consented_on}:#{line["consented_on"]}:"
#				assert enrollment.refusal_reason_id   == refusal_reason_id.to_nil_or_i,
#					"refusal_reason_id mismatch:#{enrollment.refusal_reason_id}:" <<
#						"#{line["refusal_reason_id"]}:"
#				assert enrollment.document_version_id == document_version_id.to_nil_or_i,
#					"document_version_id mismatch:#{enrollment.document_version_id}:" <<
#						"#{line["document_version_id"]}:"
#				assert enrollment.is_eligible == line['is_eligible'].to_nil_or_i,
#					"is_eligible mismatch:#{enrollment.is_eligible}:#{line['is_eligible']}:"
#				assert enrollment.ineligible_reason_id   == line['ineligible_reason_id'].to_nil_or_i,
#					"ineligible_reason_id mismatch:#{enrollment.ineligible_reason_id}:" <<
#						"#{line["ineligible_reason_id"]}:"
#			end
#
#		end
#		error_file.close
#	end
#
#end
