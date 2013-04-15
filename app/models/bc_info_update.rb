require 'csv'

#
#	BcInfo files come from ICF
#
class BcInfoUpdate

	attr_accessor :csv_file
	attr_accessor :log

	def initialize(csv_file)
		self.csv_file = csv_file
		self.log = []
		self.parse_csv_file
	end

	def expected_columns
#		expected_columns = [
		[
			%w( masterid biomom biodad date 
				mother_full_name mother_maiden_name father_full_name 
				child_full_name child_dobm child_dobd child_doby child_gender 
				birthplace_country birthplace_state birthplace_city 
				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort,
			%w( masterid biomom biodad date 
				mother_first mother_last new_mother_first new_mother_last 
				mother_maiden new_mother_maiden 
				father_first father_last new_father_first new_father_last 
				child_first child_middle child_last 
				new_child_first new_child_middle new_child_last 
				child_dobfull new_child_dobfull child_dobm new_child_dobm 
				child_dobd new_child_dobd child_doby new_child_doby 
				child_gender new_child_gender 
				birthplace_country birthplace_state birthplace_city 
				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort,
			%w( icf_master_id mom_is_biomom dad_is_biodad
				date mother_first_name mother_last_name new_mother_first_name
				new_mother_last_name mother_maiden_name new_mother_maiden_name
				father_first_name father_last_name new_father_first_name
				new_father_last_name first_name middle_name last_name
				new_first_name new_middle_name new_last_name dob
				new_dob dob_month new_dob_month dob_day
				new_dob_day dob_year new_dob_year sex
				new_sex birth_country birth_state birth_city
				mother_hispanicity mother_hispanicity_mex mother_race other_mother_race
				father_hispanicity father_hispanicity_mex father_race other_father_race ).sort,
			%w( icf_master_id mom_is_biomom dad_is_biodad 
				date mother_first_name mother_last_name new_mother_first_name 
				new_mother_last_name mother_maiden_name new_mother_maiden_name 
				father_first_name father_last_name new_father_first_name 
				new_father_last_name first_name middle_name last_name 
				new_first_name new_middle_name new_last_name dob 
				new_dob dob_month new_dob_month dob_day 
				new_dob_day dob_year new_dob_year sex 
				new_sex birth_country birth_state birth_city 
				mother_hispanicity mother_hispanicity_mex mother_race mother_race_other 
				father_hispanicity father_hispanicity_mex father_race father_race_other ).sort ]
	end

	def parse_csv_file
		f=CSV.open(csv_file,'rb')
		actual_columns = f.readline
		f.close
	
		unless expected_columns.include?(actual_columns.sort)
			Notification.plain(
				"BC Info (#{csv_file}) has unexpected column names<br/>\n" <<
				"Actual   ...<br/>\n#{actual_columns.join(',')}<br/>\n" ,
				email_options.merge({ 
					:subject => "ODMS: Unexpected or missing columns in #{csv_file}" })
			).deliver
		end	#	unless expected_columns.include?(actual_columns.sort)
	
		study_subjects = []
		log << "Processing #{csv_file}..."

		(f=CSV.open( csv_file, 'rb',{ :headers => true })).each do |line|
			log << ''
			log << "Processing line :#{f.lineno}:"
			log << line

			bc_info = BcInfo.new(line.to_hash.merge(
				:bc_info_file => csv_file, :log => log ) )
			bc_info.process
			study_subjects.push( self.bc_info.study_subject )
	
		end	#	(f=CSV.open( csv_file, 'rb',{

		Notification.updates_from_bc_info( csv_file, study_subjects,
				email_options.merge({ })
			).deliver
		log << ''; log << "Archiving #{csv_file}"
		archive_dir = Date.current.strftime('%Y%m%d')
		FileUtils.mkdir_p(archive_dir) unless File.exists?(archive_dir)
		FileUtils.move(csv_file,archive_dir)
	end

end
