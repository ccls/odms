class CreateAbstracts < ActiveRecord::Migration
  def change
    create_table :abstracts do |t|


#	user ids
#	entry dates
#	merged flag

			t.string  :entry_1_by_uid
			t.string  :entry_2_by_uid
			t.string  :merged_by_uid

			t.integer :study_subject_id

			t.integer :bmb_report_found, :limit => 2
			t.date    :bmb_test_date
			t.integer :bmb_percentage_blasts_known, :limit => 2
			t.string  :bmb_percentage_blasts, :limit => 25
			t.text    :bmb_comments

			t.integer :bma_report_found, :limit => 2
			t.date    :bma_test_date
			t.integer :bma_percentage_blasts_known, :limit => 2
			t.string  :bma_percentage_blasts, :limit => 25
			t.text    :bma_comments

			t.integer :ccs_report_found, :limit => 2
			t.date    :ccs_test_date
			t.string  :ccs_peroxidase, :limit => 25
			t.string  :ccs_sudan_black, :limit => 25
			t.string  :ccs_periodic_acid_schiff, :limit => 25
			t.string  :ccs_chloroacetate_esterase, :limit => 25
			t.string  :ccs_non_specific_esterase, :limit => 25
			t.string  :ccs_alpha_naphthyl_butyrate_esterase, :limit => 25
			t.string  :ccs_toluidine_blue, :limit => 25
			t.string  :ccs_bcl_2, :limit => 25
			t.string  :ccs_other, :limit => 25

			t.integer :dfc_report_found, :limit => 2
			t.date    :dfc_test_date
			t.integer :dfc_numerical_data_available, :limit => 2

			t.string  :marker_bmk, :limit => 25
			t.string  :marker_bml, :limit => 25
			t.string  :marker_cd10, :limit => 25
			t.string  :marker_cd11b, :limit => 25
			t.string  :marker_cd11c, :limit => 25
			t.string  :marker_cd13, :limit => 25
			t.string  :marker_cd14, :limit => 25
			t.string  :marker_cd15, :limit => 25
			t.string  :marker_cd16, :limit => 25
			t.string  :marker_cd19, :limit => 25
			t.string  :marker_cd19_cd10, :limit => 25
			t.string  :marker_cd1a, :limit => 25
			t.string  :marker_cd2, :limit => 25
			t.string  :marker_cd20, :limit => 25
			t.string  :marker_cd21, :limit => 25
			t.string  :marker_cd22, :limit => 25
			t.string  :marker_cd23, :limit => 25
			t.string  :marker_cd24, :limit => 25
			t.string  :marker_cd25, :limit => 25
			t.string  :marker_cd3, :limit => 25
			t.string  :marker_cd33, :limit => 25
			t.string  :marker_cd34, :limit => 25
			t.string  :marker_cd38, :limit => 25
			t.string  :marker_cd3_cd4, :limit => 25
			t.string  :marker_cd3_cd8, :limit => 25
			t.string  :marker_cd4, :limit => 25
			t.string  :marker_cd40, :limit => 25
			t.string  :marker_cd41, :limit => 25
			t.string  :marker_cd45, :limit => 25
			t.string  :marker_cd5, :limit => 25
			t.string  :marker_cd56, :limit => 25
			t.string  :marker_cd57, :limit => 25
			t.string  :marker_cd61, :limit => 25
			t.string  :marker_cd7, :limit => 25
			t.string  :marker_cd71, :limit => 25
			t.string  :marker_cd8, :limit => 25
			t.string  :marker_cd9, :limit => 25
			t.string  :marker_cdw65, :limit => 25
			t.string  :marker_glycophorin_a, :limit => 25
			t.string  :marker_hla_dr, :limit => 25
			t.string  :marker_igm, :limit => 25
			t.string  :marker_sig, :limit => 25
			t.string  :marker_tdt, :limit => 25
			t.text    :other_markers
			t.text    :marker_comments

			t.integer :tdt_report_found, :limit => 2
			t.date    :tdt_test_date

			t.string  :tdt_found_where, :limit => 25
			t.string  :tdt_result, :limit => 25
			t.string  :tdt_numerical_result, :limit => 25


			t.integer :ploidy_report_found, :limit => 2
			t.date    :ploidy_test_date
			t.string  :ploidy_found_where, :limit => 25

			t.string  :ploidy_hypodiploid, :limit => 25
			t.string  :ploidy_pseudodiploid, :limit => 25
			t.string  :ploidy_hyperdiploid, :limit => 25
			t.string  :ploidy_diploid, :limit => 25
			t.string  :ploidy_dna_index, :limit => 25
			t.text    :ploidy_other_dna_measurement
			t.text    :ploidy_notes


			t.integer :hla_report_found, :limit => 2
			t.date    :hla_test_date
			t.text    :hla_results

			t.integer :cgs_report_found, :limit => 2
			t.date    :cgs_test_date
			t.integer :cgs_normal, :limit => 2
			t.integer :cgs_conventional_karyotype_done, :limit => 2
			t.integer :cgs_hospital_fish_done, :limit => 2
			t.integer :cgs_hyperdiploidy_detected, :limit => 2
			t.string  :cgs_hyperdiploidy_by, :limit => 25
			t.string  :cgs_hyperdiploidy_number_of_chromosomes, :limit => 25



