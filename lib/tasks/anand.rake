require 'csv'

#
#	One-off tasks written for Anand
#
namespace :anand do

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
				subject = StudySubject.where(:subjectid => line['SubjectID']).first
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
			subject = StudySubject.where(:subjectid => line['SubjectID']).first
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
				external_ids = nil if external_ids.blank?
		
				out << external_ids
		
				puts out
				csv_out << out
		
			end
		end

	end

end
