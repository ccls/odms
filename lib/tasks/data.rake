namespace :app do
namespace :data do

	desc "Show basic data report and counts"
	task :report => :environment do
		puts
		puts "Report data counts in database"
		puts
		printf "%-25s %5d\n", "StudySubject.count:", StudySubject.count

		StudySubject.select("subject_type_id, COUNT(*) AS count"
				).group(:subject_type_id ).each do |e|
			printf "%-25s %5d\n", "subject_type = #{e.subject_type}:", e.count
		end

		%w{ case_control_type childidwho hispanicity_id father_hispanicity_id
				mother_hispanicity_id sex do_not_contact }.each do |field|
			StudySubject.select("#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "Patient.count:", Patient.count
		%w{ was_under_15_at_dx was_previously_treated was_ca_resident_at_diagnosis 
			organization_id diagnosis_id
		}.each do |field|
			Patient.select( "#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "Enrollment.count:", Enrollment.count
		printf "%-25s %5d\n", "OperationalEvent.count:", OperationalEvent.count
		%w{ operational_event_type_id }.each do |field|
			OperationalEvent.select( "#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "CCLS Enrollments.count:", Enrollment.count(
			:conditions => { :project_id => Project['ccls'].id })
		%w{ consented is_eligible refusal_reason_id document_version_id
			ineligible_reason_id
		}.each do |field|
			Enrollment.select( "#{field}, COUNT(*) AS count"
					).where( :project_id => Project['ccls'].id 
					).group( field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

		printf "%-25s %5d\n", "IcfMasterId.count:", IcfMasterId.count
		printf "%-25s %5d\n", "Used IcfMasterId.count:", 
			IcfMasterId.where( 'study_subject_id IS NOT NULL' ).count
		printf "%-25s %5d\n", "Unused IcfMasterId.count:", 
			IcfMasterId.where( 'study_subject_id IS NULL' ).count

		printf "%-25s %5d\n", "Subjects with icf_master_id:", 
			StudySubject.where( 'icf_master_id IS NOT NULL' ).count
		printf "%-25s %5d\n", "Subjects without icf_master_id:", 
			StudySubject.where( 'icf_master_id IS NULL' ).count

		printf "%-25s %5d\n", "Subjects with childid:", 
			StudySubject.where( 'childid IS NOT NULL' ).count
		printf "%-25s %5d\n", "Subjects without childid:", 
			StudySubject.where( 'childid IS NULL' ).count

		printf "%-25s %5d\n", "Subjects with patid:", 
			StudySubject.where( 'patid IS NOT NULL' ).count
		printf "%-25s %5d\n", "Subjects without patid:", 
			StudySubject.where( 'patid IS NULL' ).count

		printf "%-25s %5d\n", "Subjects with studyid:", 
			StudySubject.where( 'studyid IS NOT NULL' ).count
		printf "%-25s %5d\n", "Subjects without studyid:", 
			StudySubject.where( 'studyid IS NULL' ).count

		printf "%-25s %5d\n", "Subjects with subjectid:", 
			StudySubject.where( 'subjectid IS NOT NULL' ).count
		printf "%-25s %5d\n", "Subjects without subjectid:", 
			StudySubject.where( 'subjectid IS NULL' ).count

		printf "%-25s %5d\n", "Address.count:", Address.count
		printf "%-25s %5d\n", "Addressing.count:", Addressing.count
		printf "%-25s %5d\n", "PhoneNumber.count:", PhoneNumber.count
		printf "%-25s %5d\n", "Sample.count:", Sample.count
		%w{ sample_type_id }.each do |field|
			Sample.select( "#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-25s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end

	end

	desc "Dump some database tables to xml files"
	task :export_to_xml => :environment do
		outdir = if Rails.env == 'production'
			"/my/ruby/xml"
		else
			"."
		end
#
#	redefine the to_xs method. This should be unnecessary
#	if we upgrade ruby from 1.8.7 to 1.9
#
  class String
    # XML escaped version of to_s. When <tt>escape</tt> is set to false
    # the CP1252 fix is still applied but utf-8 characters are not
    # converted to character entities.
    def to_xs(escape=true)
      unpack('U*').map {|n| n.xchr(escape)}.join # ASCII, UTF-8
    rescue
      unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
    end
  end
		puts "Starting...(#{Time.now})"
		%w( address address_type addressing candidate_control enrollment 
				interview operational_event patient phone_number phone_type
				project sample study_subject ).each do |model|
			puts "Exporting #{model.pluralize} ..."
			File.open("#{outdir}/#{model.pluralize}.xml",'w'){|f| 
				f.puts model.camelize.constantize.all.to_xml }
		end
		puts "Done.(#{Time.now})"
	end

end	#	namespace :data do
end	#	namespace :app do

__END__


	Somewhere along the line someone, hpricot I believe, redefines to_xs
	which raises ...
	ArgumentError: wrong number of arguments (1 for 0)
		from /Library/Ruby/Gems/1.8/gems/builder-3.0.0/lib/builder/xmlbase.rb:135:in `to_xs'
		from /Library/Ruby/Gems/1.8/gems/builder-3.0.0/lib/builder/xmlbase.rb:135:in `_escape'
		from /Library/Ruby/Gems/1.8/gems/builder-3.0.0/lib/builder/xmlbase.rb:140:in `_escape_quote'
	
	I can't find the redefinition in the code, but it could be compiled.

	If we simply redefine it again back to the way it is in Builder 3.0.0

	/usr/lib/ruby/user-gems/1.8/gems/builder-3.0.0/lib/builder/xchar.rb

	Putting this here actually causes Builder to complain,
	however, putting it in the rake task seems to work! Yay!

  class String
    # XML escaped version of to_s. When <tt>escape</tt> is set to false
    # the CP1252 fix is still applied but utf-8 characters are not
    # converted to character entities.
    def to_xs(escape=true)
      unpack('U*').map {|n| n.xchr(escape)}.join # ASCII, UTF-8
    rescue
      unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
    end
  end


