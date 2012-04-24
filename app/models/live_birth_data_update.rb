class LiveBirthDataUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(File.dirname(__FILE__),'../..','config/live_birth_data_update.yml')
		))).result)[Rails.env]

	validates_attachment_presence     :csv_file

	validates_inclusion_of :csv_file_content_type,
		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
		:allow_blank => true

#	perhaps by file extension rather than mime type?
#	validates_format_of :csv_file_file_name,
#		:with => %r{\.csv$}i,
#		:allow_blank => true

	validate :valid_csv_file_column_names

	def valid_csv_file_column_names
		#	'to_file' needed as the path method wouldn't be
		#	defined until after save.
		if self.csv_file && self.csv_file.to_file
			f=FasterCSV.open(self.csv_file.to_file.path,'rb')
			column_names = f.readline
			f.close
			if column_names != expected_column_names 
				errors.add(:csv_file, "Invalid column names in csv_file.")
			end
		end
	end



#
#	to_candidate_controls is being deprecated in favor of parse.
#
#	most of the column names have changed
#
#	the icf_master_tracker uses a unique icf_master_id.
#	the birth data doesn't have the icf_master_id so
#		which column is the unique defining column?
#		state_id_no or something
#
#	def parse
#		results = []
#		if !self.csv_file_file_name.blank? &&
#				File.exists?(self.csv_file.path)
#			(f=FasterCSV.open( self.csv_file.path, 'rb',{
#				:headers => true })).each do |line|
#
##				icf_master_tracker = IcfMasterTracker.find_or_create_by_master_id(
##					line['master_id'],
##					:master_tracker_date => self.master_tracker_date )
#
#				successfully_updated = birth_data.update_attributes!(
#					line.to_hash.delete_keys!(
##						'master_id').merge(
##						:master_tracker_date => self.master_tracker_date) )
#
#				results.push(birth_data)
#			end	#	(f=FasterCSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
#		end	#	if !self.csv_file_file_name.blank? && File.exists?(self.csv_file.path)
#		results	#	TODO why am I returning anything?  will I use this later?
#	end	#	def parse








	def to_candidate_controls
		results = []
		if !self.csv_file_file_name.blank? &&
				File.exists?(self.csv_file.path)
			(f=FasterCSV.open( self.csv_file.path, 'rb',{
				:headers => true })).each do |line|

#	masterid,ca_co_status,biomom,biodad,date,mother_full_name,mother_maiden_name,father_full_name,child_full_name,child_dobm,child_dobd,child_doby,child_gender,birthplace_country,birthplace_state,birthplace_city,mother_hispanicity,mother_hispanicity_mex,mother_race,mother_race_other,father_hispanicity,father_hispanicity_mex,father_race,father_race_other

				if line['ca_co_status'] == 'case'
					study_subject = StudySubject.where(:icf_master_id => line['masterid']).first
					if study_subject
						results.push(study_subject)
					else
						results.push("Could not find study_subject with masterid #{line['masterid']}")
						next
					end
				elsif line['ca_co_status'] == 'control'
					study_subject = StudySubject.where(:icf_master_id => line['masterid']).first
					unless study_subject
						results.push("Could not find study_subject with masterid #{line['masterid']}")
						next
					end

					dob = unless( 
							line['child_doby'].blank? || 
							line['child_dobm'].blank? ||
							line['child_dobd'].blank? )
						Date.new(
							line['child_doby'].to_i, 
							line['child_dobm'].to_i, 
							line['child_dobd'].to_i)
					else
						nil
					end
					child_names  = line["child_full_name"].to_s.split_name
					father_names = line["father_full_name"].to_s.split_name
					mother_names = line["mother_full_name"].to_s.split_name
