class BirthDatumUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(File.dirname(__FILE__),'../..','config/birth_datum_update.yml')
		))).result)[Rails.env]

	has_many :birth_data

	has_many :odms_exceptions, :as => :exceptable

	validates_attachment_presence     :csv_file

	validates_inclusion_of :csv_file_content_type,
		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
		:allow_blank => true

#	perhaps by file extension rather than mime type?
#	validates_format_of :csv_file_file_name,
#		:with => %r{\.csv$}i,
#		:allow_blank => true

	validate :valid_csv_file_column_names

	#	if only doing this after create,
	#	what happens on edit/update?
	#	probably don't want to allow that.
	after_create :parse_csv_file

	def valid_csv_file_column_names
		#	'to_file' needed as the path method wouldn't be
		#	defined until after save.
		if self.csv_file && self.csv_file.to_file
			f=FasterCSV.open(self.csv_file.to_file.path,'rb')
			column_names = f.readline
			f.close
			column_names.each do |column_name|
				errors.add(:csv_file, "Invalid column name '#{column_name}' in csv_file."
					) unless expected_column_names.include?(column_name)
			end
#
#	what about missing columns???
#
		end
	end

	def parse_csv_file
		unless self.csv_file_file_name.blank?
			csv_file_path = self.csv_file.to_file.path
#			csv_file_path = if File.exists?(self.csv_file.to_file.path)
#				self.csv_file.to_file.path
#			elsif File.exists?(self.csv_file.path)
##	this would only happen on an update.
##	after create will use the above "csv_file.to_file.path"
##		for some reason as file hasn't yet been saved.
##	"csv_file.to_file.path" works on existing models too, 
##		so perhaps its best to use it anyway
#				self.csv_file.path
#			else 
##	This should never happen as the csv_file is required.
#				nil
#			end
			unless csv_file_path.nil?
				line_count = 0
				(f=FasterCSV.open( csv_file_path, 'rb',{
						:headers => true })).each do |line|
					line_count += 1

					birth_datum_attributes = line.dup.to_hash
#	remove invalid attributes, if there are any
					birth_datum_attributes.delete('father_ssn')
					birth_datum_attributes.delete('mother_ssn')
					birth_datum_attributes.delete('ignore')
					birth_datum_attributes.delete('ignore1')
					birth_datum_attributes.delete('ignore2')
					birth_datum_attributes.delete('ignore3')

					birth_datum = self.birth_data.create( birth_datum_attributes )
					if birth_datum.new_record?
						odms_exceptions.create({
							:name        => "birth_data append",
							:description => "Record failed to save"
#
#	TODO which record?  include the actual line?  and the line number?
#
						})
#1.Any records that fail to append will be noted in the odms_exceptions table with an exception-specific error message (to be defined at the judgment of the programmer) as follows:
#b.description:  programmer-specified error (to include master_id or errant record) or “Error importing record into birth_data table.  Exception record master_id = xxxxxxxxx.”  or “Error importing record into birth_data table.  Exception record master_id not provided.”
#c.occurred_at: timestamp
					end	#	if birth_datum.new_record?
				end	#	(f=FasterCSV.open( self.csv_file.path, 'rb',{ :headers => true })).each

				if line_count != birth_data_count
					odms_exceptions.create({
						:name        => "birth_data append",
						:description => "Birth data upload validation failed: incorrect number of birth data records appended to birth_data."
					})
				end	#	if line_count != birth_data_count
			end	#	unless csv_file_path.nil?
		end	#	unless self.csv_file_file_name.blank?
	end	#	def parse_csv_file

	#	separated purely to allow stubbing in testing
	def birth_data_count
		birth_data.count
	end








