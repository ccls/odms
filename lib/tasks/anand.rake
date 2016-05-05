require 'csv'

## gonna start asserting that everything is as expected.
## will slow down import, but I want to make sure I get it right.
#def assert(expression,message = 'Assertion failed.')
#	raise "#{message} :\n #{caller[0]}" unless expression
#end

#def total_lines(csv_file_name)
#	f = CSV.open(csv_file_name,'rb')
#	total_lines = f.readlines.size  # includes header, but so does f.lineno
#	f.close
#	total_lines
#end

def childid_cdcid 
	unless @childid_cdcid
		@childid_cdcid = HWIA.new
		CSV.open( 'anand/2010-12-06_MaternalBiospecimenIDLink.csv',
				'rb',{ :headers => true }).each do |line|
			@childid_cdcid[line['CHILDID'].to_i] = line['CDC_ID'].to_i
		end
	end
	@childid_cdcid
end

#
# NOTE
#	CDC\ Maternal\ Inventory\ 11_10_08.csv 
#	Child ID of 09299 changed to 09229 as this subject had samples with the
#	corresponding CDC ID of 318
#

#
#	One-off tasks written for Anand
#
namespace :anand do

	#
	#	For this task, I wanted the output quoting to match the input quoting
	#	so that I can compare.  By default, any attempt to quote the fields
	#	will result in triplicate quoting as the quotes get quoted.  Irritating.
	#	However, I read a response to a post online 
	#		http://stackoverflow.com/questions/4854900
	#	that sets the quote char to null and then manually quote the fields.
	#	Doing it this way doesn't quote the quotes.  Clever.
	#	
	task :verify_maternal_last_batch => :environment do
		total_lines = total_lines('anand/20130405_CDC_GEGL_lastbatch.csv')
		error_file = File.open('anand/20130405_CDC_GEGL_lastbatch.txt','w')
		csv_out = CSV.open( 'anand/20130405_CDC_GEGL_lastbatch_OUTPUT.csv', 'w',
			{ :quote_char => "\0" } )
		csv_out << %w(LabelID AstroID subjectid sampleid sex sample_type collected_date Box 
			Position).collect{|c| "\"#{c}\""}
		sampleids_in_csv = []
		CSV.open( 'anand/20130405_CDC_GEGL_lastbatch.csv',
			'rb',{ :headers => true }).each do |line|
			sampleids_in_csv << line['sampleid'] if line['sampleid'].present?
		end
		( csv_in = CSV.open( 'anand/20130405_CDC_GEGL_lastbatch.csv',
				'rb',{ :headers => true })).each do |line|

			#	"LabelID","AstroID","subjectid","sampleid","sex","sample_type",
			#	"collected_date","Box","Position"
			puts "Processing #{csv_in.lineno}/#{total_lines}"

			#	subjectid sampleid sex sample_type collected_date Box Position)
			outline = ["\"#{line['LabelID']}\"", "\"#{line['AstroID']}\""]

			#	verify subjectid exists
			#	verify sampleid exists
			#	verify subject with subjectid is same subject with cdcid/childid
			#	verify subject sex
			#	verify subject is mother
			#	verify sample sample type

			cdcid = line['LabelID'].gsub(/^05-57-/,'').gsub(/-\w+$/,'').to_i
			childid = childid_cdcid.invert[cdcid]
			cdc_mother = StudySubject.with_childid(childid).first.mother

			subject = nil

			outline << if line['subjectid'].present?
				subject = StudySubject.with_subjectid(line['subjectid']).first
				if subject.nil?
					raise "No subject found with #{line['subjectid']}"
					#	DOESN'T HAPPEN
					#	error_file.puts "No subject found with #{line['subjectid']}"
					#	error_file.puts line
					#	error_file.puts 
				end
				line['subjectid'].presence
			else
				#	error_file.puts "SubjectID is blank"
				#	error_file.puts line
				#	error_file.puts "CDC mother subjectid would be #{cdc_mother.subjectid}"
				#	error_file.puts
				puts "SubjectID is blank."
				puts "Assigning the subjectid of mother matching CDCID.#{cdc_mother.subjectid}"
				cdc_mother.subjectid
			end

			#
			#	Do we want these samples attached to the child or the mother?  
			#	Assuming mother since all but one are attached to mothers,
			#		even though the LabelID contains the child's childid.
			#

			if subject and !subject.is_mother?
				raise "subject is not a mother"
				#	FIXED SO WON'T HAPPEN
				#	error_file.puts "subject is not a mother"
				#	error_file.puts line
				#	if subject.mother.nil?		#	DOESN'T HAPPEN
				#		error_file.puts "And subject has no mother in database. could create."
				#	else
				#		puts "Mother: #{subject.mother.childid}, #{subject.mother.subjectid}"
				#	end
				#	error_file.puts
				#
				#	only happens for one subjectid
				#
				#	create mother?
				#				subject.create_mother
				#	reassign it to subject?
				#				subject = subject.mother
				#
			end

			if subject and subject.childid != cdc_mother.childid
				raise "childid mismatch #{subject.childid} : #{cdc_mother.childid}"
				#	FIXED SO WON'T HAPPEN
				#	error_file.puts "childid mismatch #{subject.childid} : #{cdc_mother.childid}"
				#	error_file.puts line
				#	error_file.puts
			end

			#	2 samples required reassignment to a different subject 
			#	to match CDCID/CHILDID relationship

			sample = nil
			outline << if line['sampleid'].present?
				sample = Sample.where(:id => line['sampleid'].to_i).first

				if sample.nil?		#	DOESN'T HAPPEN
					raise "No sample found with #{line['sampleid']}"
					#	error_file.puts "No sample found with #{line['sampleid']}"
					#	error_file.puts line
					#	error_file.puts 
				end
				line['sampleid'].presence
			else
				puts "SampleID is blank." 

				#	error_file.puts "SampleID is blank." 
				#	error_file.puts line

				samples = Sample.where(
					Sample.arel_table[:external_id].matches("%#{line['LabelID']}%") )

				assumed_sampleid = nil

				if samples.empty?
					raise "And no samples match external_id #{line['LabelID']}"
					#	DOESN'T HAPPEN
					#	error_file.puts "And no samples match external_id #{line['LabelID']}"
				else
					#	error_file.puts "BUT #{samples.length} samples DO match external_id #{line['LabelID']}"
					#	error_file.puts samples.collect(&:sampleid)
					#	csv doesn't have leading 0's so just use id, AND they are strings
					sampleids = samples.collect(&:id).collect(&:to_s)	
					puts "Matching sampleids #{sampleids.join(',')}"

					unused_sampleids = sampleids - sampleids_in_csv

					if unused_sampleids.length == 1
						assumed_sampleid = unused_sampleids.first
					else
						raise "More that one left over matching sampleid? #{sampleids.join(',')}"
					end
				end
				#	error_file.puts
				assumed_sampleid
			end

			if subject and sample
				if !subject.samples.include?( sample )		#	DOESN'T HAPPEN
					raise "Sample does not belong to subject"
					#	FIXED SO WON'T HAPPEN
					#	error_file.puts "Sample does not belong to subject"
					#	error_file.puts line
					#	error_file.puts
				end
			elsif cdc_mother and sample
				if !cdc_mother.samples.include?( sample )		#	DOESN'T HAPPEN
					raise "Sample does not belong to cdc_mother"
					#	FIXED SO WON'T HAPPEN
					#	error_file.puts "Sample does not belong to cdc_mother"
					#	error_file.puts line
					#	error_file.puts
				end
			end


			outline << "\"#{line['sex']}\""
			outline << "\"#{line['sample_type']}\""
			outline << line['collected_date']
			outline << if line['Box'].to_s.match(/^NCL/)
				"\"#{line['Box']}\""
			else
				line['Box']
			end
			outline << line['Position']
			csv_out << outline
		end	#	( csv_in = CSV.open( 'anand/20130405_CDC_GEGL_lastbatch.csv', 'rb'
		error_file.close
		csv_out.close
	end	#	task :verify_maternal_last_batch => :environment do


	#	20130402
	task :output_mothers_with_their_own_childids => :environment do
		csv_out = CSV.open('anand/mothers_with_their_own_childids.csv','w')
		csv_out << %w( mother_subjectid mother_childid child_subjectid child_childid )
		StudySubject.mothers.where(StudySubject.arel_table[:childid].not_eq(nil)).each do |mother|
			out = []
			out << mother.subjectid
			out << mother.childid
			child = mother.child
			out << child.subjectid
			out << child.childid
			puts out.join(',')
			csv_out << out
		end
		csv_out.close
	end


	#	20130402
	task :verify_childid_subjectid_in_original_samples_is_same_subject => :environment do
		total_lines = total_lines('anand/ODMS_samples_xxxxxx.csv')
		error_file = File.open('anand/ODMS_samples_xxxxxx.txt','w')
		( csv_in = CSV.open( 'anand/ODMS_samples_xxxxxx.csv',
				'rb',{ :headers => true })).each do |line|

			puts "Processing #{csv_in.lineno}/#{total_lines}"

			subject = StudySubject.with_subjectid(line['subjectID']).first

			if subject.nil?
				error_file.puts "No subject found with #{line['subjectID']}"
				error_file.puts line
				error_file.puts 
				next
			end
			#
			#	The subjectids and childids don't always match.
			#	Sometimes they were subjectid for the mother and childid of the child???
			#	When I imported these samples, I was only going by the subjectid.
			#	This file confirms the mismatch at import of the 0196 samples.
			#
			if subject.childid != line['childid'].to_i &&
					subject.child.childid != line['childid'].to_i
				error_file.puts "Childid Subjectid mismatch"
				error_file.puts "Expected #{line['childid']}"
				error_file.puts "Has #{subject.childid}"
				error_file.puts line
				error_file.puts
				next
			end

		end
		error_file.close
	end	#	task :verify_childid_subjectid_in_original_samples_is_same_subject => :environment do


	#	20130401
	#	check that all samples with an external_id matching the cdcid
	#	belong to the subject with the given childid
	task :verify_cdcid_childid_sample_link => :environment do
		error_file = File.open('anand/2010-12-06_MaternalBiospecimenIDLink.txt','w')
		childid_cdcid.each do |childid, cdcid|
			cdcid = sprintf('%04d',cdcid.to_i)
			puts "Checking childid #{childid} against cdcid #{cdcid}"
			samples = Sample.where(
				Sample.arel_table[:external_id].matches("05-57-#{cdcid}%") )
			samples.each do |sample|
				puts "DB:#{sample.study_subject.child.childid} CSV:#{childid}"
				unless ( sample.study_subject.child.childid == childid )	#.to_i )
					error_file.puts "Childid Mismatch"
					error_file.puts "CDC ID #{cdcid}"
					error_file.puts "DB:#{sample.study_subject.child.childid} CSV:#{childid}"
					error_file.puts
				end
			end
		end

		#	ensure that the cdcids are unique
		if childid_cdcid.keys.length != childid_cdcid.invert.keys.length
			error_file.puts "ChildIDs #{childid_cdcid.keys.length}" 
			error_file.puts "CDC IDs  #{childid_cdcid.invert.keys.length}"
		end

		error_file.close
	end	#	task :verify_cdcid_childid_sample_link => :environment do


