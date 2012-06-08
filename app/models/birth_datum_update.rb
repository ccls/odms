class BirthDatumUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(Rails.root,'config/birth_datum_update.yml')
		))).result)[Rails.env]
#			File.join(File.dirname(__FILE__),'../..','config/birth_datum_update.yml')

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
#	TODO what about missing columns???
#
		end
	end

	def parse_csv_file
		unless self.csv_file_file_name.blank?
			csv_file_path = self.csv_file.to_file.path
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
							:description => "Record failed to save",
							:notes       => line
						})	#	the line could be too long, so put in notes section
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
	#	I can't seem to find a way to stub 'birth_data.count'
	def birth_data_count
		birth_data.count
	end

	def self.expected_column_names
#		%w( masterid found_in_state_db match_confidence case_control_flag birth_state sex dob ignore1 ignore2 ignore3 last_name first_name middle_name state_registrar_no county_of_delivery local_registrar_no local_registrar_district birth_type birth_order birth_weight_gms method_of_delivery abnormal_conditions apgar_1min apgar_5min apgar_10min complications_labor_delivery fetal_presentation_at_birth forceps_attempt_unsuccessful vacuum_attempt_unsuccessful mother_maiden_name mother_first_name mother_middle_name mother_residence_line_1 mother_residence_city mother_residence_county mother_residence_state mother_residence_zip mother_dob mother_birthplace mother_ssn mother_race_ethn_1 mother_race_ethn_2 mother_race_ethn_3 mother_hispanic_origin_code mother_yrs_educ mother_occupation mother_job_industry mother_received_wic mother_weight_pre_pregnancy mother_weight_at_delivery mother_height month_prenatal_care_began prenatal_care_visit_count complications_pregnancy length_of_gestation_days length_of_gestation_weeks last_menses_on live_births_now_living last_live_birth_on live_births_now_deceased term_count_pre_20_weeks term_count_20_plus_weeks last_termination_on daily_cigarette_cnt_3mo_preconc daily_cigarette_cnt_1st_tri daily_cigarette_cnt_2nd_tri daily_cigarette_cnt_3rd_tri father_last_name father_first_name father_middle_name father_dob father_ssn father_race_ethn_1 father_race_ethn_2 father_race_ethn_3 father_hispanic_origin_code father_yrs_educ father_occupation father_job_industry )
		%w( masterid found_in_state_db match_confidence case_control_flag birth_state sex dob ignore1 ignore2 ignore3 last_name first_name middle_name state_registrar_no county_of_delivery local_registrar_no local_registrar_district birth_type birth_order birth_weight_gms method_of_delivery abnormal_conditions apgar_1min apgar_5min apgar_10min complications_labor_delivery fetal_presentation_at_birth forceps_attempt_unsuccessful vacuum_attempt_unsuccessful mother_maiden_name mother_first_name mother_middle_name mother_residence_line_1 mother_residence_city mother_residence_county mother_residence_state mother_residence_zip mother_dob mother_birthplace mother_ssn mother_race_ethn_1 mother_race_ethn_2 mother_race_ethn_3 mother_hispanic_origin_code mother_yrs_educ mother_occupation mother_industry mother_received_wic mother_weight_pre_pregnancy mother_weight_at_delivery mother_height month_prenatal_care_began prenatal_care_visit_count complications_pregnancy length_of_gestation_days length_of_gestation_weeks last_menses_on live_births_now_living last_live_birth_on live_births_now_deceased term_count_pre_20_weeks term_count_20_plus_weeks last_termination_on daily_cigarette_cnt_3mo_preconc daily_cigarette_cnt_1st_tri daily_cigarette_cnt_2nd_tri daily_cigarette_cnt_3rd_tri father_last_name father_first_name father_middle_name father_dob father_ssn father_race_ethn_1 father_race_ethn_2 father_race_ethn_3 father_hispanic_origin_code father_yrs_educ father_occupation father_industry )
	end

	def expected_column_names
		BirthDatumUpdate.expected_column_names
	end

end
