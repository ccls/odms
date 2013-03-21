require 'csv'

#
#	One-off tasks written for Anand
#
namespace :anand do

	#
	#	20130321
	#
	task :check_guthrie_card_inventory => :environment do
		CSV.open('Guthrie_card_inventory_out.csv','w') do |csv_out|
			csv_out << %w(
				guthrieid subjectid sampleid projectid gender smp_type book page pocket
			)
			(i=CSV.open( 'Guthrie cards inventory 02_05_13-APC CHECKED- for import.csv', 
					'rb',{ :headers => true })).each do |line|
				out = []
				subject = StudySubject.where(:subjectid => line['SubjectID']).first
				raise "No subject found with #{line['SubjectID']}" if subject.nil?
#"SubjectID","GuthrieID","Book","Page","Pocket"

				out << line['GuthrieID']
				out << line['SubjectID']
				out << '1234567'
				out << 'CCLS'
				out << subject.sex
				out << 'g'
				out << line['Book']
				out << line['Page']
				out << line['Pocket']
		
		puts out
				csv_out << out
		
			end
		end
	end

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
