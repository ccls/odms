#	Abstract model
class Abstract < ActiveRecord::Base

	belongs_to :study_subject	#, :counter_cache => true

	with_options :class_name => 'User', :primary_key => 'uid' do |u|
		u.belongs_to :entry_1_by, :foreign_key => 'entry_1_by_uid'
		u.belongs_to :entry_2_by, :foreign_key => 'entry_2_by_uid'
		u.belongs_to :merged_by,  :foreign_key => 'merged_by_uid'
	end

	validates_length_of :response_classification_day_7,
		:response_classification_day_14,
		:response_classification_day_28,
			:maximum => 2, :allow_blank => true

	validates_length_of :cytogen_chromosome_number,
		:maximum => 3, :allow_blank => true

	validates_length_of :flow_cyto_other_marker_1,
		:flow_cyto_other_marker_2,
		:flow_cyto_other_marker_3,
		:flow_cyto_other_marker_4,
		:flow_cyto_other_marker_5,
		:response_other1_value_day_7,
		:response_other1_value_day_14,
		:response_other2_value_day_7,
		:response_other2_value_day_14,
		:response_other3_value_day_14,
		:response_other4_value_day_14,
		:response_other5_value_day_14,
			:maximum => 4, :allow_blank => true

	validates_length_of :flow_cyto_other_marker_1,
		:flow_cyto_other_marker_2,
		:flow_cyto_other_marker_3,
		:flow_cyto_other_marker_4,
		:flow_cyto_other_marker_5,
		:response_other1_value_day_7,
		:response_other1_value_day_14,
		:response_other2_value_day_7,
		:response_other2_value_day_14,
		:response_other3_value_day_14,
		:response_other5_value_day_14,
			:maximum => 4, :allow_blank => true

	validates_length_of :normal_cytogen,
		:is_cytogen_hosp_fish_t1221_done,
		:is_karyotype_normal,
		:physical_neuro,
		:physical_other_soft_2,
		:physical_gingival,
		:physical_leukemic_skin,
		:physical_lymph,
		:physical_spleen,
		:physical_testicle,
		:physical_other_soft,
		:is_hypodiploid,
		:is_hyperdiploid,
		:is_diploid,
		:dna_index,
		:cytogen_is_hyperdiploidy,
			:maximum => 5, :allow_blank => true

	validates_length_of :cytogen_t1221,
		:cytogen_inv16,
		:cytogen_t119,
		:cytogen_t821,
		:cytogen_t1517,
			:maximum => 9, :allow_blank => true

	validates_length_of :response_cd10_day_7,
		:response_cd10_day_14,
		:response_cd13_day_14,
		:response_cd13_day_7,
		:response_cd14_day_14,
		:response_cd14_day_7,
		:response_cd15_day_14,
		:response_cd15_day_7,
		:response_cd19_day_14,
		:response_cd19_day_7,
		:response_cd19cd10_day_14,
		:response_cd19cd10_day_7,
		:response_cd1a_day_14,
		:response_cd2a_day_14,
		:response_cd20_day_14,
		:response_cd20_day_7,
		:response_cd3a_day_14,
		:response_cd3_day_7,
		:response_cd33_day_14,
		:response_cd33_day_7,
		:response_cd34_day_14,
		:response_cd34_day_7,
		:response_cd4a_day_14,
		:response_cd5a_day_14,
		:response_cd56_day_14,
		:response_cd61_day_14,
		:response_cd7a_day_14,
		:response_cd8a_day_14,
		:flow_cyto_cd10,
		:flow_cyto_igm,
		:flow_cyto_bm_kappa,
		:flow_cyto_bm_lambda,
		:flow_cyto_cd10_19,
		:flow_cyto_cd19,
		:flow_cyto_cd20,
		:flow_cyto_cd21,
		:flow_cyto_cd22,
		:flow_cyto_cd23,
		:flow_cyto_cd24,
		:flow_cyto_cd40,
		:flow_cyto_surface_ig,
		:flow_cyto_cd1a,
		:flow_cyto_cd2,
		:flow_cyto_cd3,
		:flow_cyto_cd4,
		:flow_cyto_cd5,
		:flow_cyto_cd7,
		:flow_cyto_cd8,
		:flow_cyto_cd3_cd4,
		:flow_cyto_cd3_cd8,
		:flow_cyto_cd11b,
		:flow_cyto_cd11c,
		:flow_cyto_cd13,
		:flow_cyto_cd15,
		:flow_cyto_cd33,
		:flow_cyto_cd41,
		:flow_cyto_cdw65,
		:flow_cyto_cd34,
		:flow_cyto_cd61,
		:flow_cyto_cd14,
		:flow_cyto_glycoa,
		:flow_cyto_cd16,
		:flow_cyto_cd56,
		:flow_cyto_cd57,
		:flow_cyto_cd9,
		:flow_cyto_cd25,
		:flow_cyto_cd38,
		:flow_cyto_cd45,
		:flow_cyto_cd71,
		:flow_cyto_tdt,
		:flow_cyto_hladr,
		:response_hladr_day_7,
		:response_hladr_day_14,
		:response_tdt_day_7,
		:response_tdt_day_14,
			:maximum => 10, :allow_blank => true

	validates_length_of :response_blasts_units_day_7,
		:response_blasts_units_day_14,
		:response_blasts_units_day_28,
		:other_dna_measure,
		:response_fab_subtype,
			:maximum => 15, :allow_blank => true

	validates_length_of :flow_cyto_other_marker_1_name,
		:flow_cyto_other_marker_2_name,
		:flow_cyto_other_marker_3_name,
		:flow_cyto_other_marker_4_name,
		:flow_cyto_other_marker_5_name,
			:maximum => 20, :allow_blank => true

	validates_length_of :response_other1_name_day_7,
		:response_other1_name_day_14,
		:response_other2_name_day_7,
		:response_other2_name_day_14,
		:response_other3_name_day_14,
		:response_other4_name_day_14,
		:response_other5_name_day_14,
			:maximum => 25, :allow_blank => true

	validates_length_of :cytogen_other_trans_1,
		:cytogen_other_trans_2,
		:cytogen_other_trans_3,
		:cytogen_other_trans_4,
		:cytogen_other_trans_5,
		:cytogen_other_trans_6,
		:cytogen_other_trans_7,
		:cytogen_other_trans_8,
		:cytogen_other_trans_9,
		:cytogen_other_trans_10,
			:maximum => 35, :allow_blank => true

	validates_length_of :flow_cyto_igm_text,
		:flow_cyto_bm_kappa_text,
		:flow_cyto_bm_lambda_text,
		:flow_cyto_cd10_19_text,
		:flow_cyto_cd10_text,
		:flow_cyto_cd19_text,
		:flow_cyto_cd20_text,
		:flow_cyto_cd21_text,
		:flow_cyto_cd22_text,
		:flow_cyto_cd23_text,
		:flow_cyto_cd24_text,
		:flow_cyto_cd40_text,
		:flow_cyto_surface_ig_text,
		:flow_cyto_cd1a_text,
		:flow_cyto_cd2_text,
		:flow_cyto_cd3_text,
		:flow_cyto_cd4_text,
		:flow_cyto_cd5_text,
		:flow_cyto_cd7_text,
		:flow_cyto_cd8_text,
		:flow_cyto_cd3_cd4_text,
		:flow_cyto_cd3_cd8_text,
		:flow_cyto_cd11b_text,
		:flow_cyto_cd11c_text,
		:flow_cyto_cd13_text,
		:flow_cyto_cd15_text,
		:flow_cyto_cd33_text,
		:flow_cyto_cd41_text,
		:flow_cyto_cdw65_text,
		:flow_cyto_cd34_text,
		:flow_cyto_cd61_text,
		:flow_cyto_cd14_text,
		:flow_cyto_glycoa_text,
		:flow_cyto_cd16_text,
		:flow_cyto_cd56_text,
		:flow_cyto_cd57_text,
		:flow_cyto_cd9_text,
		:flow_cyto_cd25_text,
		:flow_cyto_cd38_text,
		:flow_cyto_cd45_text,
		:flow_cyto_cd71_text,
		:flow_cyto_tdt_text,
		:flow_cyto_hladr_text,
		:flow_cyto_other_marker_1_text,
		:flow_cyto_other_marker_2_text,
		:flow_cyto_other_marker_3_text,
		:flow_cyto_other_marker_4_text,
		:flow_cyto_other_marker_5_text,
		:ucb_fish_results,
		:fab_classification,
		:diagnosis_icdo_number,
		:cytogen_t922,
			:maximum => 50, :allow_blank => true

	validates_length_of :diagnosis_icdo_description,
			:maximum => 55, :allow_blank => true

	validates_length_of :ploidy_comment,
			:maximum => 100, :allow_blank => true

	validates_length_of :csf_red_blood_count_text,
		:blasts_are_present,
		:peripheral_blood_in_csf,
		:chemo_protocol_report_found,
		:chemo_protocol_name,
		:conventional_karyotype_results,
		:hospital_fish_results,
		:hyperdiploidy_by,
			:maximum => 250, :allow_blank => true

	validates_length_of :marrow_biopsy_diagnosis,
		:marrow_aspirate_diagnosis,
		:csf_white_blood_count_text,
		:csf_comment,
		:chemo_protocol_agent_description,
		:chest_imaging_comment,
		:cytogen_comment,
		:discharge_summary,
		:flow_cyto_remarks,
		:response_comment_day_7,
		:response_comment_day_14,
		:histo_report_results,
		:response_comment,
			:maximum => 65000, :allow_blank => true

