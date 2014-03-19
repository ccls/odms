require 'csv'

#class Object
#	def send_chain(chain)
#		links = chain.split('.')
#		x = self.send(links.shift)
#		if links.empty? || x.nil?
#			x
#		else
#			x.send_chain(links.join('.')) 
#		end
#	end
#end

namespace :app do
namespace :birth_data do

	task :id_number_report => :environment do
		cols = %w(id study_subject_id birth_data_file_name state_registrar_no derived_state_file_no_last6 derived_local_file_no_last6)
		puts (cols+%w(state_first_then_local state_last_after_unknown)).join(',')
		BirthDatum.find_each do |bd|
			values = cols.collect do |col|
				bd.send(col)
			end

			statefirst = sprintf("%d", "#{bd.derived_state_file_no_last6}#{bd.derived_local_file_no_last6}".to_i)
			values.push ( ( bd.state_registrar_no.to_s.length > 6 && bd.state_registrar_no == statefirst ) ? 'TRUE' : '-' )
			values.push ( ( bd.state_registrar_no.to_s.length > 6 && bd.state_registrar_no.to_s[-6..-1] == bd.derived_state_file_no_last6 ) ? 'TRUE' : '-' )

			puts values.join(',')
		end
	end	#	task :id_number_report => :environment do

	task :check_state_registrar_no => :environment do
		puts BirthDatum.count
		puts "state_registrar_no,derived_state_file_no_last6,derived_local_file_no_last6"
		counts = BirthDatum.all.to_a.inject(Hash.new(0)){|h,bd| 
			statefirst = sprintf("%d", "#{bd.derived_state_file_no_last6}#{bd.derived_local_file_no_last6}".to_i)
			localfirst = sprintf("%d", "#{bd.derived_local_file_no_last6}#{bd.derived_state_file_no_last6}".to_i)
			if( bd.state_registrar_no.blank? )
				h[:state_registrar_no_blank] += 1
			elsif( bd.derived_state_file_no_last6.blank? )
				h[:derived_state_file_no_last6_blank] += 1
			elsif( bd.derived_local_file_no_last6.blank? )
				h[:derived_local_file_no_last6_blank] += 1
			elsif( bd.state_registrar_no == statefirst )
				h[:state_first_then_local]+=1
			elsif( bd.state_registrar_no == localfirst )
				h[:local_first_then_state]+=1
			elsif( bd.state_registrar_no[-6..-1] == bd.derived_state_file_no_last6 )
				h[:state_last]+=1
			else
				h[:confused]+=1
				puts "#{bd.state_registrar_no}, #{bd.derived_state_file_no_last6}, #{bd.derived_local_file_no_last6}"
			end

			if( bd.study_subject.blank? )
				h[:study_subject_blank] +=1
			elsif( bd.study_subject.state_id_no.blank? )
				h[:study_subject_state_id_no_blank] +=1
			elsif( bd.study_subject.birth_year.blank? )
				h[:study_subject_birth_year_blank] +=1
			elsif( bd.study_subject.state_id_no == "#{bc.study_subject.birth_year}-#{bd.state_registrar_no}" )
				h["state_id_no_=_state_registrar_no"] +=1
			else
				h["state_id_no_!=_state_registrar_no"] +=1
			end

			h	#	must return the modified hash
		}
		puts counts
	end	#	task :check_state_registrar_no => :environment do


	task :reprocess_birth_data => :environment do
		puts "Study Subject count: #{StudySubject.count}"
