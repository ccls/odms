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
		FileUtils.mkdir( outdir ) unless Dir.exists?( outdir )
#		FileUtils.chmod( 0777, outdir )
#		FileUtils.mkdir( outdir, :mode => 0777 ) unless Dir.exists?( outdir )
#		FileUtils.chmod( 0777, outdir )

		config = Rails.configuration.database_configuration
		username = config[Rails.env]['username']
		password = config[Rails.env]['password']
		database = config[Rails.env]['database']
		host = config[Rails.env]['host']
		port = config[Rails.env]['port']
		ActiveRecord::Base.connection.execute('show tables;').to_a.flatten.each do |table|
			next if table == "schema_migrations"
			puts "Table:#{table}:"
#			columns = ActiveRecord::Base.connection.execute("show columns from #{table};"
#				).to_a.collect(&:first)
#			puts "Columns:#{columns.to_s}:"
#
#			#	we use the column name "key" on many occassions.
#			#	This is a reserved word so must be quoted, so quote all columns.
#			#	DON'T DO THIS .... ESCAPED BY '\"'
#			#	Changes NULL to "N which makes no sense to me as it mucks up parsing.
#			#	Perhaps '\\', which escapes " in fields, but converts NULL to \N (better)
#			statement="(SELECT '#{columns.join('\',\'')}')
#				UNION
#				(SELECT `#{columns.join('`,`')}`
#				FROM #{table}
#				INTO OUTFILE '#{outdir}/#{table}.csv'
#				FIELDS ENCLOSED BY '\"' 
#				TERMINATED BY ',' 
#				ESCAPED BY '\\\\'
#				LINES TERMINATED BY '\n');"
#			puts statement;
#			ActiveRecord::Base.connection.execute(statement)




#	20160203
#	Sadly, no one wants to yield permissions to do the above.
#	The following will create a tab separated file.
#	It will not escape anything however.  One tab in the actual data and fail.
#	Actually, the tabs are escaped.   tab\ttest
#	However, converting to csv would require some effort.
#	mysql -u root DBNAME -e "select * from TABLENAME;" > TABLENAME.tsv

#	These seem to work and properly quote double quotes and commas in fields.
#	mysql -u root chirp -e "select * from identifiers;" | ruby -rcsv -n -e "puts chomp.split(\"\t\").to_csv"
#	mysql -u root chirp -e "select * from identifiers;" | ruby -rcsv -n -e 'puts chomp.split("\t").to_csv'

#	.gsub(/NULL/,"")




#config   = Rails.configuration.database_configuration
#host     = config[Rails.env]["host"]
#database = config[Rails.env]["database"]
#username = config[Rails.env]["username"]
#password = config[Rails.env]["password"]
#
#	OR
#
#require 'YAML'
#info = YAML::load(IO.read("database.yml"))
#print info["production"]["host"]
#print info["production"]["database"]
#...


#	username = Rails.configuration.database_configuration[Rails.env]['username']
#	password = Rails.configuration.database_configuration[Rails.env]['password']
#	database = Rails.configuration.database_configuration[Rails.env]['database']
#	host = Rails.configuration.database_configuration[Rails.env]['host']
#	port = Rails.configuration.database_configuration[Rails.env]['port']

#			`mysql --user=#{username} --password=#{password} #{database} --host=#{host} --port=#{port} -e "select * from #{table};" | ruby -rcsv -n -e 'puts chomp.gsub(/NULL/,"").gsub(//,"\n").split("\t").to_csv' > #{outdir}/#{table}.csv`
#	using .my.cnf to hold password
#			`mysql --user=#{username} #{database} --host=#{host} --port=#{port} -e "select * from #{table};" | ruby -rcsv -n -e 'puts chomp.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "").gsub(/NULL/,"").gsub(//,"\n").split("\t").to_csv' > #{outdir}/#{table}.csv`


#	Since I'm forced to use encoding, add the universal_newline option.
#	unpack("C*").pack("U*") seems to work and preserve the values!
#	Keeping the encode(universal_newline: true) instead of the gsub() as it doesn't complain ...
#		-e:1: warning: encountered \r in middle of line, treated as a mere space


			`mysql --user=#{username} #{database} --host=#{host} --port=#{port} -e "select * from #{table};" | ruby -rcsv -n -e 'puts chomp.unpack("C*").pack("U*").encode(universal_newline: true).gsub(/NULL/,"").split("\t").to_csv' > #{outdir}/#{table}.csv`


#	On my mac, "Montañez" works just fine.


#	on occassion get ... so had to add encode to the chain. (so far only in addresses and study_subjects)
#-e:1:in `gsub': invalid byte sequence in UTF-8 (ArgumentError)
#	ruby seems to crash on these occassions and results in truncation of the csv.
#		Monta?ez 
#		V?a Cristobal
#	Simplest solution is to remove the chars.

#	Oddly, from the rails console, this isn't a problem?

#	.encode(universal_newline: true)



#irb(main):004:0> Rails.configuration.database_configuration['test']
#=> {"adapter"=>"mysql", "encoding"=>"utf8", "database"=>"odms_test", "username"=>"root", "password"=>nil, "host"=>"localhost"}
#irb(main):005:0> Rails.configuration.database_configuration['test']['username']
#=> "root"
#irb(main):006:0> Rails.env
#=> "development"

#	username = Rails.configuration.database_configuration[Rails.env]['username']
#	password = Rails.configuration.database_configuration[Rails.env]['password']




		end

#		system("sed -i '' 's/\\\\N//g' #{outdir}/*.csv")	#	gotta get these out
#		system("sed -i '' 's///g' #{outdir}/*.csv")	#	necessary?
#		system("sed -i '' 's/\\\\\\"/'"'"'/g' #{outdir}/*.csv") # DOES NOT WORK
		#	The double quotes used by system make this difficult.
		#	Backticks work well.

#		#	20160203 - Using the new technique from the command line
#		#			I'm not sure if these are needed.  Perhaps the Control-M, but I can do in command?
#		#	Meant to remove SQL's \N which represents NULL
#		`sed -i '' 's/\\\\N//g' #{outdir}/*.csv`
#		#	Meant to remove any stray Microsoft carriage return - line feeds.
#		`sed -i '' 's///g' #{outdir}/*.csv`
#		#	Meant to swap double quotes for single quotes in the data. Somehow was corrupt?
#		`sed -i '' 's/\\\\"/'"'"'/g' #{outdir}/*.csv`

#		system("chmod a-w #{outdir}/*.csv")
#		system("chmod 755 #{outdir}")

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
		%w{ aliquot_or_sample_on_receipt sample_temperature_id sample_format_id project_id organization_id sample_type_id }.each do |field|
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


