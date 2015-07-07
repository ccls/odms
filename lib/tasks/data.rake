namespace :app do
namespace :data do

#	def assert(expression,options={})
#		defaults = {
#			:pre_message  => 'Checking something.',
#			:fail_message => 'Assertion failed.'
#		}
#		if options.is_a?(String)
#			message = options
#			options = {}
#			options[:pre_message] = message
#		end
#		defaults.merge(options)
#		puts options[:pre_message]
#		raise "#{options[:fail_message]} :\n #{caller[0]}" unless expression
#	end

	task :dump_to_csv => :environment do
		outdir = "#{Rails.root.to_s}/csv_dump.#{Time.current.strftime('%Y%m%d%H%M%S')}"
		#	the directory NEEDS to exist and be writable by user _mysql
		FileUtils.mkdir( outdir, :mode => 0777 ) unless Dir.exists?( outdir )
		FileUtils.chmod( 0777, outdir )
		ActiveRecord::Base.connection.execute('show tables;').to_a.flatten.each do |table|
			next if table == "schema_migrations"
			puts "Table:#{table}:"
			columns = ActiveRecord::Base.connection.execute("show columns from #{table};"
				).to_a.collect(&:first)
			puts "Columns:#{columns.to_s}:"

			#	we use the column name "key" on many occassions.
			#	This is a reserved word so must be quoted, so quote all columns.
			#	DON'T DO THIS .... ESCAPED BY '\"'
			#	Changes NULL to "N which makes no sense to me as it mucks up parsing.
			#	Perhaps '\\', which escapes " in fields, but converts NULL to \N (better)
			statement="(SELECT '#{columns.join('\',\'')}')
				UNION
				(SELECT `#{columns.join('`,`')}`
				FROM #{table}
				INTO OUTFILE '#{outdir}/#{table}.csv'
				FIELDS ENCLOSED BY '\"' 
				TERMINATED BY ',' 
				ESCAPED BY '\\\\'
				LINES TERMINATED BY '\n');"
			puts statement;
			ActiveRecord::Base.connection.execute(statement)

		end

		puts
		puts "Be advised that these files are still not perfect."
		puts "They still contain ^M's for carriage returns,"
		puts "escaped double quotes which could be problematic,"
		puts "add \N's where NULLs used to be."
		puts "And they belong to _mysql so that needs changed."
		puts

