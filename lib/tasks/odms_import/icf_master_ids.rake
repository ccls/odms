require 'tasks/odms_import/base'

namespace :odms_import do

	desc "Import data from icf master ids csv file"
	task :icf_master_ids => :odms_import_base do 
		puts "Destroying icf_master_ids"
		IcfMasterId.destroy_all
		puts "Importing icf_master_ids"

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open(ICFMASTERIDS_CSV, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line

			raise "Given icf_master_id is blank?" if line['icf_master_id'].blank?

			#	by block to avoid protected attributes (study_subject_id)
			icf_master_id = IcfMasterId.new do |imi|
				imi.icf_master_id = line['icf_master_id']

				if line['subjectid'] and !line['subjectid'].blank?
#					study_subjects = StudySubject.find(:all,
#						:conditions => { :subjectid => line['subjectid'] } )
					study_subjects = StudySubject.where(:subjectid => line['subjectid'])
					case 
						#
						#	subjectid is unique so this should NEVER happen
						#
						when study_subjects.length > 1
							raise "More than one study_subject found matching subjectid" <<
								":#{line['subjectid']}:"
						when study_subjects.length == 0
							raise "No study_subject found matching subjectid:#{line['subjectid']}:"
						else
							puts "Found study_subject matching subjectid:#{line['subjectid']}:"
					end
					study_subject = study_subjects.first
	
					#	Fortunately, these never happen
					if study_subject.icf_master_id.blank?
						#	assign it?
						raise "ICF Master ID isn't actually set in the StudySubject!"
					else
						#	different?
						if study_subject.icf_master_id != line['icf_master_id']
							raise "ICF Master ID is different than that set in the StudySubject!\n" <<
								"#{study_subject.icf_master_id}:#{line['icf_master_id']}"
						end
					end
					imi.study_subject_id = study_subject.id
					imi.assigned_on = Time.parse(line['assigned_on'])

				else
					#	I just noticed that some of the icf_master_ids are actually
					#	assigned in the subject data, but not marked as being
					#	assigned in the icf_master_id list.  So, search for them.
#					study_subjects = StudySubject.find(:all,
#						:conditions => { :icf_master_id => line['icf_master_id'] } )
					study_subjects = StudySubject.where(:icf_master_id => line['icf_master_id'])
					case 
						#
						#	icf_master_id is unique, so should NEVER find more than 1 unless it is nil.
						#
						when study_subjects.length > 1
							raise "More than one study_subject found matching "<<
								"icf_master_id:#{line['icf_master_id']}:"
#					when study_subjects.length == 0
#						raise "No study_subject found matching icf_master_id:#{line['icf_master_id']}:"
						when study_subjects.length == 1
							puts "Found study_subject matching icf_master_id:#{line['icf_master_id']}:"
							imi.study_subject_id = study_subjects.first.id
							imi.assigned_on = Date.today
					end
				end
			end	#	IcfMasterId.new do |imi|

			icf_master_id.save!
			assert icf_master_id.icf_master_id == line['icf_master_id'],
				"ICF Master ID mismatch"
		end	#	.each do |line|

	end

end
