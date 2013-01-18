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


	alias_attribute :_14or28Flag, :response_day14or28_flag
	alias_attribute :att1, :received_bone_marrow_biopsy
	alias_attribute :att10, :received_h_and_p
	alias_attribute :att11, :received_other_reports
	alias_attribute :att12, :received_discharge_summary
	alias_attribute :att11, :received_other_reports
	alias_attribute :att14, :received_chemo_protocol
	alias_attribute :att15, :received_resp_to_therapy
	alias_attribute :att16, :received_specify_other_reports
	alias_attribute :att2, :received_bone_marrow_aspirate
	alias_attribute :att3, :received_flow_cytometry
	alias_attribute :att4, :received_ploidy
	alias_attribute :att5, :received_hla_typing
	alias_attribute :att6, :received_cytogenetics
	alias_attribute :att7, :received_cbc
	alias_attribute :att8, :received_csf
	alias_attribute :att9, :received_chest_xray
	alias_attribute :bm1a_14, :response_report_found_day_14
	alias_attribute :bm1a_28, :response_report_found_day_28
	alias_attribute :bm1a_7, :response_report_found_day_7
	alias_attribute :bm1b_14, :response_report_on_day_14
	alias_attribute :bm1b_28, :response_report_on_day_28
	alias_attribute :bm1b_7, :response_report_on_day_7
	alias_attribute :bm1c_14, :response_classification_day_14
	alias_attribute :bm1c_28, :response_classification_day_28
	alias_attribute :bm1c_7, :response_classification_day_7
	alias_attribute :bm1d_14, :response_blasts_day_14
	alias_attribute :bm1d_28, :response_blasts_day_28
	alias_attribute :bm1d_7, :response_blasts_day_7
	alias_attribute :bm1da_14, :response_blasts_units_day_14
	alias_attribute :bm1da_28, :response_blasts_units_day_28
	alias_attribute :bm1da_7, :response_blasts_units_day_7
	alias_attribute :bm1e_14, :response_in_remission_day_14
	alias_attribute :bma1, :marrow_biopsy_report_found
	alias_attribute :bma2, :marrow_biopsy_on
	alias_attribute :bma3, :marrow_biopsy_diagnosis
	alias_attribute :bmb1, :marrow_aspirate_report_found
	alias_attribute :bmb2, :marrow_aspirate_taken_on
	alias_attribute :bmb3, :marrow_aspirate_diagnosis
	alias_attribute :bonemarkappa_14, :response_marrow_kappa_day_14
	alias_attribute :bonemarkappa_7, :response_marrow_kappa_day_7
	alias_attribute :bonemarlambda_14, :response_marrow_lambda_day_14
	alias_attribute :bonemarlambda_7, :response_marrow_lambda_day_7
	alias_attribute :cbc1, :cbc_report_found
	alias_attribute :cbc2, :cbc_report_on
	alias_attribute :cbc3, :cbc_white_blood_count
	alias_attribute :cbc4, :cbc_percent_blasts
	alias_attribute :cbc4a, :cbc_number_blasts
	alias_attribute :cbc5, :cbc_hemoglobin_level
	alias_attribute :cbc6, :cbc_platelet_count
	alias_attribute :cbf1, :cerebrospinal_fluid_report_found
	alias_attribute :cbf2, :csf_report_on
	alias_attribute :cbf3, :csf_white_blood_count
	alias_attribute :cbf3b, :csf_white_blood_count_text
	alias_attribute :cbf4, :csf_red_blood_count
	alias_attribute :cbf4b, :csf_red_blood_count_text
	alias_attribute :cbf5a, :blasts_are_present
	alias_attribute :cbf5b, :number_of_blasts
	alias_attribute :cbf6a, :peripheral_blood_in_csf
	alias_attribute :cbf7, :csf_comment
	alias_attribute :cc1, :chemo_protocol_report_found
	alias_attribute :cc4, :patient_on_chemo_protocol
	alias_attribute :cc5, :chemo_protocol_name
	alias_attribute :cc6, :chemo_protocol_agent_description
	alias_attribute :cd10_14, :response_cd10_day_14
	alias_attribute :cd10_7, :response_cd10_day_7
	alias_attribute :cd13_14, :response_cd13_day_14
	alias_attribute :cd13_7, :response_cd13_day_7
	alias_attribute :cd14_14, :response_cd14_day_14
	alias_attribute :cd14_7, :response_cd14_day_7
	alias_attribute :cd15_14, :response_cd15_day_14
	alias_attribute :cd15_7, :response_cd15_day_7
	alias_attribute :cd19_14, :response_cd19_day_14
	alias_attribute :cd19_7, :response_cd19_day_7
	alias_attribute :cd19cd10_14, :response_cd19cd10_day_14
	alias_attribute :cd19cd10_7, :response_cd19cd10_day_7
	alias_attribute :cd1a_14, :response_cd1a_day_14
	alias_attribute :cd2_14, :response_cd2a_day_14
	alias_attribute :cd20_14, :response_cd20_day_14
	alias_attribute :cd20_7, :response_cd20_day_7
	alias_attribute :cd3_14, :response_cd3a_day_14
	alias_attribute :cd3_7, :response_cd3_day_7
	alias_attribute :cd33_14, :response_cd33_day_14
	alias_attribute :cd33_7, :response_cd33_day_7
	alias_attribute :cd34_14, :response_cd34_day_14
	alias_attribute :cd34_7, :response_cd34_day_7
	alias_attribute :cd4_14, :response_cd4a_day_14
	alias_attribute :cd5_14, :response_cd5a_day_14
	alias_attribute :cd56_14, :response_cd56_day_14
	alias_attribute :cd61_14, :response_cd61_day_14
	alias_attribute :cd7_14, :response_cd7a_day_14
	alias_attribute :cd8_14, :response_cd8a_day_14
	alias_attribute :childinremission, :response_day30_is_in_remission
	alias_attribute :cim1, :chest_imaging_report_found
	alias_attribute :cim2, :chest_imaging_report_on
	alias_attribute :cim3, :mediastial_mass_present
	alias_attribute :cim4, :chest_imaging_comment
	alias_attribute :cim5, :received_chest_ct
	alias_attribute :cim6, :chest_ct_taken_on
	alias_attribute :cim7, :chest_ct_medmass_present
	alias_attribute :createdate, :created_at
	alias_attribute :createdby, :created_by
	alias_attribute :cy_tri10_gband, :cytogen_trisomy10
	alias_attribute :cy_tri17_gband, :cytogen_trisomy17
	alias_attribute :cy_tri21_gband, :cytogen_trisomy21
	alias_attribute :cy_tri21_pheno, :is_down_syndrome_phenotype
	alias_attribute :cy_tri4_gband, :cytogen_trisomy4
	alias_attribute :cy_tri5_gband, :cytogen_trisomy5
	alias_attribute :cy1, :cytogen_report_found
	alias_attribute :cy2, :cytogen_report_on
	alias_attribute :cy3, :conventional_karyotype_results
	alias_attribute :cy3a, :normal_cytogen
	alias_attribute :cy3aa, :is_cytogen_hosp_fish_t1221_done
	alias_attribute :cy3b, :is_karyotype_normal
	alias_attribute :cy3c, :number_normal_metaphase_karyotype
	alias_attribute :cy3d, :number_metaphase_tested_karyotype
	alias_attribute :cy4, :cytogen_comment
	alias_attribute :cy5, :is_verification_complete
	alias_attribute :dischargediag, :discharge_summary
	alias_attribute :fab_b_lineage, :diagnosis_is_b_all
	alias_attribute :fab_t_lineage, :diagnosis_is_t_all
	alias_attribute :fab1, :diagnosis_is_all
	alias_attribute :fab1a, :diagnosis_all_type
	alias_attribute :fab2, :diagnosis_is_cml
	alias_attribute :fab3, :diagnosis_is_cll
	alias_attribute :fab4, :diagnosis_is_aml
	alias_attribute :fab4a, :diagnosis_aml_type
	alias_attribute :fab5, :diagnosis_is_other
	alias_attribute :fc1a, :flow_cyto_report_found
	alias_attribute :fc1a_14, :received_flow_cyto_day_14
	alias_attribute :fc1a_7, :received_flow_cyto_day_7
	alias_attribute :fc1b, :flow_cyto_report_on
	alias_attribute :fc1b_14, :response_flow_cyto_day_14_on
	alias_attribute :fc1b_7, :response_flow_cyto_day_7_on
	alias_attribute :fc1c1, :flow_cyto_cd10
	alias_attribute :fc1c10, :flow_cyto_igm
	alias_attribute :fc1c10b, :flow_cyto_igm_text
	alias_attribute :fc1c11, :flow_cyto_bm_kappa
	alias_attribute :fc1c11b, :flow_cyto_bm_kappa_text
	alias_attribute :fc1c12, :flow_cyto_bm_lambda
	alias_attribute :fc1c12b, :flow_cyto_bm_lambda_text
	alias_attribute :fc1c13, :flow_cyto_cd10_19 # "flow_cyto_CD10+19"
	alias_attribute :fc1c13b, :flow_cyto_cd10_19_text # "flow_cyto_CD10+19_text"
	alias_attribute :fc1c1b, :flow_cyto_cd10_text
	alias_attribute :fc1c2, :flow_cyto_cd19
	alias_attribute :fc1c2b, :flow_cyto_cd19_text
	alias_attribute :fc1c3, :flow_cyto_cd20
	alias_attribute :fc1c3b, :flow_cyto_cd20_text
	alias_attribute :fc1c4, :flow_cyto_cd21
	alias_attribute :fc1c4b, :flow_cyto_cd21_text
	alias_attribute :fc1c5, :flow_cyto_cd22
	alias_attribute :fc1c5b, :flow_cyto_cd22_text
	alias_attribute :fc1c6, :flow_cyto_cd23
	alias_attribute :fc1c6b, :flow_cyto_cd23_text
	alias_attribute :fc1c7, :flow_cyto_cd24
	alias_attribute :fc1c7b, :flow_cyto_cd24_text
	alias_attribute :fc1c8, :flow_cyto_cd40
	alias_attribute :fc1c8b, :flow_cyto_cd40_text
	alias_attribute :fc1c9, :flow_cyto_surface_ig
	alias_attribute :fc1c9b, :flow_cyto_surface_ig_text
	alias_attribute :fc1d1, :flow_cyto_cd1a
	alias_attribute :fc1d1b, :flow_cyto_cd1a_text
	alias_attribute :fc1d2, :flow_cyto_cd2
	alias_attribute :fc1d2b, :flow_cyto_cd2_text
	alias_attribute :fc1d3, :flow_cyto_cd3
	alias_attribute :fc1d3b, :flow_cyto_cd3_text
	alias_attribute :fc1d4, :flow_cyto_cd4
	alias_attribute :fc1d4b, :flow_cyto_cd4_text
	alias_attribute :fc1d5, :flow_cyto_cd5
	alias_attribute :fc1d5b, :flow_cyto_cd5_text
	alias_attribute :fc1d6, :flow_cyto_cd7
	alias_attribute :fc1d6b, :flow_cyto_cd7_text
	alias_attribute :fc1d7, :flow_cyto_cd8
	alias_attribute :fc1d7b, :flow_cyto_cd8_text
	alias_attribute :fc1d8, :flow_cyto_cd3_cd4 		#	"flow_cyto_CD3+CD4"
	alias_attribute :fc1d8b, :flow_cyto_cd3_cd4_text # "flow_cyto_CD3+CD4_text"
	alias_attribute :fc1d9, :flow_cyto_cd3_cd8 # "flow_cyto_CD3+CD8"
	alias_attribute :fc1d9b, :flow_cyto_cd3_cd8_text # "flow_cyto_CD3+CD8_text"
	alias_attribute :fc1e1, :flow_cyto_cd11b
	alias_attribute :fc1e1b, :flow_cyto_cd11b_text
	alias_attribute :fc1e2, :flow_cyto_cd11c
	alias_attribute :fc1e2b, :flow_cyto_cd11c_text
	alias_attribute :fc1e3, :flow_cyto_cd13
	alias_attribute :fc1e3b, :flow_cyto_cd13_text
	alias_attribute :fc1e4, :flow_cyto_cd15
	alias_attribute :fc1e4b, :flow_cyto_cd15_text
	alias_attribute :fc1e5, :flow_cyto_cd33
	alias_attribute :fc1e5b, :flow_cyto_cd33_text
	alias_attribute :fc1e8, :flow_cyto_cd41
	alias_attribute :fc1e8b, :flow_cyto_cd41_text
	alias_attribute :fc1e9, :flow_cyto_cdw65
	alias_attribute :fc1e9b, :flow_cyto_cdw65_text
	alias_attribute :fc1f, :flow_cyto_cd34
	alias_attribute :fc1fb, :flow_cyto_cd34_text
	alias_attribute :fc1g, :flow_cyto_cd61
	alias_attribute :fc1gb, :flow_cyto_cd61_text
	alias_attribute :fc1h, :flow_cyto_cd14
	alias_attribute :fc1hb, :flow_cyto_cd14_text
	alias_attribute :fc1i, :flow_cyto_glycoA
	alias_attribute :fc1ib, :flow_cyto_glycoA_text
	alias_attribute :fc1j1, :flow_cyto_cd16
	alias_attribute :fc1j1b, :flow_cyto_cd16_text
	alias_attribute :fc1j2, :flow_cyto_cd56
	alias_attribute :fc1j2b, :flow_cyto_cd56_text
	alias_attribute :fc1j3, :flow_cyto_cd57
	alias_attribute :fc1j3b, :flow_cyto_cd57_text
	alias_attribute :fc1k1, :flow_cyto_cd9
	alias_attribute :fc1k1b, :flow_cyto_cd9_text
	alias_attribute :fc1k2, :flow_cyto_cd25
	alias_attribute :fc1k2b, :flow_cyto_cd25_text
	alias_attribute :fc1k3, :flow_cyto_cd38
	alias_attribute :fc1k3b, :flow_cyto_cd38_text
	alias_attribute :fc1k4, :flow_cyto_cd45
	alias_attribute :fc1k4b, :flow_cyto_cd45_text
	alias_attribute :fc1k5, :flow_cyto_cd71
	alias_attribute :fc1k5b, :flow_cyto_cd71_text
	alias_attribute :fc1l1, :flow_cyto_tdt
	alias_attribute :fc1l1b, :flow_cyto_tdt_text
	alias_attribute :fc1l2, :flow_cyto_hladr
	alias_attribute :fc1l2b, :flow_cyto_hladr_text
	alias_attribute :fc1l3a, :flow_cyto_other_marker_1_name
	alias_attribute :fc1l3b, :flow_cyto_other_marker_1
	alias_attribute :fc1l3c, :flow_cyto_other_marker_1_text
	alias_attribute :fc1l4a, :flow_cyto_other_marker_2_name
	alias_attribute :fc1l4b, :flow_cyto_other_marker_2
	alias_attribute :fc1l4c, :flow_cyto_other_marker_2_text
	alias_attribute :fc1l5a, :flow_cyto_other_marker_3_name
	alias_attribute :fc1l5b, :flow_cyto_other_marker_3
	alias_attribute :fc1l5c, :flow_cyto_other_marker_3_text
	alias_attribute :fc1l6a, :flow_cyto_other_marker_4_name
	alias_attribute :fc1l6b, :flow_cyto_other_marker_4
	alias_attribute :fc1l6c, :flow_cyto_other_marker_4_text
	alias_attribute :fc1l7a, :flow_cyto_other_marker_5_name
	alias_attribute :fc1l7b, :flow_cyto_other_marker_5
	alias_attribute :fc1l7c, :flow_cyto_other_marker_5_text
	alias_attribute :fc1m, :flow_cyto_remarks
	alias_attribute :fc2a, :Tdt_often_found_flow_cytometry
	alias_attribute :fc2b, :tdt_report_found
	alias_attribute :fc2c, :tdt_report_on
	alias_attribute :fc2d, :tdt_positive_or_negative
	alias_attribute :fc2e, :tdt_numerical_result
	alias_attribute :fc2f, :tdt_found_in_flow_cyto_chart
	alias_attribute :fc2g, :tdt_found_in_separate_report
	alias_attribute :fccomments, :response_comment_day_7
	alias_attribute :fccomments_14, :response_comment_day_14
	alias_attribute :fsh_convkaryodone, :cytogen_karyotype_done
	alias_attribute :fsh_hospfishdone, :cytogen_hospital_fish_done
	alias_attribute :fsh_hospresults, :hospital_fish_results
	alias_attribute :fsh_ucbfishdone, :cytogen_ucb_fish_done
	alias_attribute :fsh_ucbresults, :ucb_fish_results
	alias_attribute :hla_dr_14, :response_hladr_day_14
	alias_attribute :hla_dr_7, :response_hladr_day_7
	alias_attribute :hs1, :histo_report_found
	alias_attribute :hs2, :histo_report_on
	alias_attribute :hs3, :histo_report_results
	alias_attribute :id6, :diagnosed_on
	alias_attribute :id8, :treatment_began_on
	alias_attribute :inconclresults_14, :response_is_inconclusive_day_14
	alias_attribute :inconclresults_21, :response_is_inconclusive_day_21
	alias_attribute :inconclresults_28, :response_is_inconclusive_day_28
	alias_attribute :inconclresults_7, :response_is_inconclusive_day_7
	alias_attribute :nd4aid, :abstracted_by
	alias_attribute :nd4b, :abstracted_on
	alias_attribute :nd5aid, :reviewed_by
	alias_attribute :nd5b, :reviewed_on
	alias_attribute :nd6aid, :data_entry_by
	alias_attribute :nd6b, :data_entry_done_on
	alias_attribute :nd7, :abstract_version_number
	alias_attribute :numresultsavailable, :flow_cyto_num_results_available
	alias_attribute :other1_14, :response_other1_value_day_14
	alias_attribute :other1_7, :response_other1_value_day_7
	alias_attribute :other2_14, :response_other2_value_day_14
	alias_attribute :other2_7, :response_other2_value_day_7
	alias_attribute :other3_14, :response_other3_value_day_14
	alias_attribute :other4_14, :response_other4_value_day_14
	alias_attribute :other5_14, :response_other5_value_day_14
	alias_attribute :pe1, :h_and_p_reports_found
	alias_attribute :att12, :received_discharge_summary
	alias_attribute :pe14, :is_h_and_p_report_found
	alias_attribute :pe2, :h_and_p_reports_on
	alias_attribute :pe10, :physical_neuro
	alias_attribute :pe11, :physical_other_soft_2
	alias_attribute :pe12, :vital_status
	alias_attribute :pe12a, :dod
	alias_attribute :pe13b, :discharge_summary_found
	alias_attribute :pe3, :physical_gingival
	alias_attribute :pe4, :physical_leukemic_skin
	alias_attribute :pe5, :physical_lymph
	alias_attribute :pe6, :physical_spleen
	alias_attribute :pe8, :physical_testicle
	alias_attribute :pe9, :physical_other_soft
	alias_attribute :pl1, :ploidy_report_found
	alias_attribute :pl2, :ploidy_report_on
	alias_attribute :pl3, :is_hypodiploid
	alias_attribute :pl5, :is_hyperdiploid
	alias_attribute :pl6, :is_diploid
	alias_attribute :pl7, :dna_index
	alias_attribute :pl8, :other_dna_measure
	alias_attribute :pl9, :ploidy_comment
	alias_attribute :pehepa, :hepatomegaly_present
	alias_attribute :pespleno, :splenomegaly_present
	alias_attribute :remarks, :response_comment
	alias_attribute :specify1_14, :response_other1_name_day_14
	alias_attribute :specify1_7, :response_other1_name_day_7
	alias_attribute :specify2_14, :response_other2_name_day_14
	alias_attribute :specify2_7, :response_other2_name_day_7
	alias_attribute :specify3_14, :response_other3_name_day_14
	alias_attribute :specify4_14, :response_other4_name_day_14
	alias_attribute :specify5_14, :response_other5_name_day_14
	alias_attribute :sty1, :fab_classification
	alias_attribute :sty2, :diagnosis_icdO_description
	alias_attribute :sty2a, :diagnosis_icdO_number
	alias_attribute :sty3a, :cytogen_t1221
	alias_attribute :sty3b, :cytogen_inv16
	alias_attribute :sty3c, :cytogen_t119
	alias_attribute :sty3d, :cytogen_t821
	alias_attribute :sty3e, :cytogen_t1517
	alias_attribute :sty3f, :cytogen_is_hyperdiploidy
	alias_attribute :sty3f1, :cytogen_chromosome_number
	alias_attribute :sty3g, :cytogen_other_trans_1
	alias_attribute :sty3h, :cytogen_other_trans_2
	alias_attribute :sty3i, :cytogen_other_trans_3
	alias_attribute :sty3k, :cytogen_t922
	alias_attribute :sty3l, :cytogen_other_trans_4
	alias_attribute :sty3m, :cytogen_other_trans_5
	alias_attribute :subtype, :response_fab_subtype
	alias_attribute :termdoxy_14, :response_tdt_day_14
	alias_attribute :termdoxy_7, :response_tdt_day_7
	alias_attribute :versiondesc, :abstract_version_description
	alias_attribute :versionid, :abstract_version_id


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
