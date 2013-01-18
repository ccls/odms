require 'csv'
namespace :automate do

	task :import_screening_data => :environment do

		local_bc_info_dir = 'bc_infos'





#
#		Here is where problems begin.
#		The first bc_info files had 41 columns.
#		The latest have been simplified and have only 25.
#		Good luck.
#




		expected_columns = %w(icf_master_id mom_is_biomom dad_is_biodad
			date mother_first_name mother_last_name new_mother_first_name
			new_mother_last_name mother_maiden_name new_mother_maiden_name
			father_first_name father_last_name new_father_first_name
			new_father_last_name first_name middle_name last_name
			new_first_name new_middle_name new_last_name dob
			new_dob dob_month new_dob_month dob_day
			new_dob_day dob_year new_dob_year sex
			new_sex birth_country birth_state birth_city
			mother_hispanicity mother_hispanicity_mex mother_race other_mother_race
			father_hispanicity father_hispanicity_mex father_race other_father_race)

		Dir["#{local_bc_info_dir}/bc_info*csv"].each do |bc_info_file|

			puts bc_info_file

			f=CSV.open(bc_info_file,'rb')
			actual_columns = f.readline
			f.close

			if actual_columns.sort != expected_columns.sort
#				Notification.plain(
				puts (
					"BC Info has unexpected column names<br/>\n" <<
					"Expected ...<br/>\n#{expected_columns.join(',')}<br/>\n" <<
					"Actual   ...<br/>\n#{actual_columns.join(',')}<br/>\n" <<
					"Diffs    ...<br/>\n#{(expected_columns - actual_columns).join(',')}<br/>\n"
				).inspect
#, {
##:to => 'jakewendt@berkeley.edu',
#						:subject => "ODMS: Unexpected or missing columns in ICF Master Tracker" }
#				).deliver
				abort( "Unexpected column names in ICF Master Tracker" )

			else

				puts " - Columns are kosher"

			end	#	if actual_columns.sort != expected_columns.sort




			

			puts "Processing #{bc_info_file}..."
			changed = []
			(f=CSV.open( bc_info_file, 'rb',{
					:headers => true })).each do |line|
				puts
				puts "Processing line :#{f.lineno}:"
				puts line
	
	
				if line['icf_master_id'].blank?
					#	raise "master_id is blank" 
					puts "icf_master_id is blank" 
					next
				end
				subjects = StudySubject.where(:icf_master_id => line['icf_master_id'])
	
				#	Shouldn't be possible as icf_master_id is unique in the db
				#raise "Multiple case subjects? with icf_master_id:" <<
				#	"#{line['icf_master_id']}:" if subjects.length > 1
				unless subjects.length == 1
					#raise "No subject with icf_master_id: #{line['icf_master_id']}:" 
					puts "No subject with icf_master_id:#{line['icf_master_id']}:" 
					next
				end
	
				s = subjects.first
				e = s.enrollments.where(:project_id => Project['ccls'].id).first























	
	
			end	#	(f=CSV.open( bc_info_file, 'rb',{







		end	#	Dir["#{local_bc_info_dir}/bc_info*csv"].each do |bc_info_file|

	end	#	task :import_screening_data => :environment do

