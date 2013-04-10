namespace :app do
namespace :data do

	task :checkup => :environment do


		StudySubject.select('subjectid').collect(&:subjectid).each do |subjectid| 

#			StudySubject.with_familyid(subjectid).update_all(:mother_icf_master_id => StudySubject.mothers.with_familyid(subjectid).first.try(:icf_master_id))}

			puts "Checking subjectid #{subjectid}"

			if %w( 3t82t8 ).include? subjectid
				puts "skipping known badness"
				next
			end

			puts "There should be only one subject with this subjectid.  (Would've failed already)"
			subjects = StudySubject.with_subjectid(subjectid)
			subject = subjects.first
			raise "More than one subject with subjectid?" if subjects.length != 1

#			puts "Unless is mother, probably more than one family member"
#			puts "Is this subject a mother? :#{subject.is_mother?}:"
#			family  = StudySubject.with_familyid(subjectid)
#			puts "Family members: #{family.length}:"
#
#			mothers = StudySubject.mothers.with_familyid(subjectid)
#			puts "Mothers count: #{mothers.length}:"
#			
##			puts "There should be no more than one mother with a familyid with this subjectid"
#
#			puts "If is case, probably more than one matching subject"
#			puts "Is this subject a case? :#{subject.is_case?}:"
#			matching = StudySubject.with_matchingid(subjectid)
#			puts "Matching members: #{matching.length}:"


			if subject.is_case?

				puts "There should be ONLY THIS CASE subject with this as a matchingid"
				matching = StudySubject.cases.with_matchingid(subjectid)
				raise "There should be ONLY THIS CASE subject with this as a matchingid" unless matching.length == 1

			elsif subject.is_control?

				puts "There should be no subject with this as a matchingid"
				matching = StudySubject.with_matchingid(subjectid)
				raise "There should be no subject with this as a matchingid" unless matching.empty?

			else	#	is mother, father or twin

				puts "There should be no subject with this as a matchingid"
				matching = StudySubject.with_matchingid(subjectid)
				raise "There should be no subject with this as a matchingid" unless matching.empty?

				puts "There should be no subject with this as a familyid"
				family = StudySubject.with_familyid(subjectid)
				raise "There should be no subject with this as a familyid" unless family.empty?



			end

			puts; puts

		end

	end


	task :diseminate_icf_master_ids => :environment do

		StudySubject.cases.each do |subject|
			puts "Processing case subject matchingid #{subject.matchingid}"
			#	its a case so subjectid, familyid and matchingid are the same
			StudySubject.with_matchingid(subject.subjectid).update_all(
				:case_icf_master_id => subject.icf_master_id)
		end

		StudySubject.mothers.each do |subject|
			puts "Processing mother subject familyid #{subject.familyid}"
			#	its a mother, so subjectid, familyid and matchingid are all DIFFERENT
			#	subjectid is itself
			#	familyid is the subjectid of the child (case or control)
			#	matchingid is the subjectid of the case child
			StudySubject.with_familyid(subject.familyid).update_all(
				:mother_icf_master_id => subject.icf_master_id)
		end

