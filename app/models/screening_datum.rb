class ScreeningDatum < ActiveRecord::Base
#  attr_accessible :birth_city, :birth_country, :birth_state, :dad_is_biodad, :date, :dob, :dob_day, :dob_month, :dob_year, :father_first_name, :father_hispanicity, :father_hispanicity_mex, :father_last_name, :father_race, :first_name, :icf_master_id, :last_name, :middle_name, :mom_is_biomom, :mother_first_name, :mother_hispanicity, :mother_hispanicity_mex, :mother_last_name, :mother_maiden_name, :mother_race, :new_dob, :new_dob_day, :new_dob_month, :new_dob_year, :new_father_first_name, :new_father_last_name, :new_first_name, :new_last_name, :new_middle_name, :new_mother_first_name, :new_mother_last_name, :new_mother_maiden_name, :new_sex, :other_father_race, :other_mother_race, :screening_datum_update_id, :sex, :study_subject_id

	belongs_to :screening_datum_update
	attr_protected :screening_datum_update_id, :screening_datum_update
	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject

	has_many :odms_exceptions, :as => :exceptable

	after_create :post_processing

	def post_processing
		if icf_master_id.blank?
			odms_exceptions.create(:name => 'screening data append',
				:description => "icf_master_id blank")
		else
#			#	DO NOT USE 'study_subject' here as it will conflict with
#			#	the study_subject association.
#			subject = StudySubject.where(:icf_master_id => icf_master_id).first
#			if subject.nil?
#				odms_exceptions.create(:name => 'screening data append',
#					:description => "No subject found with icf_master_id :#{icf_master_id}:")
#			else
#
#
#
#
#
#			end
		end
	end	#	def post_processing

end