#	20160504 - Commented out to avoid accidental usage.
#	#	20130402
#	task :import_cdc_biospecimens_inventory_not_on_gegl_manifest => :environment do
#		raise "This task has been disabled."
#		csv_out = CSV.open('anand/20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest-OUTPUT.csv','w')
#		csv_out << ['LabelID','SubjectID','SampleID','ProjectID','Gender','smp_type','Amount (mL)',
#			'Box','Group','Pos','Container']
#		total_lines = total_lines('anand/20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv')
#		(csv_in = CSV.open( 'anand/20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv',
#				'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{csv_in.lineno}/#{total_lines}"
#			#	,"DLSSampleID","AstroID","smp_type","Box","Group","Pos","Amount (mL)",
#			#		"Amount Full","Container","Sample Type"
#			#1,"05-57-0042-R1","0019UJNP","RBC",,"NCCLS07C11",1,0.75,,"2.0 mL cryo","R1 RBC Folate"
#
#			cdcid = line['DLSSampleID'].gsub(/^05-57-/,'').gsub(/-\w+$/,'').to_i
#			childid = childid_cdcid.invert[cdcid]
#
#			subject = StudySubject.where(:childid => childid).first.mother
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:sample_type_id => 1003,
#				:external_id_source => '20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv',
#				:external_id => line['DLSSampleID'],
#				:notes => "Imported from 20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv\n" <<
#					"DLSSampleID #{line['DLSSampleID']},\n" <<
#					"AstroID #{line['AstroID']},\n" <<
#					"smp_type #{line['smp_type']},\n" <<
#					"Box #{line['Box']},\n" <<
#					"Group #{line['Group']},\n" <<
#					"Pos #{line['Pos']},\n" <<
#					"Amount (mL) #{line['Amount (mL)']},\n" <<
#					"Amount Full #{line['Amount Full']},\n" <<
#					"Container #{line['Container']}" )
#
#			out = []
#			out << line['DLSSampleID']
#			out << subject.subjectid
#			out << sample.sampleid
#			out << 'CCLS'
#			out << 'F'
#			out << sample.sample_type.gegl_sample_type_id
#			out << line['Amount (mL)']
#			out << line['Box']
#			out << line['Group']
#			out << line['Pos']
#			out << line['Container']
#			puts out.join(',')
#			csv_out << out
#		end	#	CSV.open( '20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv',
#		csv_out.close
#		puts "Commiting to Sunspot index."
#		Sunspot.commit
#	end	#	task :import_cdc_biospecimens_inventory_not_on_gegl_manifest => :environment do


	#	20130401
	#	check if samples with the given external_id exist
	task :verify_cdc_biospecimens_inventory_not_on_gegl_manifest => :environment do
		CSV.open( 'anand/20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv',
				'rb',{ :headers => true }).each do |line|
			#	,"DLSSampleID","AstroID","smp_type","Box","Group","Pos","Amount (mL)",
			#		"Amount Full","Container","Sample Type"
			#1,"05-57-0042-R1","0019UJNP","RBC",,"NCCLS07C11",1,0.75,,"2.0 mL cryo","R1 RBC Folate"
			#	DLSSampleID ... external_id