#irb(main):017:0> StudySubject.select('subjectid').collect(&:subjectid).each{|subjectid| StudySubject.with_familyid(subjectid).update_all(:mother_icf_master_id => StudySubject.mothers.with_familyid(subjectid).first.try(:icf_master_id))}
	end


	desc "Show basic data report and counts"
	task :report => :environment do
		puts
		puts "Report data counts in database"
		puts
		printf "%-45s %5d\n", "StudySubject.count:", StudySubject.count

		StudySubject.select("subject_type_id, COUNT(*) AS count"
				).group(:subject_type_id ).each do |e|
			printf "%-45s %5d\n", "subject_type = #{e.subject_type}:", e.count
		end

		%w{ case_control_type childidwho hispanicity_id father_hispanicity_id
				mother_hispanicity_id sex do_not_contact }.each do |field|
			StudySubject.select("#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-45s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end
		puts
		printf "%-45s %5d\n", "Patient.count:", Patient.count
		%w{ was_under_15_at_dx was_previously_treated was_ca_resident_at_diagnosis 
			organization_id diagnosis_id
		}.each do |field|
			Patient.select( "#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-45s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end
		puts
		printf "%-45s %5d\n", "Enrollment.count:", Enrollment.count
		printf "%-45s %5d\n", "CCLS Enrollments.count:", Enrollment.count(
			:conditions => { :project_id => Project['ccls'].id })
		%w{ consented is_eligible refusal_reason_id document_version_id
			ineligible_reason_id
		}.each do |field|
			Enrollment.select( "#{field}, COUNT(*) AS count"
					).where( :project_id => Project['ccls'].id 
					).group( field ).each do |e|
				printf "%-45s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end
		puts
		printf "%-45s %5d\n", "OperationalEvent.count:", OperationalEvent.count
		%w{ operational_event_type_id }.each do |field|
			OperationalEvent.select( "#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-45s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end
		puts
		printf "%-45s %5d\n", "IcfMasterId.count:", IcfMasterId.count
		printf "%-45s %5d\n", "Used IcfMasterId.count:", 
			IcfMasterId.where( 'study_subject_id IS NOT NULL' ).count
		printf "%-45s %5d\n", "Unused IcfMasterId.count:", 
			IcfMasterId.where( 'study_subject_id IS NULL' ).count
		printf "%-45s %5d\n", "Subjects with icf_master_id:", 
			StudySubject.where( 'icf_master_id IS NOT NULL' ).count
		printf "%-45s %5d\n", "Subjects without icf_master_id:", 
			StudySubject.where( 'icf_master_id IS NULL' ).count
		puts
		printf "%-45s %5d\n", "Subjects with childid:", 
			StudySubject.where( 'childid IS NOT NULL' ).count
		printf "%-45s %5d\n", "Subjects without childid:", 
			StudySubject.where( 'childid IS NULL' ).count

		printf "%-45s %5d\n", "Subjects with patid:", 
			StudySubject.where( 'patid IS NOT NULL' ).count
		printf "%-45s %5d\n", "Subjects without patid:", 
			StudySubject.where( 'patid IS NULL' ).count

		printf "%-45s %5d\n", "Subjects with studyid:", 
			StudySubject.where( 'studyid IS NOT NULL' ).count
		printf "%-45s %5d\n", "Subjects without studyid:", 
			StudySubject.where( 'studyid IS NULL' ).count

		printf "%-45s %5d\n", "Subjects with subjectid:", 
			StudySubject.where( 'subjectid IS NOT NULL' ).count
		printf "%-45s %5d\n", "Subjects without subjectid:", 
			StudySubject.where( 'subjectid IS NULL' ).count
		puts
		printf "%-45s %5d\n", "Address.count:", Address.count
		printf "%-45s %5d\n", "Addressing.count:", Addressing.count
		printf "%-45s %5d\n", "PhoneNumber.count:", PhoneNumber.count
		puts
		printf "%-45s %5d\n", "Sample.count:", Sample.count
		%w{ aliquot_or_sample_on_receipt sample_temperature_id sample_format_id project_id location_id sample_type_id }.each do |field|
			Sample.select( "#{field}, COUNT(*) AS count"
					).group( field ).each do |e|
				printf "%-45s %5d\n", "#{field} = #{e.send(field)}:", e.count
			end
		end
		printf "%-45s %5d\n", "Samples with received_by_ccls_at:", 
			Sample.where( 'received_by_ccls_at IS NOT NULL' ).count
		printf "%-45s %5d\n", "Samples without received_by_ccls_at:", 
			Sample.where( 'received_by_ccls_at IS NULL' ).count
		printf "%-45s %5d\n", "Samples without study_subject:", 
			Sample.where( 'study_subject_id IS NULL' ).count

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
#	Using 1.9.3 now and this works without this modification.
#
#  class String
#    # XML escaped version of to_s. When <tt>escape</tt> is set to false
#    # the CP1252 fix is still applied but utf-8 characters are not
#    # converted to character entities.
#    def to_xs(escape=true)
#      unpack('U*').map {|n| n.xchr(escape)}.join # ASCII, UTF-8
#    rescue
#      unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
#    end
#  end
		puts "Starting...(#{Time.now})"
		%w( abstract address address_type addressing bc_request 
				birth_datum candidate_control 
				document_version enrollment icf_master_id
				icf_master_tracker icf_master_tracker_change icf_master_tracker_update
				interview language 
				odms_exception operational_event operational_event_type 
				patient phone_number phone_type
				project race sample 
				subject_language subject_race study_subject ).each do |model|
			puts "Exporting #{model.pluralize} ..."
			File.open("#{outdir}/#{model.pluralize}.xml",'w'){|f| 
				f.puts model.camelize.constantize.all.to_xml }
		end
		puts "Done.(#{Time.now})"
		puts
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