end
__END__
class ScreeningDatum < ActiveRecord::Base
#
#	belongs_to :screening_datum_update
#	attr_protected :screening_datum_update_id, :screening_datum_update
#	belongs_to :study_subject
#	attr_protected :study_subject_id, :study_subject
#
#	has_many :odms_exceptions, :as => :exceptable
#
#	after_create :post_processing
#
#	def post_processing
#		if icf_master_id.blank?
#			odms_exceptions.create(:name => 'screening data append',
#				:description => "icf_master_id blank")
#		else
#			#	DO NOT USE 'study_subject' here as it will conflict with
#			#	the study_subject association.
#			subject = StudySubject.where(:icf_master_id => icf_master_id).first
#			if subject.nil?
#				odms_exceptions.create(:name => 'screening data append',
#					:description => "No subject found with icf_master_id :#{icf_master_id}:")
#			else
#				#	assign study_subject_id to case's id
#				self.update_column(:study_subject_id, subject.id)
#				self.update_study_subject_attributes
#				subject.operational_events.create(
#					:occurred_at => date || DateTime.now,
#					:project_id  => Project['ccls'].id,
#					:operational_event_type_id => OperationalEventType['screener_complete'].id,
#					:description => "ICF screening complete" )
#			end
#		end
#	end	#	def post_processing
#
#	#
#	#	Separated this out so that can do separately if needed.
#	#
#	def update_study_subject_attributes
#		return if icf_master_id.blank?
#
#		#	If subject is created after this record (this would be odd)
#		#	then study subject isn't set.  Regardless, check if its
#		#	set.  If not, try to set it.  If can't, go away.
#		unless study_subject
#			subject = StudySubject.where(:icf_master_id => icf_master_id).first
#			return if subject.nil?
#			self.update_column(:study_subject_id, subject.id)
#		end
#
#		%w( dob sex father_first_name father_last_name 
#			mother_first_name mother_last_name mother_maiden_name
#			first_name middle_name last_name ).each do |field|
#
#			current, updated = if( field == 'dob' )
#				[study_subject.send(field), self.send("new_#{field}")]
#			else
#				[study_subject.send(field).to_s,
#					self.send("new_#{field}").to_s.squish.namerize]
#			end
#
#			if !updated.blank? and ( current != updated )
##
##	It will be database heavy, but perhaps update the database for each attribute
##	This way I can tell when the failure occurs and deal with it more appropriately?
##
##				study_subject.send("#{field}=", updated)
#				if study_subject.update_attributes(field => updated)
#					study_subject.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['datachanged'].id,
#						:description => "ICF Screening data change:  " <<
#							"The value in #{field} has changed from " <<
#							"\"#{current}\" to \"#{updated}\"" )
#				else
#
#
#
##	TODO do something to show failure
#
#
##				odms_exceptions.create(
##					:name        => 'screening data update',
##					:description => "Error updating study subject. " <<
##													"Save failed! " <<
##													study_subject.errors.full_messages.to_sentence) 
#
#
##	study_subject.reload		#	if don't, won't ever save as bad attribute still there
#
#
#
#				end
#			end
#
#		end
#
##  section 3 has fields which we won't already have since this is their point of origin. Any values in those columns can be updated without comparison to the existing record.
#
#		%w( mother_race father_race ).each do |field|
#			unless self.send(field).blank?	#	IS BLANK OK?  UNKNOWN ALWAYS SEEMS POSSIBLE
#				if( race = Race.where(:id => self.send(field)).first )
##					study_subject.send("#{field}_id=", race.id)
#					if study_subject.update_attributes("#{field}_id" => race.id)
#
##						study_subject.operational_events.create(
##							:occurred_at => DateTime.now,
##							:project_id => Project['ccls'].id,
##							:operational_event_type_id => OperationalEventType['datachanged'].id,
##							:description => "ICF Screening data change:  " <<
##								"The value in #{field} has changed from " <<
##								"\"#{current}\" to \"#{updated}\"" )
#					else
#
#
#
#
##	FAILURE
#
#
#
#
#					end
#				else
#					study_subject.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['dataconflict'].id,
#						:description => "ICF screening data conflict:  " <<
#							"#{field} does not match CCLS designations.    " <<
#							"Value = #{self.send(field)}" )
#				end
#			end
#		end
#
#		%w( mother_hispanicity father_hispanicity ).each do |field|
#			unless self.send(field).blank?	#	IS BLANK OK?  UNKNOWN ALWAYS SEEMS POSSIBLE
##				if( race = Race.where(:id => self.send(field)).first )
##					study_subject.send("#{field}_id=", race.id)
#				if( self.send(field) != 0 )
##					study_subject.send("#{field}_id=", self.send(field) )
#					if study_subject.update_attributes("#{field}_id" => self.send(field) )
#
#
#
#
#
#					else
#
#
#
##	FAILURE
#
#
#
#					end
#				else
#					study_subject.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['dataconflict'].id,
#						:description => "ICF screening data conflict:  " <<
#							"#{field} does not match CCLS designations.    " <<
#							"Value = #{self.send(field)}" )
#				end
#			end
#		end
#	end
#
end