##			sample = Sample.where(:external_id => line['DLSSampleID']).first
##			sample = Sample.where(:external_id => line['DLSSampleID'].gsub(/-??$/,'')).first
##external_id = line['DLSSampleID'].gsub(/-..$/,'%')
#external_id = line['DLSSampleID']
##external_id = line['DLSSampleID'].gsub(/-R1$/,'-P1')
##puts external_id
#			samples = Sample.where(
#				Sample.arel_table[:external_id].matches(external_id) )
#			if samples.empty?
#				raise "No sample found with external_id #{line['DLSSampleID']}" 
#			else
#				puts "-- sample found with external_id #{line['DLSSampleID']}" 
#				puts samples.collect(&:external_id)
#			end

			cdcid = line['DLSSampleID'].gsub(/^05-57-/,'').gsub(/-\w+$/,'').to_i
			childid = childid_cdcid.invert[cdcid]
			raise "CDCID Not Found. #{cdcid}" if childid.nil?

		end	#	CSV.open( '20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv',
	end	#	task :verify_cdc_biospecimens_inventory_not_on_gegl_manifest => :environment do


	#	20130328
	task :verify_cdc_biospecimens_inventory => :environment do
		error_file = File.open('anand/20111114_CDC_UrinePlasmaRBC_SampleInventory.txt','w')
		(i=CSV.open( 'anand/20111114_CDC_UrinePlasmaRBC_SampleInventory.csv',
				'rb',{ :headers => true })).each do |line|
			#"external_id","astroid","SubjectID","SampleID","sex","type","collected_on","Box","Position",,1
			sample = nil
			if line['SubjectID'].blank?
				puts "Blank subjectid."
				puts line
				error_file.puts i.lineno
				error_file.puts line
				error_file.puts "Blank SubjectID"
				error_file.puts
				sample = Sample.find(line['SampleID'].to_i)
				#	actually, find would raise an error so this will never happen
				raise "No sample found with sampleid #{line['SampleID']}" if sample.nil?
				puts "Found sample with #{line['SampleID']}"
			else
				subject = StudySubject.with_subjectid(line['SubjectID']).first
				raise "No subject found with subjectid #{line['SubjectID']}" if subject.nil?
				puts "Found subject with #{line['SubjectID']}"

				unless subject.is_mother?
					error_file.puts i.lineno
					error_file.puts line
					error_file.puts "Subject is not a Mother" 
					error_file.puts subject.subject_type
					error_file.puts
				end

				sample = subject.samples.find(line['SampleID'].to_i)
				#	actually, find would raise an error so this will never happen
				raise "No sample found with sampleid #{line['SampleID']}" if sample.nil?
				puts "Found subject's sample with #{line['SampleID']}"
			end
			puts "Types: DB: #{sample.sample_type.gegl_sample_type_id} CSV: #{line['type']}"
			puts "ExtID: DB: #{sample.external_id} CSV: #{line['external_id']}"
			puts "Sex: DB: #{sample.study_subject.sex} CSV: #{line['sex']}"