#	histo_report_found is a string.  needs to be an int for this validation
#| histo_report_found                         | varchar(5)    | YES  |     | NULL    
#		:histo_report_found,
#	changed to integer

	validates_inclusion_of(
		:histo_report_found,
		:cbc_report_found,
		:cerebrospinal_fluid_report_found,
		:chemo_protocol_report_found,
		:chest_ct_medmass_present,
		:chest_imaging_report_found,
		:cytogen_hospital_fish_done,
		:cytogen_karyotype_done,
		:cytogen_report_found,
		:cytogen_trisomy4,
		:cytogen_trisomy5,
		:cytogen_trisomy10,
		:cytogen_trisomy17,
		:cytogen_trisomy21,
		:cytogen_ucb_fish_done,
		:diagnosis_is_all,
		:diagnosis_is_aml,
		:diagnosis_is_b_all,
		:diagnosis_is_cll,
		:diagnosis_is_cml,
		:diagnosis_is_other,
		:diagnosis_is_t_all,
		:discharge_summary_found,
		:flow_cyto_num_results_available,
		:flow_cyto_report_found,
		:h_and_p_reports_found,
		:hepatomegaly_present,
		:is_down_syndrome_phenotype,
		:marrow_aspirate_report_found,
		:marrow_biopsy_report_found,
		:mediastinal_mass_present,
		:patient_on_chemo_protocol,
		:ploidy_report_found,
		:received_bone_marrow_aspirate,
		:received_bone_marrow_biopsy,
		:received_cbc,
		:received_chemo_protocol,
		:received_chest_ct,
		:received_chest_xray,
		:received_csf,
		:received_cytogenetics,
		:received_discharge_summary,
		:received_flow_cytometry,
		:received_hla_typing,
		:received_h_and_p,
		:received_other_reports,
		:received_ploidy,
		:received_resp_to_therapy,
		:response_day14or28_flag,
		:response_day30_is_in_remission,
		:response_is_inconclusive_day_7,
		:response_is_inconclusive_day_14,
		:response_is_inconclusive_day_21,
		:response_is_inconclusive_day_28,
		:response_report_found_day_7,
		:response_report_found_day_14,
		:response_report_found_day_28,
		:splenomegaly_present,
		:tdt_often_found_flow_cytometry,
		:tdt_report_found,
			:in => YNDK.valid_values, :allow_nil => true )

	attr_protected :study_subject_id, :study_subject
	attr_protected :entry_1_by_uid
	attr_protected :entry_2_by_uid
	attr_protected :merged_by_uid

	attr_accessor :current_user
	attr_accessor :weight_units, :height_units
	attr_accessor :merging	#	flag to be used to skip 2 abstract limitation

	#	The :on => :create doesn't seem to work as described
	#	validate_on_create is technically deprecated, but still works
