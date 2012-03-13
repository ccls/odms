namespace :app do
namespace :data do

	desc "Show basic data report and counts"
	task :report => :environment do
		puts
		puts "Report data counts in database"
		puts
		printf "%-25s %5d\n", "StudySubject.count:", StudySubject.count

		StudySubject.all(:select => "subject_type_id, COUNT(*) AS count",
				:group => :subject_type_id ).each do |e|
			printf "%-25s %5d\n", "subject_type = #{e.subject_type}:", e.count
		end

		%w{ case_control_type childidwho hispanicity_id father_hispanicity_id
				mother_hispanicity_id sex do_not_contact }.each do |field|
			StudySubject.all(:select => "#{field}, COUNT(*) AS count",
					:group => field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "Patient.count:", Patient.count
		%w{ was_under_15_at_dx was_previously_treated was_ca_resident_at_diagnosis 
			organization_id diagnosis_id
		}.each do |field|
			Patient.all(:select => "#{field}, COUNT(*) AS count",
					:group => field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "Enrollment.count:", Enrollment.count
		printf "%-25s %5d\n", "OperationalEvent.count:", OperationalEvent.count
		%w{ operational_event_type_id }.each do |field|
			OperationalEvent.all(:select => "#{field}, COUNT(*) AS count",
					:group => field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "CCLS Enrollments.count:", Enrollment.count(
			:conditions => { :project_id => Project['ccls'].id })
		%w{ consented is_eligible refusal_reason_id document_version_id
			ineligible_reason_id
		}.each do |field|
			Enrollment.all(:select => "#{field}, COUNT(*) AS count",
					:conditions => { :project_id => Project['ccls'].id },
					:group      => field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "IcfMasterId.count:", IcfMasterId.count
		printf "%-25s %5d\n", "Used IcfMasterId.count:", IcfMasterId.count(
			:conditions => [ 'study_subject_id IS NOT NULL' ])
		printf "%-25s %5d\n", "Unused IcfMasterId.count:", IcfMasterId.count(
			:conditions => [ 'study_subject_id IS NULL' ])

		printf "%-25s %5d\n", "Subjects with icf_master_id:", StudySubject.count(
			:conditions => [ 'icf_master_id IS NOT NULL' ])
		printf "%-25s %5d\n", "Subjects without icf_master_id:", StudySubject.count(
			:conditions => [ 'icf_master_id IS NULL' ])

		printf "%-25s %5d\n", "Subjects with childid:", StudySubject.count(
			:conditions => [ 'childid IS NOT NULL' ])
		printf "%-25s %5d\n", "Subjects without childid:", StudySubject.count(
			:conditions => [ 'childid IS NULL' ])

		printf "%-25s %5d\n", "Subjects with patid:", StudySubject.count(
			:conditions => [ 'patid IS NOT NULL' ])
		printf "%-25s %5d\n", "Subjects without patid:", StudySubject.count(
			:conditions => [ 'patid IS NULL' ])

		printf "%-25s %5d\n", "Subjects with studyid:", StudySubject.count(
			:conditions => [ 'studyid IS NOT NULL' ])
		printf "%-25s %5d\n", "Subjects without studyid:", StudySubject.count(
			:conditions => [ 'studyid IS NULL' ])

		printf "%-25s %5d\n", "Subjects with subjectid:", StudySubject.count(
			:conditions => [ 'subjectid IS NOT NULL' ])
		printf "%-25s %5d\n", "Subjects without subjectid:", StudySubject.count(
			:conditions => [ 'subjectid IS NULL' ])
	end

	desc "Dump some database tables to xml files"
	task :export_to_xml => :environment do
		outdir = if Rails.env == 'production'
			"/my/ruby/xml"
		else
			"."
		end
		%w( project enrollment study_subject 
				patient phone_number address addressing ).each do |model|
			puts "Exporting #{model.pluralize} ..."
			File.open("#{outdir}/#{model.pluralize}.xml",'w'){|f| 
				f.puts model.camelize.constantize.all.to_xml }
		end
	end

end	#	namespace :data do
end	#	namespace :app do