#			Our gegl sample type codes aren't always the same
#			raise "Type mismatch" if sample.sample_type.gegl_sample_type_id != line['type']
			raise "ExtID Mismatch" if sample.external_id != line['external_id']

			if sample.study_subject.sex != line['sex'].upcase
				error_file.puts i.lineno
				error_file.puts line
				error_file.puts "Sex Mismatch"
				error_file.puts "Sex: DB: #{sample.study_subject.sex} CSV: #{line['sex']}"
				error_file.puts
			end

		end	#	CSV.open
		error_file.close
	end	#	task :check_maternal_biospecimens_inventory


#	20160504 - Commented out to avoid accidental usage.
#	#	20130401
#	task :import_maternal_biospecimens_inventory => :environment do
#		raise "This task has been disabled."
#		error_file = File.open('anand/CDC Maternal Inventory 11_10_08.txt','w')
#		csv_out = CSV.open('anand/UCSF Maternal Samples.csv','w') 
#		csv_out << ['LabelID','SubjectID','SampleID','ProjectID','Gender','smp_type',
#			'Date Collected','Date Received','Vol(ml)','Freezer','Rack','Box','Position']
#		total_lines = total_lines('anand/CDC Maternal Inventory 11_10_08.csv')
#
#		childid_cdcid_out = HWIA.new
#
#		(csv_in = CSV.open( 'anand/CDC Maternal Inventory 11_10_08.csv', 
#				'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{csv_in.lineno}/#{total_lines}"
#
#			if line['Assigned Location'] != '1 Wiencke Lab'
#				puts "Location is not Wiencke Lab.  It is '#{line['Assigned Location']}'. Skipping."
#				next
#			end
#			if line['Spec Type'] == 'VOC(gray top)'	#	irrelevant as only location '11 CDC'
#				puts "Spec Type is VOC(gray top).  Skipping."
#				next
#			end
#			if line['Spec Type'] == 'VOC(gray tube)'	#	irrelevant as only location '11 CDC'
#				puts "Spec Type is VOC(gray tube).  Skipping."
#				next
#			end
#			puts line
#
#			#
#			# "Item#","Assigned Location","Child ID","CDC ID","2-Digit CDC ID","Spec Type",
#			#	"Freezer","Rack","Box","Position","Vol (ml)","Date Collected","Date Received",
#			#	"Date Shipped to CDC","Studycode","Comments","UsedUp?","Hematocrit",
#			#	"First Morning Void?"
#			#
#			subject = StudySubject.where(:childid => line['Child ID']).first.mother
#			raise "No subject found with childid #{line['Child ID']}" if subject.nil?
#
#			cdcid = line['CDC ID'].gsub(/05-57-/,'').to_i
#			if childid_cdcid_out.has_key? line['Child ID'].to_i
#				if childid_cdcid_out[line['Child ID'].to_i] != cdcid	#	line['CDC ID'].to_i
#					puts "Child ID CDC ID Mismatch"
#					puts "Have CDC ID :#{childid_cdcid_out[line['Child ID'].to_i]}:"
#					puts "This CDC ID :#{cdcid}:"		#	line['CDC ID'].to_i}:"
#					raise "Child ID CDC ID Mismatch"
#				end
#			else
#				childid_cdcid_out[line['Child ID'].to_i] = cdcid	#	line['CDC ID'].to_i
#			end
#
#			cdcid = childid_cdcid[line['Child ID'].to_i]
#			if cdcid.blank?
#				error_file.puts line['CDC ID'] 
#				error_file.puts line['Child ID'] 
#				error_file.puts "No comparison cdc id"
#				error_file.puts
#			elsif line['CDC ID'] != "05-57-#{sprintf('%04d',cdcid)}"
#				error_file.puts "CDC ID Mismatch" 
#				error_file.puts line['CDC ID'] 
#				error_file.puts "05-57-#{sprintf('%04d',cdcid)}"
#				error_file.puts
#			end
#
#			sample_type = case line['Spec Type']
#				when 'Serum Cotinine' then SampleType.find 1002
#				when 'Plasma Folate' then SampleType.find 1000
#				when 'RBC Folate' then SampleType.find 1003
#				when 'Urine Cup' then SampleType.find 25
#				when 'SAA' then SampleType.find 1002
#				when 'SE' then SampleType.find 1002
#				when 'PL' then SampleType.find 1000
#				when 'RBC' then SampleType.find 1003
#				when 'CL' then SampleType.find 1001
#				when 'Urine Archive' then SampleType.find 25
#				when 'Clot' then SampleType.find 1001
#				when 'PA' then SampleType.find 1000
#				else
#					raise "All hell. Unexpected spec type :#{line['Spec Type']}:"
#			end
#
#			labelid = "#{line['CDC ID']}-#{line['2-Digit CDC ID']}"
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:sample_type_id => sample_type.id,
#				:external_id_source => 'CDC Maternal Inventory 11_10_08.csv',
#				:external_id => labelid,
#				:collected_from_subject_at => line['Date Collected'],
#				:received_by_ccls_at => line['Date Received'],
#				:notes => "Imported from CDC Maternal Inventory 11_10_08.csv\n" <<
#					"Child ID #{line['Child ID']},\n" <<
#					"CDC ID #{line['CDC ID']},\n" <<
#					"2-Digit CDC ID #{line['2-Digit CDC ID']},\n" <<
#					"Spec Type #{line['Spec Type']},\n" <<
#					"Freezer #{line['Freezer']},\n" <<
#					"Rack #{line['Rack']},\n" <<
#					"Box #{line['Box']},\n" <<
#					"Position #{line['Position']},\n" <<
#					"Vol (ml) #{line['Vol (ml)']},\n" <<
#					"UsedUp? #{line['UsedUp?']},\n" <<
#					"Hematocrit #{line['Hematocrit']},\n" <<
#					"First Morning Void? #{line['First Morning Void?']}" )
#
#			out = []
#
#			out << labelid
#			out << subject.subjectid
#			out << sample.sampleid
#			out << 'CCLS'
#			out << 'F'
#			out << sample.sample_type.gegl_sample_type_id
#			out << line['Date Collected']
#			out << line['Date Received']
#			out << line['Vol (ml)']
#			out << line['Freezer']
#			out << line['Rack']
#			out << line['Box']
#			out << line['Position']
#
#			puts out.join(',')
#
#			csv_out << out
#
#		end	#	CSV.open
#		csv_out.close
#		error_file.close
#
#		childid_cdcid_csv_out = CSV.open('anand/CDC Maternal Inventory 11_10_08-childid-cdcid.csv','w')
#		childid_cdcid_csv_out << ["CHILDID","CDC_ID"]
#		childid_cdcid_out.each { |childid,cdcid| childid_cdcid_csv_out << [childid,cdcid] }
#		childid_cdcid_csv_out.close
#
#		puts "Commiting to Sunspot index."
#		Sunspot.commit
#	end	#	task :import_maternal_biospecimens_inventory


	#	20130321
	#	Just confirm that the childids in this csv file exist.
	task :check_maternal_biospecimens_inventory => :environment do
		(i=CSV.open( 'anand/CDC Maternal Inventory 11_10_08.csv', 
				'rb',{ :headers => true })).each do |line|
			puts line
			#
			# "Item#","Assigned Location","Child ID","CDC ID","2-Digit CDC ID","Spec Type",
			#	"Freezer","Rack","Box","Position","Vol (ml)","Date Collected","Date Received",
			#	"Date Shipped to CDC","Studycode","Comments","UsedUp?","Hematocrit",
			#	"First Morning Void?"
			#
			subject = StudySubject.where(:childid => line['Child ID']).first
			raise "No subject found with childid #{line['Child ID']}" if subject.nil?
		end	#	CSV.open
	end	#	task :check_maternal_biospecimens_inventory