#	NOTE does this actually work???
#	validate_on_create :subject_has_less_than_three_abstracts	#, :on => :create
#	validate_on_create :subject_has_no_merged_abstract	#, :on => :create
	validate :subject_has_less_than_three_abstracts, :on => :create
	validate :subject_has_no_merged_abstract, :on => :create

	before_create :set_user
	after_create  :delete_unmerged
	before_save   :convert_height_to_cm
	before_save   :convert_weight_to_kg
	before_save   :set_days_since_fields

	def self.fields
		#	db: db field name
		#	human: humanized field
		@@fields ||= YAML::load( ERB.new( IO.read(
			File.join(File.dirname(__FILE__),'../../config/abstract_fields.yml')
		)).result)
	end

	def fields
		Abstract.fields
	end

	def self.db_fields
#		@db_fields ||= fields.collect{|f|f[:db]}
		Abstract.fields.collect{|f|f[:db]}
	end

	def db_fields
		Abstract.db_fields
	end

	#	db_fields need defined first though
#	attr_accessible *(Abstract.db_fields + [:current_user,:weight_units,:height_units,:merging])
#	attr_accessible *Abstract.db_fields

	def comparable_attributes
		HashWithIndifferentAccess[attributes.select {|k,v| db_fields.include?(k)}]
	end

	def is_the_same_as?(another_abstract)
		self.diff(another_abstract).blank?
	end

	def diff(another_abstract)
		a1 = self.comparable_attributes
		a2 = Abstract.find(another_abstract).comparable_attributes
		HashWithIndifferentAccess[a1.select{|k,v| a2[k] != v unless( a2[k].blank? && v.blank? ) }]
	end

	def self.sections
		#	:label: Cytogenetics
		#	:controller: CytogeneticsController
		#	:edit:  :edit_abstract_cytogenetic_path
		#	:show:  :abstract_cytogenetic_path
		@@sections ||= YAML::load(ERB.new( IO.read(
			File.join(File.dirname(__FILE__),'../../config/abstract_sections.yml')
		)).result)
	end

	def merged?
		!merged_by_uid.blank?
	end

	scope :merged,   where('merged_by_uid IS NOT NULL')
	scope :unmerged, where('merged_by_uid IS NULL')

