#	Abstract model
class Abstract < ActiveRecord::Base

	belongs_to :study_subject

	with_options :class_name => 'User', :primary_key => 'uid' do |u|
		u.belongs_to :entry_1_by, :foreign_key => 'entry_1_by_uid'
		u.belongs_to :entry_2_by, :foreign_key => 'entry_2_by_uid'
		u.belongs_to :merged_by,  :foreign_key => 'merged_by_uid'
	end

	validations_from_yaml_file

	attr_protected :study_subject_id, :study_subject
	attr_protected :entry_1_by_uid
	attr_protected :entry_2_by_uid
	attr_protected :merged_by_uid

	attr_accessor :current_user
	attr_accessor :weight_units, :height_units
	attr_accessor :merging	#	flag to be used to skip 2 abstract limitation

	validate :subject_has_less_than_three_abstracts, :on => :create
	validate :subject_has_no_merged_abstract, :on => :create

	before_create :set_user
	after_create  :delete_unmerged
	before_save   :convert_height_to_cm
	before_save   :convert_weight_to_kg
	before_save   :set_days_since_fields

#	def self.fields
#		#	db: db field name
#		#	human: humanized field
#		@@fields ||= YAML::load( ERB.new( IO.read(
#			File.join(Rails.root,'config/abstract_fields.yml')
#		)).result)
##
##	Assuming that eventually there will be a preferred order,
##	we'll probably need to use this config file.
##
##	will need to add computed fields also, but this works too ...
##	could then remove this config file
##		@@fields ||= Abstract.comparable_attribute_names.collect{|f|
##			{:db => f, :human => Abstract.human_attribute_name(f) }
##		}
#	end
#
##
##	Why didn't I just use locales for this?
##
#
#	def fields
#		Abstract.fields
#	end

	#	db_fields may be a bit of a misnomer
	#	perhaps data_fields? 
	def self.db_fields