#	20160504 - Commented out to avoid accidental usage.
#	#	20130321
#	#	Loop over the guthrie card inventory and create new samples
#	#	and then output a combination of the input and the new sample data.
#	task :import_guthrie_card_inventory => :environment do
#		raise "This task has been disabled."
#		csv_out = CSV.open('anand/Guthrie cards inventory 02_05_13- OUTPUT.csv','w') 
#		csv_out << %w(
#			guthrieid subjectid sampleid projectid gender smp_type book page pocket
#		)
#		total_lines = total_lines('anand/Guthrie cards inventory 02_05_13-APC CHECKED- for import.csv')
#		(csv_in = CSV.open( 'anand/Guthrie cards inventory 02_05_13-APC CHECKED- for import.csv', 
#				'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{csv_in.lineno}/#{total_lines}"
#			#
#			# "SubjectID","GuthrieID","Book","Page","Pocket"
#			#
#			out = []
#			subject = StudySubject.with_subjectid(line['SubjectID']).first
#			raise "No subject found with #{line['SubjectID']}" if subject.nil?
#
#			#
#			#	Create Sample and get sampleid
#			#		sample_type = Blood Spot ( id: 16 ... archive newborn blood )
#			#		external_id_source = 'Guthrie' ( perhaps with book, page and pocket? )
#			#		external_id = line['GuthrieID']
#			#	
#
#			sample = subject.samples.create!(
#				:project_id => Project[:ccls].id,
#				:sample_type_id => 16,
#				:sample_format_id => SampleFormat[:guthrie].id,
#				:external_id_source => "Guthrie cards inventory 02_05_13-APC CHECKED- for import",
#				:external_id => line['GuthrieID'],
#				:notes => "Imported from Guthrie cards inventory 02_05_13-APC CHECKED- for import\n" <<
#					"SubjectID #{line['SubjectID']},\n" <<
#					"GuthrieID #{line['GuthrieID']},\n" <<
#					"Book #{line['Book']},\n" <<
#					"Page #{line['Page']},\n" <<
#					"Pocket #{line['Pocket']}" )
#
#			out << line['GuthrieID']
#			out << line['SubjectID']
#			out << sample.sampleid
#			out << 'CCLS'
#			out << subject.sex
#			out << 'bg'
#			out << line['Book']
#			out << line['Page']
#			out << line['Pocket']
#			puts out.join(', ')
#			csv_out << out
#		end	#	CSV.open( 'Guthrie cards in
#		csv_out.close
#		puts "Commiting to Sunspot index."
#		Sunspot.commit
#	end	#	task :import_guthrie_card_inventory 


	#	20130321
	#	Loop over guthrie card inventory and confirm that any samples with an 
	#	external_id equal to the given GuthrieID belong to the given Subject.
	task :check_guthrie_card_inventory => :environment do
		raise "This task has been disabled."
		(i=CSV.open( 'anand/Guthrie cards inventory 02_05_13-APC CHECKED- for import.csv', 
				'rb',{ :headers => true })).each do |line|
			# "SubjectID","GuthrieID","Book","Page","Pocket"
			subject = StudySubject.with_subjectid(line['SubjectID']).first
			raise "No subject found with #{line['SubjectID']}" if subject.nil?
			samples = Sample.where(:external_id => line['GuthrieID'])
			if samples.empty?
				puts "No samples with guthrieid #{line['GuthrieID']}"
			else
				samples.each do |sample|
					puts "Found sample with guthrieid #{line['GuthrieID']}"
					if sample.study_subject_id == subject.id
						puts "Sample and Subject match"
					else
						puts "WARNING ..... Sample and Subject DO NOT match"
					end
				end
			end
		end	#	CSV.open
	end	#	task :check_guthrie_card_inventory


	#	20130313
	task :add_sample_external_ids_to_csv => :environment do
		raise "This task has been disabled."
		f=CSV.open('anand/subjects_with_blood_spot.csv', 'rb')
		in_columns = f.gets
		f.close
		CSV.open('anand/subjects_with_blood_spot_and_external_ids.csv','w') do |csv_out|
			csv_out << in_columns + ['external_ids']
			(i=CSV.open( 'anand/subjects_with_blood_spot.csv', 
					'rb',{ :headers => true })).each do |line|
				out = in_columns.collect{|c| line[c] }
				subject = StudySubject.with_subjectid(line['subjectid']).first
				external_ids = subject.samples.where(:sample_type_id => 16).where("external_id LIKE '%G'").collect(&:external_id).compact.join(', ')
				external_ids = nil if external_ids.blank?
				out << external_ids
				puts out
				csv_out << out
			end
		end
	end	#	task :add_sample_external_ids_to_csv => :environment do

end