#
#	incoming data may be strings, but 
#		nil DOES NOT EQUAL "" for integer comparison
#	so MUST nilify blank integer fields or will never find
#	the record and will create duplicates every time.
#
#					biomom = ( ( line["biomom"].blank? ) ? nil : line["biomom"] )
#					biodad = ( ( line["biodad"].blank? ) ? nil : line["biodad"] )
#					mother_hispanicity = ( (line["mother_hispanicity"].blank? ) ?
#						nil : line["mother_hispanicity"] )
#					mother_race = ( (line["mother_race"].blank? ) ?
#						nil : line["mother_race"] )
#					father_hispanicity = ( (line["father_hispanicity"].blank? ) ?
#						nil : line["father_hispanicity"] )
#					father_race = ( (line["father_race"].blank? ) ?
#						nil : line["father_race"] )

					candidate_control_options = {
#						:related_patid => identifier.patid,
						:related_patid => study_subject.patid,
						:mom_is_biomom => line["biomom"].nilify_blank,
						:dad_is_biodad => line["biodad"].nilify_blank,
#"date":nil 	#	some event's occurred on
						:first_name  => child_names[0],
						:middle_name => child_names[1],
						:last_name   => child_names[2],
#						:father_first_name  => father_names[0],	#	doesn't exist
#						:father_middle_name => father_names[1],	#	doesn't exist
#						:father_last_name   => father_names[2],	#	doesn't exist
						:mother_first_name  => mother_names[0],
						:mother_middle_name => mother_names[1],
						:mother_last_name   => mother_names[2],
						:mother_maiden_name => line["mother_maiden_name"],
						:dob => dob,
						:sex => line["child_gender"],
#"birthplace_country":"United States" 	#	doesn't exist
#"birthplace_state":"CA" 	#	doesn't exist
#"birthplace_city":"Oakland" 	#	doesn't exist
						:mother_hispanicity_id => line["mother_hispanicity"].nilify_blank,
#"mother_hispanicity_mex":"2" 	#	doesn't exist
						:mother_race_id => line["mother_race"].nilify_blank,
#"other_mother_race":nil 	#	doesn't exist
						:father_hispanicity_id => line["father_hispanicity"].nilify_blank,
#"father_hispanicity_mex":"2" 	#	doesn't exist
						:father_race_id => line["father_race"].nilify_blank
#"other_father_race":nil	#	doesn't exist
					}
#					candidate_control = CandidateControl.find(:first,
#						:conditions => candidate_control_options )
					candidate_control = CandidateControl.where(candidate_control_options
						).first

					if candidate_control.nil?
						candidate_control = CandidateControl.create( candidate_control_options )
						#	TODO what if there's an error?
					end
#					unless candidate_control.new_record?
#						results.push(candidate_control.id)
#					end
					results.push(candidate_control)

				else
					results.push("Unexpected ca_co_status :#{line['ca_co_status']}:")
				end	#	elsif line['ca_co_status'] == 'control'
			end	#	(f=FasterCSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
		end	#	if !self.csv_file_file_name.blank? && File.exists?(self.csv_file.path)
		results	#	TODO why am I returning anything?  will I use this later?
	end	#	def to_candidate_controls

	def self.expected_column_names
		["masterid", "ca_co_status", "biomom", "biodad", "date", "mother_full_name", "mother_maiden_name", "father_full_name", "child_full_name", "child_dobm", "child_dobd", "child_doby", "child_gender", "birthplace_country", "birthplace_state", "birthplace_city", "mother_hispanicity", "mother_hispanicity_mex", "mother_race", "mother_race_other", "father_hispanicity", "father_hispanicity_mex", "father_race", "father_race_other"]
	end

	def expected_column_names
		LiveBirthDataUpdate.expected_column_names
	end

end


#	Probably better to move this somewhere more appropriate
#	Perhaps CommonLib::StringExtension
#	Trying to get actual names from hospital, so, hopefully,
#	this won't be needed.

String.class_eval do

	def split_name
		#	Really only want to split on spaces so just remove the problem chars.
		#	May have to add others later.
		names  = self.gsub(/\240/,' ').split
		first  = names.shift.to_s.squish
		last   = names.pop.to_s.squish
		middle = names.join(' ').squish
		[first,middle,last]
	end

end

#	Object and not String because could be NilClass
Object.class_eval do

	def nilify_blank
		( self.blank? ) ? nil : self
	end

end