#		Abstract.fields.collect{|f|f[:db]}
		column_names - %w(id entry_1_by_uid entry_2_by_uid merged_by_uid study_subject_id
			created_at updated_at)
	end

	def db_fields
		Abstract.db_fields
	end

	def comparable_attributes
		HWIA[attributes.select {|k,v| db_fields.include?(k)}]
	end

	def is_the_same_as?(another_abstract)
		self.diff(another_abstract).blank?
	end

	def diff(another_abstract)
		a1 = self.comparable_attributes
		a2 = Abstract.find(another_abstract).comparable_attributes
		HWIA[a1.select{|k,v| a2[k] != v unless( a2[k].blank? && v.blank? ) }]
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

	scope :merged,   
		where(self.arel_table[:merged_by_uid].not_eq(nil) )
	scope :unmerged, where('merged_by_uid' => nil)


	alias_attribute "14or28Flag", :response_day14or28_flag
	alias_attribute :Att1, :received_bone_marrow_biopsy
	alias_attribute :ATT10, :received_h_and_p
	alias_attribute :ATT11, :received_other_reports
	alias_attribute :ATT12, :received_discharge_summary
	alias_attribute :ATT11, :received_other_reports
	alias_attribute :ATT14, :received_chemo_protocol
	alias_attribute :ATT15, :received_resp_to_therapy
	alias_attribute :ATT16, :received_specify_other_reports
	alias_attribute :ATT2, :received_bone_marrow_aspirate
	alias_attribute :ATT3, :received_flow_cytometry
	alias_attribute :ATT4, :received_ploidy
	alias_attribute :ATT5, :received_hla_typing
	alias_attribute :ATT6, :received_cytogenetics
	alias_attribute :ATT7, :received_cbc
	alias_attribute :ATT8, :received_csf
	alias_attribute :ATT9, :received_chest_xray
	alias_attribute :BM1A_14, :response_report_found_day_14
	alias_attribute :BM1A_28, :response_report_found_day_28
	alias_attribute :BM1A_7, :response_report_found_day_7
	alias_attribute :BM1B_14, :response_report_on_day_14
	alias_attribute :BM1B_28, :response_report_on_day_28
	alias_attribute :BM1B_7, :response_report_on_day_7
	alias_attribute :BM1C_14, :response_classification_day_14
	alias_attribute :BM1C_28, :response_classification_day_28
	alias_attribute :BM1C_7, :response_classification_day_7
	alias_attribute :BM1D_14, :response_blasts_day_14
	alias_attribute :BM1D_28, :response_blasts_day_28
	alias_attribute :BM1D_7, :response_blasts_day_7
	alias_attribute :BM1Da_14, :response_blasts_units_day_14
	alias_attribute :BM1Da_28, :response_blasts_units_day_28
	alias_attribute :BM1Da_7, :response_blasts_units_day_7
	alias_attribute :BM1E_14, :response_in_remission_day_14
	alias_attribute :BMA1, :marrow_biopsy_report_found
	alias_attribute :BMA2, :marrow_biopsy_on
	alias_attribute :BMA3, :marrow_biopsy_diagnosis
	alias_attribute :BMB1, :marrow_aspirate_report_found
	alias_attribute :BMB2, :marrow_aspirate_taken_on
	alias_attribute :BMB3, :marrow_aspirate_diagnosis
	alias_attribute :BoneMarKappa_14, :response_marrow_kappa_day_14
	alias_attribute :BoneMarKappa_7, :response_marrow_kappa_day_7
	alias_attribute :BoneMarLambda_14, :response_marrow_lambda_day_14
	alias_attribute :BoneMarLambda_7, :response_marrow_lambda_day_7
	alias_attribute :CBC1, :cbc_report_found
	alias_attribute :CBC2, :cbc_report_on
	alias_attribute :CBC3, :cbc_white_blood_count
	alias_attribute :CBC4, :cbc_percent_blasts
	alias_attribute :CBC4A, :cbc_number_blasts
	alias_attribute :CBC5, :cbc_hemoglobin_level
	alias_attribute :CBC6, :cbc_platelet_count
	alias_attribute :CBF1, :cerebrospinal_fluid_report_found
	alias_attribute :CBF2, :csf_report_on
	alias_attribute :CBF3, :csf_white_blood_count
	alias_attribute :CBF3b, :csf_white_blood_count_text
	alias_attribute :CBF4, :csf_red_blood_count
	alias_attribute :CBF4b, :csf_red_blood_count_text
	alias_attribute :CBF5a, :blasts_are_present
	alias_attribute :CBF5b, :number_of_blasts
	alias_attribute :CBF6a, :peripheral_blood_in_csf
	alias_attribute :CBF7, :csf_comment
	alias_attribute :CC1, :chemo_protocol_report_found
	alias_attribute :CC4, :patient_on_chemo_protocol
	alias_attribute :CC5, :chemo_protocol_name
	alias_attribute :CC6, :chemo_protocol_agent_description
	alias_attribute :CD10_14, :response_cd10_day_14
	alias_attribute :CD10_7, :response_cd10_day_7
	alias_attribute :CD13_14, :response_cd13_day_14
	alias_attribute :CD13_7, :response_cd13_day_7
	alias_attribute :CD14_14, :response_cd14_day_14
	alias_attribute :CD14_7, :response_cd14_day_7
	alias_attribute :CD15_14, :response_cd15_day_14
	alias_attribute :CD15_7, :response_cd15_day_7
	alias_attribute :CD19_14, :response_cd19_day_14
	alias_attribute :CD19_7, :response_cd19_day_7
	alias_attribute :CD19CD10_14, :response_cd19cd10_day_14
	alias_attribute :CD19CD10_7, :response_cd19cd10_day_7
	alias_attribute :CD1a_14, :response_cd1a_day_14
	alias_attribute :CD2_14, :response_cd2a_day_14
	alias_attribute :CD20_14, :response_cd20_day_14
	alias_attribute :CD20_7, :response_cd20_day_7
	alias_attribute :CD3_14, :response_cd3a_day_14
	alias_attribute :CD3_7, :response_cd3_day_7
	alias_attribute :CD33_14, :response_cd33_day_14
	alias_attribute :CD33_7, :response_cd33_day_7
	alias_attribute :CD34_14, :response_cd34_day_14
	alias_attribute :CD34_7, :response_cd34_day_7
	alias_attribute :CD4_14, :response_cd4a_day_14
	alias_attribute :CD5_14, :response_cd5a_day_14
	alias_attribute :CD56_14, :response_cd56_day_14
	alias_attribute :CD61_14, :response_cd61_day_14
	alias_attribute :CD7_14, :response_cd7a_day_14
	alias_attribute :CD8_14, :response_cd8a_day_14
	alias_attribute :ChildInRemission, :response_day30_is_in_remission
	alias_attribute :CIM1, :chest_imaging_report_found
	alias_attribute :CIM2, :chest_imaging_report_on
	alias_attribute :CIM3, :mediastial_mass_present
	alias_attribute :CIM4, :chest_imaging_comment
	alias_attribute :CIM5, :received_chest_ct
	alias_attribute :CIM6, :chest_ct_taken_on
	alias_attribute :CIM7, :chest_ct_medmass_present
	alias_attribute :CreateDate, :created_at
	alias_attribute :Createdby, :created_by
	alias_attribute :CY_Tri10_gBand, :cytogen_trisomy10
	alias_attribute :CY_Tri17_gBand, :cytogen_trisomy17
	alias_attribute :CY_Tri21_gBand, :cytogen_trisomy21
	alias_attribute :CY_Tri21_Pheno, :is_down_syndrome_phenotype
	alias_attribute :CY_Tri4_gBand, :cytogen_trisomy4
	alias_attribute :CY_Tri5_GBand, :cytogen_trisomy5
	alias_attribute :CY1, :cytogen_report_found
	alias_attribute :CY2, :cytogen_report_on
	alias_attribute :CY3, :conventional_karyotype_results
	alias_attribute :CY3A, :normal_cytogen
	alias_attribute :CY3AA, :is_cytogen_hosp_fish_t1221_done
	alias_attribute :CY3B, :is_karyotype_normal
	alias_attribute :CY3C, :number_normal_metaphase_karyotype
	alias_attribute :CY3D, :number_metaphase_tested_karyotype
	alias_attribute :CY4, :cytogen_comment
	alias_attribute :CY5, :is_verification_complete
	alias_attribute :DischargeDiag, :discharge_summary
	alias_attribute :FAB_B_Lineage, :diagnosis_is_b_all
	alias_attribute :FAB_T_Lineage, :diagnosis_is_t_all
	alias_attribute :FAB1, :diagnosis_is_all
	alias_attribute :FAB1A, :diagnosis_all_type
	alias_attribute :FAB2, :diagnosis_is_cml
	alias_attribute :FAB3, :diagnosis_is_cll
	alias_attribute :FAB4, :diagnosis_is_aml
	alias_attribute :FAB4A, :diagnosis_aml_type
	alias_attribute :FAB5, :diagnosis_is_other
	alias_attribute :FC1A, :flow_cyto_report_found
	alias_attribute :FC1A_14, :received_flow_cyto_day_14
	alias_attribute :FC1A_7, :received_flow_cyto_day_7
	alias_attribute :FC1B, :flow_cyto_report_on
	alias_attribute :FC1B_14, :response_flow_cyto_day_14_on
	alias_attribute :FC1B_7, :response_flow_cyto_day_7_on
	alias_attribute :FC1C1, :flow_cyto_cd10
	alias_attribute :FC1C10, :flow_cyto_igm
	alias_attribute :FC1C10b, :flow_cyto_igm_text
	alias_attribute :FC1C11, :flow_cyto_bm_kappa
	alias_attribute :FC1C11b, :flow_cyto_bm_kappa_text
	alias_attribute :FC1C12, :flow_cyto_bm_lambda
	alias_attribute :FC1C12b, :flow_cyto_bm_lambda_text
	alias_attribute :FC1C13, :flow_cyto_cd10_19 # "flow_cyto_CD10+19"
	alias_attribute :FC1C13b, :flow_cyto_cd10_19_text # "flow_cyto_CD10+19_text"
	alias_attribute :FC1C1b, :flow_cyto_cd10_text
	alias_attribute :FC1C2, :flow_cyto_cd19
	alias_attribute :FC1C2b, :flow_cyto_cd19_text
	alias_attribute :FC1C3, :flow_cyto_cd20
	alias_attribute :FC1C3b, :flow_cyto_cd20_text
	alias_attribute :FC1C4, :flow_cyto_cd21
	alias_attribute :FC1C4b, :flow_cyto_cd21_text
	alias_attribute :FC1C5, :flow_cyto_cd22
	alias_attribute :Fc1C5b, :flow_cyto_cd22_text
	alias_attribute :FC1C6, :flow_cyto_cd23
	alias_attribute :FC1C6b, :flow_cyto_cd23_text
	alias_attribute :FC1C7, :flow_cyto_cd24
	alias_attribute :FC1C7b, :flow_cyto_cd24_text
	alias_attribute :FC1C8, :flow_cyto_cd40
	alias_attribute :FC1C8b, :flow_cyto_cd40_text
	alias_attribute :FC1C9, :flow_cyto_surface_ig
	alias_attribute :FC1C9b, :flow_cyto_surface_ig_text
	alias_attribute :FC1D1, :flow_cyto_cd1a
	alias_attribute :FC1D1b, :flow_cyto_cd1a_text
	alias_attribute :FC1D2, :flow_cyto_cd2
	alias_attribute :FC1D2b, :flow_cyto_cd2_text
	alias_attribute :FC1D3, :flow_cyto_cd3
	alias_attribute :FC1D3b, :flow_cyto_cd3_text
	alias_attribute :FC1D4, :flow_cyto_cd4
	alias_attribute :FC1D4b, :flow_cyto_cd4_text
	alias_attribute :FC1D5, :flow_cyto_cd5
	alias_attribute :Fc1D5b, :flow_cyto_cd5_text
	alias_attribute :FC1D6, :flow_cyto_cd7
	alias_attribute :FC1D6b, :flow_cyto_cd7_text
	alias_attribute :FC1D7, :flow_cyto_cd8
	alias_attribute :FC1D7b, :flow_cyto_cd8_text
	alias_attribute :FC1D8, :flow_cyto_cd3_cd4 		#	"flow_cyto_CD3+CD4"
	alias_attribute :FC1D8b, :flow_cyto_cd3_cd4_text # "flow_cyto_CD3+CD4_text"
	alias_attribute :FC1D9, :flow_cyto_cd3_cd8 # "flow_cyto_CD3+CD8"
	alias_attribute :FC1D9b, :flow_cyto_cd3_cd8_text # "flow_cyto_CD3+CD8_text"
	alias_attribute :FC1E1, :flow_cyto_cd11b
	alias_attribute :FC1E1b, :flow_cyto_cd11b_text
	alias_attribute :FC1E2, :flow_cyto_cd11c
	alias_attribute :FC1E2b, :flow_cyto_cd11c_text
	alias_attribute :FC1E3, :flow_cyto_cd13
	alias_attribute :FC1E3b, :flow_cyto_cd13_text
	alias_attribute :FC1E4, :flow_cyto_cd15
	alias_attribute :FC1E4b, :flow_cyto_cd15_text
	alias_attribute :FC1E5, :flow_cyto_cd33
	alias_attribute :Fc1E5b, :flow_cyto_cd33_text
	alias_attribute :FC1E8, :flow_cyto_cd41
	alias_attribute :FC1E8b, :flow_cyto_cd41_text
	alias_attribute :FC1E9, :flow_cyto_cdw65
	alias_attribute :FC1E9b, :flow_cyto_cdw65_text
	alias_attribute :FC1F, :flow_cyto_cd34
	alias_attribute :FC1Fb, :flow_cyto_cd34_text
	alias_attribute :FC1G, :flow_cyto_cd61
	alias_attribute :FC1Gb, :flow_cyto_cd61_text
	alias_attribute :FC1H, :flow_cyto_cd14
	alias_attribute :FC1Hb, :flow_cyto_cd14_text
	alias_attribute :FC1I, :flow_cyto_glycoA
	alias_attribute :FC1Ib, :flow_cyto_glycoA_text
	alias_attribute :FC1J1, :flow_cyto_cd16
	alias_attribute :FC1J1b, :flow_cyto_cd16_text
	alias_attribute :FC1J2, :flow_cyto_cd56
	alias_attribute :FC1J2b, :flow_cyto_cd56_text
	alias_attribute :FC1J3, :flow_cyto_cd57
	alias_attribute :FC1J3b, :flow_cyto_cd57_text
	alias_attribute :FC1K1, :flow_cyto_cd9
	alias_attribute :FC1K1b, :flow_cyto_cd9_text
	alias_attribute :FC1K2, :flow_cyto_cd25
	alias_attribute :FC1K2b, :flow_cyto_cd25_text
	alias_attribute :FC1K3, :flow_cyto_cd38
	alias_attribute :FC1K3b, :flow_cyto_cd38_text
	alias_attribute :FC1K4, :flow_cyto_cd45
	alias_attribute :FC1K4b, :flow_cyto_cd45_text
	alias_attribute :FC1K5, :flow_cyto_cd71
	alias_attribute :FC1K5b, :flow_cyto_cd71_text
	alias_attribute :FC1L1, :flow_cyto_tdt
	alias_attribute :FC1L1b, :flow_cyto_tdt_text
	alias_attribute :FC1L2, :flow_cyto_hladr
	alias_attribute :FC1L2b, :flow_cyto_hladr_text
	alias_attribute :FC1L3a, :flow_cyto_other_marker_1_name
	alias_attribute :FC1L3b, :flow_cyto_other_marker_1
	alias_attribute :FC1L3c, :flow_cyto_other_marker_1_text
	alias_attribute :FC1L4a, :flow_cyto_other_marker_2_name
	alias_attribute :FC1L4b, :flow_cyto_other_marker_2
	alias_attribute :FC1L4c, :flow_cyto_other_marker_2_text
	alias_attribute :FC1L5a, :flow_cyto_other_marker_3_name
	alias_attribute :FC1L5b, :flow_cyto_other_marker_3
	alias_attribute :FC1L5c, :flow_cyto_other_marker_3_text
	alias_attribute :FC1L6a, :flow_cyto_other_marker_4_name
	alias_attribute :FC1L6b, :flow_cyto_other_marker_4
	alias_attribute :FC1L6c, :flow_cyto_other_marker_4_text
	alias_attribute :FC1L7a, :flow_cyto_other_marker_5_name
	alias_attribute :FC1L7b, :flow_cyto_other_marker_5
	alias_attribute :FC1L7c, :flow_cyto_other_marker_5_text
	alias_attribute :FC1M, :flow_cyto_remarks
	alias_attribute :FC2A, :Tdt_often_found_flow_cytometry
	alias_attribute :FC2B, :tdt_report_found
	alias_attribute :FC2C, :tdt_report_on
	alias_attribute :FC2D, :tdt_positive_or_negative
	alias_attribute :FC2E, :tdt_numerical_result
	alias_attribute :FC2F, :tdt_found_in_flow_cyto_chart
	alias_attribute :FC2G, :tdt_found_in_separate_report
	alias_attribute :FCComments, :response_comment_day_7
	alias_attribute :FCComments_14, :response_comment_day_14
	alias_attribute :FSH_ConvKaryoDone, :cytogen_karyotype_done
	alias_attribute :FSH_HospFishDone, :cytogen_hospital_fish_done
	alias_attribute :FSH_HospResults, :hospital_fish_results
	alias_attribute :FSH_UCBFishDone, :cytogen_ucb_fish_done
	alias_attribute :FSH_UCBResults, :ucb_fish_results
	alias_attribute "HLA-DR_14", :response_hladr_day_14
	alias_attribute "HLA-DR_7", :response_hladr_day_7
	alias_attribute :HS1, :histo_report_found
	alias_attribute :HS2, :histo_report_on
	alias_attribute :HS3, :histo_report_results
	alias_attribute :ID6, :diagnosed_on
	alias_attribute :ID8, :treatment_began_on
	alias_attribute :InconclResults_14, :response_is_inconclusive_day_14
	alias_attribute :InconclResults_21, :response_is_inconclusive_day_21
	alias_attribute :InconclResults_28, :response_is_inconclusive_day_28
	alias_attribute :InconclResults_7, :response_is_inconclusive_day_7
	alias_attribute :ND4AID, :abstracted_by
	alias_attribute :ND4B, :abstracted_on
	alias_attribute :ND5AID, :reviewed_by
	alias_attribute :ND5B, :reviewed_on
	alias_attribute :ND6AID, :data_entry_by
	alias_attribute :ND6B, :data_entry_done_on
	alias_attribute :ND7, :abstract_version_number
	alias_attribute :NumResultsAvailable, :flow_cyto_num_results_available
	alias_attribute :Other1_14, :response_other1_value_day_14
	alias_attribute :Other1_7, :response_other1_value_day_7
	alias_attribute :Other2_14, :response_other2_value_day_14
	alias_attribute :Other2_7, :response_other2_value_day_7
	alias_attribute :Other3_14, :response_other3_value_day_14
	alias_attribute :Other4_14, :response_other4_value_day_14
	alias_attribute :Other5_14, :response_other5_value_day_14
	alias_attribute :PE1, :h_and_p_reports_found
	alias_attribute :ATT12, :received_discharge_summary
	alias_attribute :PE14, :is_h_and_p_report_found
	alias_attribute :PE2, :h_and_p_reports_on
	alias_attribute :PE10, :physical_neuro
	alias_attribute :PE11, :physical_other_soft_2
	alias_attribute :PE12, :vital_status
	alias_attribute :PE12A, :dod
	alias_attribute :PE13b, :discharge_summary_found
	alias_attribute :PE3, :physical_gingival
	alias_attribute :PE4, :physical_leukemic_skin
	alias_attribute :PE5, :physical_lymph
	alias_attribute :PE6, :physical_spleen
	alias_attribute :PE8, :physical_testicle
	alias_attribute :PE9, :physical_other_soft
	alias_attribute :PL1, :ploidy_report_found
	alias_attribute :PL2, :ploidy_report_on
	alias_attribute :PL3, :is_hypodiploid
	alias_attribute :PL5, :is_hyperdiploid
	alias_attribute :PL6, :is_diploid
	alias_attribute :PL7, :dna_index
	alias_attribute :PL8, :other_dna_measure
	alias_attribute :PL9, :ploidy_comment
	alias_attribute :PEHepa, :hepatomegaly_present
	alias_attribute :PESpleno, :splenomegaly_present
	alias_attribute :Remarks, :response_comment
	alias_attribute :Specify1_14, :response_other1_name_day_14
	alias_attribute :Specify1_7, :response_other1_name_day_7
	alias_attribute :Specify2_14, :response_other2_name_day_14
	alias_attribute :Specify2_7, :response_other2_name_day_7
	alias_attribute :Specify3_14, :response_other3_name_day_14
	alias_attribute :Specify4_14, :response_other4_name_day_14
	alias_attribute :Specify5_14, :response_other5_name_day_14
	alias_attribute :STY1, :fab_classification
	alias_attribute :STY2, :diagnosis_icdO_description
	alias_attribute :STY2a, :diagnosis_icdO_number
	alias_attribute :STY3a, :cytogen_t1221
	alias_attribute :STY3b, :cytogen_inv16
	alias_attribute :STY3c, :cytogen_t119
	alias_attribute :STY3d, :cytogen_t821
	alias_attribute :STY3e, :cytogen_t1517
	alias_attribute :STY3f, :cytogen_is_hyperdiploidy
	alias_attribute :STY3f1, :cytogen_chromosome_number
	alias_attribute :STY3g, :cytogen_other_trans_1
	alias_attribute :STY3h, :cytogen_other_trans_2
	alias_attribute :STY3i, :cytogen_other_trans_3
	alias_attribute :STY3k, :cytogen_t922
	alias_attribute :STY3l, :cytogen_other_trans_4
	alias_attribute :STY3m, :cytogen_other_trans_5
	alias_attribute :Subtype, :response_fab_subtype
	alias_attribute :TermDoxy_14, :response_tdt_day_14
	alias_attribute :TermDoxy_7, :response_tdt_day_7
	alias_attribute :VersionDesc, :abstract_version_description
	alias_attribute :versionID, :abstract_version_id


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
#			study_subject.abstracts.unmerged.each{|a|a.delete}
			study_subject.abstracts.unmerged.each{|a|a.destroy}
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
__END__
