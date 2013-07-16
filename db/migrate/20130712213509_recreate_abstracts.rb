class RecreateAbstracts < ActiveRecord::Migration
  def change


#	This is still VERY incomplete!!!

#	make many of these YNDK integers	(smallint ... -32000 to 32000 )
#	conventionalize the field names
#	drop the double negatives


    create_table :abstracts do |t|

			t.integer :study_subject_id

			t.integer :bmb_report_found, :limit => 2
			t.date   :bmb_test_date
			t.integer :bmb_percentage_blasts_known, :limit => 2
			t.string :bmb_percentage_blasts, :limit => 25
			t.text   :bmb_comments

			t.integer :bma_report_found, :limit => 2
			t.date   :bma_test_date
			t.integer :bma_percentage_blasts_known, :limit => 2
			t.string :bma_percentage_blasts, :limit => 25
			t.text   :bma_comments

			t.integer :dfc_report_found, :limit => 2
			t.date   :dfc_test_date
			t.integer :dfc_numerical_data_available, :limit => 2

			t.string :marker_bmk, :limit => 25
			t.string :marker_bml, :limit => 25
			t.string :marker_cd10, :limit => 25
			t.string :marker_cd11b, :limit => 25
			t.string :marker_cd11c, :limit => 25
			t.string :marker_cd13, :limit => 25
			t.string :marker_cd14, :limit => 25
			t.string :marker_cd15, :limit => 25
			t.string :marker_cd16, :limit => 25
			t.string :marker_cd19, :limit => 25
			t.string :marker_cd19_cd10, :limit => 25
			t.string :marker_cd1a, :limit => 25
			t.string :marker_cd2, :limit => 25
			t.string :marker_cd20, :limit => 25
			t.string :marker_cd21, :limit => 25
			t.string :marker_cd22, :limit => 25
			t.string :marker_cd23, :limit => 25
			t.string :marker_cd24, :limit => 25
			t.string :marker_cd25, :limit => 25
			t.string :marker_cd3, :limit => 25
			t.string :marker_cd33, :limit => 25
			t.string :marker_cd34, :limit => 25
			t.string :marker_cd38, :limit => 25
			t.string :marker_cd3_cd4, :limit => 25
			t.string :marker_cd3_cd8, :limit => 25
			t.string :marker_cd4, :limit => 25
			t.string :marker_cd40, :limit => 25
			t.string :marker_cd41, :limit => 25
			t.string :marker_cd45, :limit => 25
			t.string :marker_cd5, :limit => 25
			t.string :marker_cd56, :limit => 25
			t.string :marker_cd57, :limit => 25
			t.string :marker_cd61, :limit => 25
			t.string :marker_cd7, :limit => 25
			t.string :marker_cd71, :limit => 25
			t.string :marker_cd8, :limit => 25
			t.string :marker_cd9, :limit => 25
			t.string :marker_cdw65, :limit => 25
			t.string :marker_glycophorin_a, :limit => 25
			t.string :marker_hla_dr, :limit => 25
			t.string :marker_igm, :limit => 25
			t.string :marker_sig, :limit => 25
			t.string :marker_tdt, :limit => 25
			t.text   :other_markers
			t.text   :marker_comments

			t.integer :tdt_report_found, :limit => 2
			t.date   :tdt_test_date

			t.string :tdt_found_in_cytometry							#	FIX ME
			t.string :tdt_found_separately							#	FIX ME
			t.string :tdt_negative							#	FIX ME
			t.string :tdt_numerical_result							#	FIX ME
			t.string :tdt_positive							#	FIX ME


			t.integer :ploidy_report_found, :limit => 2
			t.date   :ploidy_test_date
			t.string :ploidy_found_in_cytometry							#	FIX ME
			t.string :ploidy_found_separately							#	FIX ME


			t.integer :hla_report_found, :limit => 2
			t.date   :hla_test_date
			t.text   :hla_results

			t.integer :cs_report_found, :limit => 2
			t.date   :cs_test_date
			t.integer :cs_conventional_karyotype_done, :limit => 2
			t.integer :cs_hospital_fish_done, :limit => 2
			t.integer :cs_hyperdiploidy_detected, :limit => 2
			t.string :cs_hyperdiploidy_by, :limit => 25
			t.string :cs_hyperdiploidy_number_of_chromosomes, :limit => 25

			t.integer :translocation_t12_21, :limit => 2
			t.integer :translocation_inv16, :limit => 2
			t.integer :translocation_t1_19, :limit => 2
			t.integer :translocation_t8_21, :limit => 2
			t.integer :translocation_t9_22, :limit => 2
			t.integer :translocation_t15_17, :limit => 2
			t.integer :trisomy_4, :limit => 2
			t.integer :trisomy_5, :limit => 2
			t.integer :trisomy_10, :limit => 2
			t.integer :trisomy_17, :limit => 2
			t.integer :trisomy_21, :limit => 2

			t.text   :cs_conventional_karyotyping_results
			t.text   :cs_hospital_fish_results

			t.integer :cbc_report_found, :limit => 2
			t.date   :cbc_test_date
			t.string :cbc_hemoglobin, :limit => 25
			t.string :cbc_leukocyte_count, :limit => 25
			t.string :cbc_number_of_blasts, :limit => 25
			t.string :cbc_percentage_blasts, :limit => 25
			t.string :cbc_platelet_count, :limit => 25

			t.integer :csf_report_found, :limit => 2
			t.date   :csf_test_date
			t.string :csf_blasts_present, :limit => 25
			t.text   :csf_cytology
			t.string :csf_number_of_blasts, :limit => 25
			t.string :csf_pb_contamination, :limit => 25
			t.string :csf_rbc, :limit => 25
			t.string :csf_wbc, :limit => 25

			t.integer :cxr_report_found, :limit => 2
			t.date   :cxr_test_date
			t.string :cxr_result, :limit => 25
			t.text   :cxr_mediastinal_mass_description

			t.integer :hpr_report_found, :limit => 2
			t.date   :hpr_test_date
			t.integer :hpr_hepatomegaly, :limit => 2
			t.integer :hpr_splenomegaly, :limit => 2
			t.integer :hpr_down_syndrome_phenotype, :limit => 2

			t.string :height_in_cm, :limit => 25
			t.string :height_in_in, :limit => 25
			t.string :weight_in_kg, :limit => 25
			t.string :weight_in_lb	, :limit => 25

			t.integer :ds_report_found, :limit => 2
			t.date   :ds_test_date
			t.text   :ds_clinical_diagnosis

			t.integer :cp_report_found, :limit => 2
			t.integer :cp_induction_protocol, :limit => 2

			t.string :cp_induction_protocol_name_and_number
			t.text   :cp_therapeutic_agents

			t.integer :bma07_report_found, :limit => 2
			t.date   :bma07_test_date
			t.string :bma07_classification, :limit => 25
			t.string :bma07_inconclusive_results, :limit => 25								#	FIX THIS
			t.string :bma07_percentage_of_blasts, :limit => 25

			t.integer :bma14_report_found, :limit => 2
			t.date   :bma14_test_date
			t.string :bma14_classification, :limit => 25
			t.string :bma14_inconclusive_results, :limit => 25							#	FIX ME
			t.string :bma14_percentage_of_blasts, :limit => 25

			t.integer :bma28_report_found, :limit => 2
			t.date   :bma28_test_date
			t.string :bma28_classification, :limit => 25
			t.string :bma28_inconclusive_results, :limit => 25							#	FIX ME
			t.string :bma28_percentage_of_blasts, :limit => 25

			t.integer :clinical_remission, :limit => 2

			t.string :leukemia_class, :limit => 25
			t.string :other_all_leukemia_class, :limit => 25
			t.string :other_aml_leukemia_class, :limit => 25

			t.string :icdo_classification_number, :limit => 25
			t.text   :icdo_classification_description
			t.string :leukemia_lineage, :limit => 25

      t.timestamps
    end
  end
end