#	def to_candidate_controls
#		results = []
#		if !self.csv_file_file_name.blank? &&
#				File.exists?(self.csv_file.path)
#			(f=FasterCSV.open( self.csv_file.path, 'rb',{
#				:headers => true })).each do |line|
#
##	masterid,ca_co_status,biomom,biodad,date,mother_full_name,mother_maiden_name,father_full_name,child_full_name,child_dobm,child_dobd,child_doby,child_gender,birthplace_country,birthplace_state,birthplace_city,mother_hispanicity,mother_hispanicity_mex,mother_race,mother_race_other,father_hispanicity,father_hispanicity_mex,father_race,father_race_other
#
#				if line['ca_co_status'] == 'case'
#					study_subject = StudySubject.where(:icf_master_id => line['masterid']).first
#					if study_subject
#						results.push(study_subject)
#					else
#						results.push("Could not find study_subject with masterid #{line['masterid']}")
#						next
#					end
#				elsif line['ca_co_status'] == 'control'
#					study_subject = StudySubject.where(:icf_master_id => line['masterid']).first
#					unless study_subject
#						results.push("Could not find study_subject with masterid #{line['masterid']}")
#						next
#					end
#
#					dob = unless( 
#							line['child_doby'].blank? || 
#							line['child_dobm'].blank? ||
#							line['child_dobd'].blank? )
#						Date.new(
#							line['child_doby'].to_i, 
#							line['child_dobm'].to_i, 
#							line['child_dobd'].to_i)
#					else
#						nil
#					end
#					child_names  = line["child_full_name"].to_s.split_name
#					father_names = line["father_full_name"].to_s.split_name
#					mother_names = line["mother_full_name"].to_s.split_name
##
##	incoming data may be strings, but 
##		nil DOES NOT EQUAL "" for integer comparison
##	so MUST nilify blank integer fields or will never find
##	the record and will create duplicates every time.
##
##					biomom = ( ( line["biomom"].blank? ) ? nil : line["biomom"] )
##					biodad = ( ( line["biodad"].blank? ) ? nil : line["biodad"] )
##					mother_hispanicity = ( (line["mother_hispanicity"].blank? ) ?
##						nil : line["mother_hispanicity"] )
##					mother_race = ( (line["mother_race"].blank? ) ?
##						nil : line["mother_race"] )
##					father_hispanicity = ( (line["father_hispanicity"].blank? ) ?
##						nil : line["father_hispanicity"] )
##					father_race = ( (line["father_race"].blank? ) ?
##						nil : line["father_race"] )
#
#					candidate_control_options = {
##						:related_patid => identifier.patid,
#						:related_patid => study_subject.patid,
#						:mom_is_biomom => line["biomom"].nilify_blank,
#						:dad_is_biodad => line["biodad"].nilify_blank,
##"date":nil 	#	some event's occurred on
#						:first_name  => child_names[0],
#						:middle_name => child_names[1],
#						:last_name   => child_names[2],
##						:father_first_name  => father_names[0],	#	doesn't exist
##						:father_middle_name => father_names[1],	#	doesn't exist
##						:father_last_name   => father_names[2],	#	doesn't exist
#						:mother_first_name  => mother_names[0],
#						:mother_middle_name => mother_names[1],
#						:mother_last_name   => mother_names[2],
#						:mother_maiden_name => line["mother_maiden_name"],
#						:dob => dob,
#						:sex => line["child_gender"],
##"birthplace_country":"United States" 	#	doesn't exist
##"birthplace_state":"CA" 	#	doesn't exist
##"birthplace_city":"Oakland" 	#	doesn't exist
#						:mother_hispanicity_id => line["mother_hispanicity"].nilify_blank,
##"mother_hispanicity_mex":"2" 	#	doesn't exist
#						:mother_race_id => line["mother_race"].nilify_blank,
##"other_mother_race":nil 	#	doesn't exist
#						:father_hispanicity_id => line["father_hispanicity"].nilify_blank,
##"father_hispanicity_mex":"2" 	#	doesn't exist
#						:father_race_id => line["father_race"].nilify_blank
##"other_father_race":nil	#	doesn't exist
#					}
##					candidate_control = CandidateControl.find(:first,
##						:conditions => candidate_control_options )
#					candidate_control = CandidateControl.where(candidate_control_options
#						).first
#
#					if candidate_control.nil?
#						candidate_control = CandidateControl.create( candidate_control_options )
#						#	TODO what if there's an error?
#					end
##					unless candidate_control.new_record?
##						results.push(candidate_control.id)
##					end
#					results.push(candidate_control)
#
#				else
#					results.push("Unexpected ca_co_status :#{line['ca_co_status']}:")
#				end	#	elsif line['ca_co_status'] == 'control'
#			end	#	(f=FasterCSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
#		end	#	if !self.csv_file_file_name.blank? && File.exists?(self.csv_file.path)
#		results	#	TODO why am I returning anything?  will I use this later?
#	end	#	def to_candidate_controls

	def self.expected_column_names
		%w( masterid found_in_state_db match_confidence case_control_flag birth_state sex dob ignore1 ignore2 ignore3 last_name first_name middle_name state_registrar_no county_of_delivery local_registrar_no local_registrar_district birth_type birth_order birth_weight_gms method_of_delivery abnormal_conditions apgar_1min apgar_5min apgar_10min complications_labor_delivery fetal_presentation_at_birth forceps_attempt_unsuccessful vacuum_attempt_unsuccessful mother_maiden_name mother_first_name mother_middle_name mother_residence_line_1 mother_residence_city mother_residence_county mother_residence_state mother_residence_zip mother_dob mother_birthplace mother_ssn mother_race_ethn_1 mother_race_ethn_2 mother_race_ethn_3 mother_hispanic_origin_code mother_yrs_educ mother_occupation mother_job_industry mother_received_wic mother_weight_pre_pregnancy mother_weight_at_delivery mother_height month_prenatal_care_began prenatal_care_visit_count complications_pregnancy length_of_gestation_days length_of_gestation_weeks last_menses_on live_births_now_living last_live_birth_on live_births_now_deceased term_count_pre_20_weeks term_count_20_plus_weeks last_termination_on daily_cigarette_cnt_3mo_preconc daily_cigarette_cnt_1st_tri daily_cigarette_cnt_2nd_tri daily_cigarette_cnt_3rd_tri father_last_name father_first_name father_middle_name father_dob father_ssn father_race_ethn_1 father_race_ethn_2 father_race_ethn_3 father_hispanic_origin_code father_yrs_educ father_occupation father_job_industry )
	end

	def expected_column_names
		BirthDatumUpdate.expected_column_names
	end

end


#	Probably better to move this somewhere more appropriate
#	Perhaps CommonLib::StringExtension
#	Trying to get actual names from hospital, so, hopefully,
#	this won't be needed.
#
#String.class_eval do
#
#	def split_name
#		#	Really only want to split on spaces so just remove the problem chars.
#		#	May have to add others later.
#		names  = self.gsub(/\240/,' ').split
#		first  = names.shift.to_s.squish
#		last   = names.pop.to_s.squish
#		middle = names.join(' ').squish
#		[first,middle,last]
#	end
#
#end

##	Object and not String because could be NilClass
#Object.class_eval do
#
#	def nilify_blank
#		( self.blank? ) ? nil : self
#	end
#
#end