protected

	def set_days_since_fields
		#	must explicitly convert these DateTimes to Date so that the
		#	difference is in days and not seconds
		#	I really only need to do this if something changes,
		#	but for now, just do it and make sure that
		#	it is tested.  Optimize and refactor later.
		unless diagnosed_on.nil?
			self.response_day_7_days_since_diagnosis = (
				response_report_on_day_7.to_date - diagnosed_on.to_date 
				) unless response_report_on_day_7.nil?
			self.response_day_14_days_since_diagnosis = (
				response_report_on_day_14.to_date - diagnosed_on.to_date 
				) unless response_report_on_day_14.nil?
			self.response_day_28_days_since_diagnosis = (
				response_report_on_day_28.to_date - diagnosed_on.to_date 
				) unless response_report_on_day_28.nil?
		end
		unless treatment_began_on.nil?
			self.response_day_7_days_since_treatment_began = (
				response_report_on_day_7.to_date - treatment_began_on.to_date 
				) unless response_report_on_day_7.nil?
			self.response_day_14_days_since_treatment_began = (
				response_report_on_day_14.to_date - treatment_began_on.to_date 
				) unless response_report_on_day_14.nil?
			self.response_day_28_days_since_treatment_began = (
				response_report_on_day_28.to_date - treatment_began_on.to_date 
				) unless response_report_on_day_28.nil?
		end
	end

	def convert_height_to_cm
		if( !height_units.nil? && height_units.match(/in/i) )
			self.height_units = nil
			self.height_at_diagnosis *= 2.54
		end
	end

	def convert_weight_to_kg
		if( !weight_units.nil? && weight_units.match(/lb/i) )
			self.weight_units = nil
			self.weight_at_diagnosis /= 2.2046
		end
	end

	#	Set user if given
	def set_user
		if study_subject
			#	because it is possible to create the first, then the second
			#	and then delete the first, and create another, first and
			#	second kinda lose their meaning until the merge, so set them
			#	both as the same until the merge
			case study_subject.abstracts.count
				when 0 
					self.entry_1_by_uid = current_user.try(:uid)||0
					self.entry_2_by_uid = current_user.try(:uid)||0
				when 1 
					self.entry_1_by_uid = current_user.try(:uid)||0
					self.entry_2_by_uid = current_user.try(:uid)||0
				when 2
					abs = study_subject.abstracts
					#	compact just in case a nil crept in
					self.entry_1_by_uid = [abs[0].entry_1_by_uid,abs[0].entry_2_by_uid].compact.first
					self.entry_2_by_uid = [abs[1].entry_1_by_uid,abs[1].entry_2_by_uid].compact.first
					self.merged_by_uid  = current_user.try(:uid)||0
			end
		end
	end

	def delete_unmerged
		if study_subject and !merged_by_uid.blank?
			#	use delete and not destroy to preserve the abstracts_count
#	gonna stop using abstracts_count so really won't matter
			study_subject.abstracts.unmerged.each{|a|a.delete}
		end
	end

	def subject_has_less_than_three_abstracts
		#	because this abstract hasn't been created yet, we're comparing to 2, not 3
		if study_subject and study_subject.abstracts.count >= 2 and !merging
			errors.add(:study_subject_id,"Study Subject can only have 2 unmerged abstracts.")
		end
	end

	def subject_has_no_merged_abstract
		if study_subject and !study_subject.abstracts.merged.empty?
			errors.add(:study_subject_id,"Study Subject already has a merged abstract." )
		end
	end

end
