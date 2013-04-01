require 'csv'

#
#	One-off tasks written for Anand
#
namespace :anand do

	#	20130401
	task :verify_cdcid_childid_sample_link => :environment do
		error_file = File.open('2010-12-06_MaternalBiospecimenIDLink.txt','w')
		childid_cdcid = HWIA.new
		(i=CSV.open( '2010-12-06_MaternalBiospecimenIDLink.csv',
				'rb',{ :headers => true })).each do |line|
			childid_cdcid[line['CHILDID']] = line['CDC_ID']
		end
		childid_cdcid.each do |childid, cdcid|
			cdcid = sprintf('%04d',cdcid.to_i)
			puts "Checking childid #{childid} against cdcid #{cdcid}"
			samples = Sample.where(
				Sample.arel_table[:external_id].matches("05-57-#{cdcid}%") )
			samples.each do |sample|
				puts "DB:#{sample.study_subject.child.childid} CSV:#{childid}"
				unless ( sample.study_subject.child.childid == childid.to_i )
					error_file.puts "Childid Mismatch"
					error_file.puts "CDC ID #{cdcid}"
					error_file.puts "DB:#{sample.study_subject.child.childid} CSV:#{childid}"
					error_file.puts
				end
			end
		end
		error_file.close
	end

	#	20130401
	task :verify_cdc_biospecimens_inventory_not_on_gegl_manifest => :environment do
		childid_cdcid = HWIA.new
		(i=CSV.open( '2010-12-06_MaternalBiospecimenIDLink.csv',
				'rb',{ :headers => true })).each do |line|
			childid_cdcid[line['CHILDID']] = line['CDC_ID']
		end
		(i=CSV.open( '20111114_CDC_UrinePlasmaRBC_SampleInventory.NotOnGeglManifest.csv',
				'rb',{ :headers => true })).each do |line|
			#	,"DLSSampleID","AstroID","smp_type","Box","Group","Pos","Amount (mL)",
			#		"Amount Full","Container","Sample Type"
			#1,"05-57-0042-R1","0019UJNP","RBC",,"NCCLS07C11",1,0.75,,"2.0 mL cryo","R1 RBC Folate"
			#	DLSSampleID ... external_id

#			sample = Sample.where(:external_id => line['DLSSampleID']).first
#			sample = Sample.where(:external_id => line['DLSSampleID'].gsub(/-??$/,'')).first
external_id = line['DLSSampleID'].gsub(/-..$/,'%')
#external_id = line['DLSSampleID'].gsub(/-R1$/,'-P1')
#puts external_id
			samples = Sample.where(
				Sample.arel_table[:external_id].matches(external_id) )
			if samples.empty?
				raise "No sample found with external_id #{line['DLSSampleID']}" 
			else
				puts "-- sample found with external_id #{line['DLSSampleID']}" 
				puts samples.collect(&:external_id)
			end
			#
			#	none exist
			#
		end
	end

	#	20130328
	task :verify_cdc_biospecimens_inventory => :environment do
		error_file = File.open('20111114_CDC_UrinePlasmaRBC_SampleInventory.txt','w')