#	alas, that is not perfect.
#	need to vi *.csv
#	:bufdo :%s///g |:up				#	somehow this makes the csv invalid?
#	:bufdo :%s/\\"/'/g |:up			#	somehow this makes the csv invalid?
#	:bufdo :%s/\\N//g |:up
#	could probably use sed so its scriptable

		#	running this sed actually chown's from _mysql to me
		#	because of the -i,  I imagine.
		#	so many \s
		#	These work!
		system("sed -i '' 's/\\\\N//g' #{outdir}/*.csv")	#	gotta get these out
		#system("sed -i '' 's///g' #{outdir}/*.csv")	#	necessary?
		#system("sed -i '' 's/\\\\"/\\\\'/g' #{outdir}/*.csv") # DOES NOT WORK

		system("chmod a-w #{outdir}/*.csv")
		system("chmod 755 #{outdir}")

	end	#	task :dump_to_csv => :environment do

	task :checkup => :environment do

		StudySubject.all.each do |study_subject| 

			puts "Checking subjectid #{study_subject.subjectid}"
			subjects = StudySubject.with_subjectid(study_subject.subjectid)
			subject = subjects.first
			assert subjects.length == 1, 
				"There should be only one subject with this subjectid.  (Would've failed already)"

			puts "Checking icf_master_id #{study_subject.icf_master_id} unless blank"
			unless study_subject.icf_master_id.blank?
				subjects = StudySubject.with_icf_master_id(study_subject.icf_master_id)
				subject = subjects.first
				assert subjects.length == 1, 
					"There should be only one subject with this icf_master_id.  (Would've failed already)"
			end

			puts "Checking childid #{study_subject.childid} unless blank"
			unless study_subject.childid.blank?
				subjects = StudySubject.with_childid(study_subject.childid)
				subject = subjects.first
				assert subjects.length == 1, 
					"There should be only one subject with this childid.  (Would've failed already)"
			end

			puts "Checking studyid #{study_subject.studyid} unless blank"
			unless study_subject.studyid.blank?
				subjects = StudySubject.with_studyid(study_subject.studyid)
				subject = subjects.first
				assert subjects.length == 1, 
					"There should be only one subject with this studyid.  (Would've failed already)"
			end

			assert study_subject.subjectid.length == 6, 
				"subjectid #{study_subject.subjectid} should be 6 chars long"
			assert study_subject.familyid.length == 6, 
				"familyid #{study_subject.familyid} should be 6 chars long"
			assert study_subject.matchingid.length == 6, 
				"matchingid #{study_subject.matchingid} should be 6 chars long"

			if study_subject.is_case?

				matching = StudySubject.cases.with_matchingid(study_subject.subjectid)
				assert matching.length == 1, 
					"There should be ONLY THIS CASE subject with this as a matchingid"

				assert study_subject.icf_master_id == study_subject.case_icf_master_id,
					"ICF Master ID should match Case ICF Master ID: " <<
					"#{study_subject.icf_master_id} == #{study_subject.case_icf_master_id}"

			elsif study_subject.is_control?

				matching = StudySubject.with_matchingid(study_subject.subjectid)
				assert matching.empty?, "There should be no subject with this as a matchingid" 

			else	#	is mother, father or twin

				matching = StudySubject.with_matchingid(study_subject.subjectid)
				assert matching.empty?, "There should be no subject with this as a matchingid" 

				family = StudySubject.with_familyid(study_subject.subjectid)
				assert family.empty?, "There should be no subject with this as a familyid" 

				if study_subject.is_mother?
					assert study_subject.icf_master_id == study_subject.mother_icf_master_id,
						"ICF Master ID should match Mother ICF Master ID: " <<
						"#{study_subject.icf_master_id} == #{study_subject.mother_icf_master_id}"
				end

			end

			assert study_subject.case_subject.try(:icf_master_id) == study_subject.case_icf_master_id,
				"Case Subject's ICF Master ID should match Case ICF Master ID: " <<
				"#{study_subject.case_subject.try(:icf_master_id)} == #{study_subject.case_icf_master_id}"

			assert study_subject.mother.try(:icf_master_id) == study_subject.mother_icf_master_id,
				"Mother Subject's ICF Master ID should match Mother ICF Master ID: " <<
				"#{study_subject.mother.try(:icf_master_id)} == #{study_subject.mother_icf_master_id}"


			if study_subject.is_case?
				assert study_subject.subjectid == study_subject.matchingid,
					"case subjectid should match matchingid: "<<
					"#{study_subject.subjectid} == #{study_subject.matchingid}"
			else
				assert study_subject.subjectid != study_subject.matchingid,
					"non-case subjectid should NOT match matchingid: "<<
					"#{study_subject.subjectid} != #{study_subject.matchingid}"
			end

			if study_subject.is_child?
				assert study_subject.subjectid == study_subject.familyid,
					"child subjectid should match familyid: "<<
					"#{study_subject.subjectid} == #{study_subject.familyid}"
			else	#	if study_subject.is_mother?	( or possibly a twin )
				assert study_subject.subjectid != study_subject.familyid,
					"mother (or twin) subjectid should NOT match familyid: "<<
					"#{study_subject.subjectid} != #{study_subject.familyid}"
			end


			puts; puts

		end

	end


	task :disseminate_icf_master_ids => :environment do

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

		StudySubject.select("subject_type, COUNT(*) AS count"
				).group(:subject_type).each do |e|
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
		%w( abstract address address_type bc_request 
				birth_datum candidate_control 
				document_version enrollment icf_master_id
				icf_master_tracker icf_master_tracker_change icf_master_tracker_update
				interview language 
				operational_event operational_event_type 
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