#	integers? YNDK?

			t.integer :cgs_t12_21, :limit => 2
			t.integer :cgs_inv16, :limit => 2
			t.integer :cgs_t1_19, :limit => 2
			t.integer :cgs_t8_21, :limit => 2
			t.integer :cgs_t9_22, :limit => 2
			t.integer :cgs_t15_17, :limit => 2
			t.integer :cgs_trisomy_4, :limit => 2
			t.integer :cgs_trisomy_5, :limit => 2
			t.integer :cgs_trisomy_10, :limit => 2
			t.integer :cgs_trisomy_17, :limit => 2
			t.integer :cgs_trisomy_21, :limit => 2


			t.integer :cgs_t4_11_q21_q23, :limit => 2
			t.integer :cgs_deletion_6q, :limit => 2
			t.integer :cgs_deletion_9p, :limit => 2
			t.integer :cgs_t16_16_p13_q22, :limit => 2
			t.integer :cgs_trisomy_8, :limit => 2
			t.integer :cgs_trisomy_x, :limit => 2
			t.integer :cgs_trisomy_6, :limit => 2
			t.integer :cgs_trisomy_14, :limit => 2
			t.integer :cgs_trisomy_18, :limit => 2
			t.integer :cgs_monosomy_7, :limit => 2
			t.integer :cgs_deletion_16_q22, :limit => 2
			t.text    :cgs_others






			t.text    :cgs_conventional_karyotyping_results
			t.text    :cgs_hospital_fish_results
			t.text    :cgs_comments

			t.integer :omg_abnormalities_found, :limit => 2
			t.date    :omg_test_date

			t.string  :omg_p16, :limit => 25
			t.string  :omg_p15, :limit => 25
			t.string  :omg_p53, :limit => 25
			t.string  :omg_ras, :limit => 25
			t.string  :omg_all1, :limit => 25
			t.string  :omg_wt1, :limit => 25
			t.string  :omg_bcr, :limit => 25
			t.string  :omg_etv6, :limit => 25
			t.string  :omg_fish,  :limit => 25

			t.integer :em_report_found, :limit => 2
			t.date    :em_test_date
			t.text    :em_comments

			t.integer :cbc_report_found, :limit => 2
			t.date    :cbc_test_date
			t.string  :cbc_hemoglobin, :limit => 25
			t.string  :cbc_leukocyte_count, :limit => 25
			t.string  :cbc_number_of_blasts, :limit => 25
			t.string  :cbc_percentage_blasts, :limit => 25
			t.string  :cbc_platelet_count, :limit => 25

			t.integer :csf_report_found, :limit => 2
			t.date    :csf_test_date
			t.integer :csf_blasts_present, :limit => 2
			t.text    :csf_cytology
			t.string  :csf_number_of_blasts, :limit => 25
			t.integer :csf_pb_contamination, :limit => 2
			t.string  :csf_rbc, :limit => 25
			t.string  :csf_wbc, :limit => 25

			t.integer :ob_skin_report_found, :limit => 2
			t.date    :ob_skin_date
			t.integer :ob_skin_leukemic_cells_present, :limit => 2

			t.integer :ob_lymph_node_report_found, :limit => 2
			t.date    :ob_lymph_node_date
			t.integer :ob_lymph_node_leukemic_cells_present, :limit => 2

			t.integer :ob_liver_report_found, :limit => 2
			t.date    :ob_liver_date
			t.integer :ob_liver_leukemic_cells_present, :limit => 2

			t.integer :ob_other_report_found, :limit => 2
			t.date    :ob_other_date
			t.string  :ob_other_site_organ
			t.integer :ob_other_leukemic_cells_present, :limit => 2

			t.integer :cxr_report_found, :limit => 2
			t.date    :cxr_test_date
			t.string  :cxr_result, :limit => 25
			t.text    :cxr_mediastinal_mass_description

			t.integer :cct_report_found, :limit => 2
			t.date    :cct_test_date
			t.string  :cct_result, :limit => 25
			t.text    :cct_mediastinal_mass_description

			t.integer :as_report_found, :limit => 2
			t.date    :as_test_date
			t.integer :as_normal, :limit => 2
			t.integer :as_sphenomegaly, :limit => 2
			t.integer :as_hepatomegaly, :limit => 2
			t.integer :as_lymphadenopathy, :limit => 2
			t.integer :as_other_abdominal_masses, :limit => 2
			t.integer :as_ascities, :limit => 2
			t.text    :as_other_abnormal_findings

			t.integer :ts_report_found, :limit => 2
			t.date    :ts_test_date
			t.text    :ts_findings

			t.integer :hpr_report_found, :limit => 2
			t.date    :hpr_test_date
			t.integer :hpr_hepatomegaly, :limit => 2
			t.integer :hpr_splenomegaly, :limit => 2
			t.integer :hpr_down_syndrome_phenotype, :limit => 2

			t.string  :height, :limit => 10
			t.string  :height_units, :limit => 5
			t.string  :weight, :limit => 10
			t.string  :weight_units	, :limit => 5

			t.integer :ds_report_found, :limit => 2
			t.date    :ds_test_date
			t.text    :ds_clinical_diagnosis

			t.integer :cp_report_found, :limit => 2
			t.integer :cp_induction_protocol_used, :limit => 2

			t.string  :cp_induction_protocol_name_and_number
			t.text    :cp_therapeutic_agents

			t.integer :bma07_report_found, :limit => 2
			t.date    :bma07_test_date
			t.string  :bma07_classification, :limit => 25
			t.boolean :bma07_inconclusive_results
			t.string  :bma07_percentage_of_blasts, :limit => 25

			t.integer :bma14_report_found, :limit => 2
			t.date    :bma14_test_date
			t.string  :bma14_classification, :limit => 25
			t.boolean :bma14_inconclusive_results
			t.string  :bma14_percentage_of_blasts, :limit => 25

			t.integer :bma28_report_found, :limit => 2
			t.date    :bma28_test_date
			t.string  :bma28_classification, :limit => 25
			t.boolean :bma28_inconclusive_results
			t.string  :bma28_percentage_of_blasts, :limit => 25

			t.integer :clinical_remission, :limit => 2

			t.string  :leukemia_class, :limit => 25
			t.string  :other_all_leukemia_class, :limit => 25
			t.string  :other_aml_leukemia_class, :limit => 25

			t.string  :icdo_classification_number, :limit => 25
			t.text    :icdo_classification_description
			t.string  :leukemia_lineage, :limit => 25

			t.integer :pe_report_found, :limit => 2
			t.date    :pe_test_date
			t.integer :pe_gingival_infiltrates, :limit => 2
			t.integer :pe_leukemic_skin_infiltrates, :limit => 2
			t.integer :pe_lymphadenopathy, :limit => 2
			t.text    :pe_lymphadenopathy_description
			t.integer :pe_splenomegaly, :limit => 2
			t.string  :pe_splenomegaly_size
			t.integer :pe_hepatomegaly, :limit => 2
			t.string  :pe_hepatomegaly_size
			t.integer :pe_testicular_mass, :limit => 2
			t.integer :pe_other_soft_tissue, :limit => 2
			t.string  :pe_other_soft_tissue_location
			t.string  :pe_other_soft_tissue_size
			t.text    :pe_neurological_abnormalities
			t.text    :pe_other_abnormal_findings

			t.string  :abstracted_by
			t.date    :abstracted_on
			t.string  :reviewed_by
			t.date    :reviewed_on

      t.timestamps
    end
  end
end