#		typesfile = File.open('20111114_CDC_UrinePlasmaRBC_SampleInventory.types.txt','w')
		(i=CSV.open( '20111114_CDC_UrinePlasmaRBC_SampleInventory.csv',
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

#			typesfile.puts sample.sample_type_id

#			if sample.sample_type.gegl_sample_type_id != line['type']
#				error_file.puts i.lineno
#				error_file.puts line
#				error_file.puts "Type Mismatch"
#				error_file.puts "Types: DB: #{sample.sample_type.gegl_sample_type_id}" <<
#												" CSV: #{line['type']}"
#				error_file.puts
#			end

			if sample.study_subject.sex != line['sex'].upcase
				error_file.puts i.lineno
				error_file.puts line
				error_file.puts "Sex Mismatch"
				error_file.puts "Sex: DB: #{sample.study_subject.sex} CSV: #{line['sex']}"
				error_file.puts
			end

		end	#	CSV.open
		error_file.close
#		typesfile.close
	end	#	task :check_maternal_biospecimens_inventory

	#
	#	20130321
	#
	task :check_maternal_biospecimens_inventory => :environment do
		(i=CSV.open( 'CDC Maternal Inventory 11_10_08.csv', 
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
#
#			sample = Sample.where(:external_id => line['GuthrieID']).first
#
#			unless sample.nil?
#				puts "Found sample with guthrieid #{line['GuthrieID']}"
#				if sample.study_subject_id == subject.id
#					puts "Sample and Subject match"
#				else
#					puts "WARNING ..... Sample and Subject DO NOT match"
#				end
#			end

		end	#	CSV.open
	end	#	task :check_maternal_biospecimens_inventory

	#
	#	20130321 - STILL IN DEVELOPMENT
	#
	task :import_guthrie_card_inventory => :environment do
		CSV.open('Guthrie_card_inventory_out.csv','w') do |csv_out|
			csv_out << %w(
				guthrieid subjectid sampleid projectid gender smp_type book page pocket
			)
			(i=CSV.open( 'Guthrie cards inventory 02_05_13-APC CHECKED- for import.csv', 
					'rb',{ :headers => true })).each do |line|
				#
				# "SubjectID","GuthrieID","Book","Page","Pocket"
				#
				out = []
				subject = StudySubject.with_subjectid(line['SubjectID']).first
				raise "No subject found with #{line['SubjectID']}" if subject.nil?

				#
				#	Create Sample and get sampleid
				#		sample_type = Blood Spot ( id: 16 ... archive newborn blood )
				#		external_id_source = 'Guthrie' ( perhaps with book, page and pocket? )
				#		external_id = line['GuthrieID']
				#	

#				sample = Sample.where(:external_id => line['GuthrieID']).first
#
#				unless sample.nil?
#					puts "Found sample with guthrieid #{line['GuthrieID']}"
#					if sample.study_subject_id == subject.id
#						puts "Sample and Subject match"
#					else
#						puts "WARNING ..... Sample and Subject DO NOT match"
#					end
#				end
	
#				sample = subject.samples.new(
#					:project_id => Project[:ccls].id,
#					:sample_type_id => 16,
#					:external_id_source => "Guthrie",
#					:external_id => line['GuthrieID'])
#
#				out << line['GuthrieID']
#				out << line['SubjectID']
#				out << '1234567'					#	new sample's sampleid
#				out << 'CCLS'
#				out << subject.sex
#				out << 'bg'
#				out << line['Book']
#				out << line['Page']
#				out << line['Pocket']
#		
#				puts out.join(', ')
#				csv_out << out
			end	#	(i=CSV.open( 'Guthrie cards in
		end	#	CSV.open('Guthrie_card_inventory_out.csv','w') do |csv_out|
	end	#	task :import_guthrie_card_inventory 

	#
	#	20130321
	#
	task :check_guthrie_card_inventory => :environment do
		(i=CSV.open( 'Guthrie cards inventory 02_05_13-APC CHECKED- for import.csv', 
				'rb',{ :headers => true })).each do |line|
			#
			# "SubjectID","GuthrieID","Book","Page","Pocket"
			#
			subject = StudySubject.with_subjectid(line['SubjectID']).first
			raise "No subject found with #{line['SubjectID']}" if subject.nil?

			sample = Sample.where(:external_id => line['GuthrieID']).first

			unless sample.nil?
				puts "Found sample with guthrieid #{line['GuthrieID']}"
				if sample.study_subject_id == subject.id
					puts "Sample and Subject match"
				else
					puts "WARNING ..... Sample and Subject DO NOT match"
				end
			end

		end	#	CSV.open
	end	#	task :check_guthrie_card_inventory

	#
	#	20130313
	#
	task :add_sample_external_ids_to_csv => :environment do

		f=CSV.open('subjects_with_blood_spot.csv', 'rb')
		in_columns = f.gets
		f.close
		
		CSV.open('subjects_with_blood_spot_and_external_ids.csv','w') do |csv_out|
			csv_out << in_columns + ['external_ids']
			(i=CSV.open( 'subjects_with_blood_spot.csv', 'rb',{ :headers => true })).each do |line|
		
				out = in_columns.collect{|c| line[c] }
		
				subject = StudySubject.where(:subjectid => line['subjectid']).first
		
				external_ids = subject.samples.where(:sample_type_id => 16).where("external_id LIKE '%G'").collect(&:external_id).compact.join(', ')
#	This would work also as an underscore, _ , is a single char wildcard.
#				external_ids = subject.samples.where(:sample_type_id => 16)
#					.where(Sample.arel_table[:external_id].matches('____G'))
#					.collect(&:external_id).compact.join(', ')
				external_ids = nil if external_ids.blank?
		
				out << external_ids
		
				puts out
				csv_out << out
		
			end
		end

	end

end