#		birth_data = BirthDatum.where(:match_confidence => 'NO').where(:study_subject_id => nil)
		birth_data = BirthDatum.where(:study_subject_id => nil)
			.where(BirthDatum.arel_table[:match_confidence].eq_any(['NO','DEFINITE']))
		birth_data.each{|bd| 
			puts "Processing #{bd}"
			bd.post_processing; bd.reload }
		puts "Study Subject count: #{StudySubject.count}"

		puts; puts "Commiting changes to Sunspot"
		Sunspot.commit

		Notification.updates_from_birth_data( 'fake file', birth_data ).deliver

		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :reprocess_birth_data => :environment do

	task :update_file_nos => :environment do
		raise "This task has been disabled."
		csv_file = "Ca_Co_6_Digit_State_Local.csv"
		raise "CSV File :#{csv_file}: not found" unless File.exists?(csv_file)
		not_found = []
		CSV.open(csv_file,'rb:bom|utf-8', { :headers => true }).each do |line|
			#	master_id,match_confidence,case_control_flag,state_registrar_no,derived_state_file_no_last6,control_number,
			#	dob,last_name,first_name,middle_name,local_registrar_no,derived_local_file_no_last6
			#
			#	If created an actual birth datum record for a control, it would create a control. 
			#	These controls have already been created.
			#	So.  Create one WITHOUT a master_id, which will stop the post_processing.
			#	Basically, create a blank one.
			#	Manually find by state_registrar_no?  and attach study subject
			#	add derived_local_file_no_last6 and derived_state_file_no_last6
			#
			puts line['state_registrar_no']
			next if line['state_registrar_no'].blank?

			birth_data = BirthDatum.where(:state_registrar_no => line['state_registrar_no'] )
			if birth_data.length == 0
				puts "Found #{birth_data.length} subjects matching" 
				not_found.push line
				next
			end

			birth_data.each do |birth_datum| 
				derived_state_file_no_last6 = sprintf("%06d",line['derived_state_file_no_last6'].to_i)
				birth_datum.update_column(:derived_state_file_no_last6, derived_state_file_no_last6)

				derived_local_file_no_last6 = sprintf("%06d",line['derived_local_file_no_last6'].to_i)
				birth_datum.update_column(:derived_local_file_no_last6, derived_local_file_no_last6)

				if birth_datum.study_subject

					birth_datum.study_subject.update_column(:needs_reindexed, true)

					birth_datum.study_subject.operational_events.create(
						:occurred_at => DateTime.current,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
						:description => "Birth Record data changes from #{csv_file}",
						:notes => "Added derived_state_file_no_last6 #{derived_state_file_no_last6} and "<<
							"derived_local_file_no_last6 #{derived_local_file_no_last6} to birth data records.")

				end
			end
		end
		puts "#{not_found.length} state registrar nos not found."
		puts not_found
	end

	task :import_birth_data => :environment do

		puts;puts;puts
		puts "Begin.(#{Time.now})"
		puts "In app:birth_data:import_birth_data"

		local_birth_data_dir = 'birth_data'
		FileUtils.mkdir_p(local_birth_data_dir) unless File.exists?(local_birth_data_dir)


#
#	Where are the birth data files?
#	Naming convention?
#

#		puts "About to scp -p birth_data files"
#	S:\CCLS\FieldOperations\ICF\DataTransfers\USC_control_matches\Birth_Certificate_Match_Files
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/ICF_birth_data/birth_data_*.csv ./#{local_birth_data_dir}/")
#		system("scp -p jakewendt@dev.sph.berkeley.edu:/Users/jakewendt/Mounts/SharedFiles/CCLS/FieldOperations/ICF/DataTransfers/USC_control_matches/birth_data_*.csv ./#{local_birth_data_dir}/")
	
		Dir.chdir( local_birth_data_dir )
		birth_data_files = Dir["*.csv"]

		unless birth_data_files.empty?

			birth_data_files.each do |birth_data_file|

				bdu = BirthDatumUpdate.new(birth_data_file,:verbose => true)
				bdu.archive

			end	#	birth_data_files.each do |birth_data_file|
	
			puts; puts "Commiting changes to Sunspot"
			Sunspot.commit

		else	#	unless birth_data_files.empty?
			puts "No birth_data files found"
			Notification.plain("No Birth Data Files Found",
					:subject => "ODMS: No Birth Data Files Found"
			).deliver
		end	#	unless birth_data_files.empty?
		puts; puts "Done.(#{Time.now})"
		puts "----------------------------------------------------------------------"

	end	#	task :import_birth_data => :environment do

#	task :import_birth_data_files => :import_birth_data
#	task :import_birth_data_update_files => :import_birth_data
#	task :import_birth_datum_files => :import_birth_data
#	task :import_birth_datum_update_files => :import_birth_data

end	#	namespace :birth_data do
end	#	namespace :app do

__END__
