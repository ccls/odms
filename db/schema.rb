# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120514172723) do

  create_table "abstracts", :force => true do |t|
    t.integer  "study_subject_id"
    t.integer  "response_day14or28_flag"
    t.integer  "received_bone_marrow_biopsy"
    t.integer  "received_h_and_p"
    t.integer  "received_other_reports"
    t.integer  "received_discharge_summary"
    t.integer  "received_chemo_protocol"
    t.integer  "received_resp_to_therapy"
    t.text     "received_specify_other_reports"
    t.integer  "received_bone_marrow_aspirate"
    t.integer  "received_flow_cytometry"
    t.integer  "received_ploidy"
    t.integer  "received_hla_typing"
    t.integer  "received_cytogenetics"
    t.integer  "received_cbc"
    t.integer  "received_csf"
    t.integer  "received_chest_xray"
    t.integer  "response_report_found_day_14"
    t.integer  "response_report_found_day_28"
    t.integer  "response_report_found_day_7"
    t.date     "response_report_on_day_14"
    t.date     "response_report_on_day_28"
    t.date     "response_report_on_day_7"
    t.string   "response_classification_day_14",             :limit => 2
    t.string   "response_classification_day_28",             :limit => 2
    t.string   "response_classification_day_7",              :limit => 2
    t.integer  "response_blasts_day_14"
    t.integer  "response_blasts_day_28"
    t.integer  "response_blasts_day_7"
    t.string   "response_blasts_units_day_14",               :limit => 15
    t.string   "response_blasts_units_day_28",               :limit => 15
    t.string   "response_blasts_units_day_7",                :limit => 15
    t.integer  "response_in_remission_day_14"
    t.integer  "marrow_biopsy_report_found"
    t.date     "marrow_biopsy_on"
    t.text     "marrow_biopsy_diagnosis"
    t.integer  "marrow_aspirate_report_found"
    t.date     "marrow_aspirate_taken_on"
    t.text     "marrow_aspirate_diagnosis"
    t.integer  "response_marrow_kappa_day_14"
    t.integer  "response_marrow_kappa_day_7"
    t.integer  "response_marrow_lambda_day_14"
    t.integer  "response_marrow_lambda_day_7"
    t.integer  "cbc_report_found"
    t.date     "cbc_report_on"
    t.decimal  "cbc_white_blood_count",                                     :precision => 10, :scale => 0
    t.integer  "cbc_percent_blasts"
    t.integer  "cbc_number_blasts"
    t.decimal  "cbc_hemoglobin_level",                                      :precision => 10, :scale => 0
    t.integer  "cbc_platelet_count"
    t.integer  "cerebrospinal_fluid_report_found"
    t.date     "csf_report_on"
    t.integer  "csf_white_blood_count"
    t.text     "csf_white_blood_count_text"
    t.integer  "csf_red_blood_count"
    t.string   "csf_red_blood_count_text"
    t.string   "blasts_are_present"
    t.integer  "number_of_blasts"
    t.string   "peripheral_blood_in_csf"
    t.text     "csf_comment"
    t.integer  "chemo_protocol_report_found"
    t.integer  "patient_on_chemo_protocol"
    t.string   "chemo_protocol_name"
    t.text     "chemo_protocol_agent_description"
    t.string   "response_cd10_day_14",                       :limit => 10
    t.string   "response_cd10_day_7",                        :limit => 10
    t.string   "response_cd13_day_14",                       :limit => 10
    t.string   "response_cd13_day_7",                        :limit => 10
    t.string   "response_cd14_day_14",                       :limit => 10
    t.string   "response_cd14_day_7",                        :limit => 10
    t.string   "response_cd15_day_14",                       :limit => 10
    t.string   "response_cd15_day_7",                        :limit => 10
    t.string   "response_cd19_day_14",                       :limit => 10
    t.string   "response_cd19_day_7",                        :limit => 10
    t.string   "response_cd19cd10_day_14",                   :limit => 10
    t.string   "response_cd19cd10_day_7",                    :limit => 10
    t.string   "response_cd1a_day_14",                       :limit => 10
    t.string   "response_cd2a_day_14",                       :limit => 10
    t.string   "response_cd20_day_14",                       :limit => 10
    t.string   "response_cd20_day_7",                        :limit => 10
    t.string   "response_cd3a_day_14",                       :limit => 10
    t.string   "response_cd3_day_7",                         :limit => 10
    t.string   "response_cd33_day_14",                       :limit => 10
    t.string   "response_cd33_day_7",                        :limit => 10
    t.string   "response_cd34_day_14",                       :limit => 10
    t.string   "response_cd34_day_7",                        :limit => 10
    t.string   "response_cd4a_day_14",                       :limit => 10
    t.string   "response_cd5a_day_14",                       :limit => 10
    t.string   "response_cd56_day_14",                       :limit => 10
    t.string   "response_cd61_day_14",                       :limit => 10
    t.string   "response_cd7a_day_14",                       :limit => 10
    t.string   "response_cd8a_day_14",                       :limit => 10
    t.integer  "response_day30_is_in_remission"
    t.integer  "chest_imaging_report_found"
    t.date     "chest_imaging_report_on"
    t.integer  "mediastinal_mass_present"
    t.text     "chest_imaging_comment"
    t.integer  "received_chest_ct"
    t.date     "chest_ct_taken_on"
    t.integer  "chest_ct_medmass_present"
    t.integer  "cytogen_trisomy10"
    t.integer  "cytogen_trisomy17"
    t.integer  "cytogen_trisomy21"
    t.integer  "is_down_syndrome_phenotype"
    t.integer  "cytogen_trisomy4"
    t.integer  "cytogen_trisomy5"
    t.integer  "cytogen_report_found"
    t.date     "cytogen_report_on"
    t.string   "conventional_karyotype_results"
    t.string   "normal_cytogen",                             :limit => 5
    t.string   "is_cytogen_hosp_fish_t1221_done",            :limit => 5
    t.string   "is_karyotype_normal",                        :limit => 5
    t.integer  "number_normal_metaphase_karyotype"
    t.integer  "number_metaphase_tested_karyotype"
    t.text     "cytogen_comment"
    t.boolean  "is_verification_complete"
    t.text     "discharge_summary"
    t.integer  "diagnosis_is_b_all"
    t.integer  "diagnosis_is_t_all"
    t.integer  "diagnosis_is_all"
    t.integer  "diagnosis_all_type_id"
    t.integer  "diagnosis_is_cml"
    t.integer  "diagnosis_is_cll"
    t.integer  "diagnosis_is_aml"
    t.integer  "diagnosis_aml_type_id"
    t.integer  "diagnosis_is_other"
    t.integer  "flow_cyto_report_found"
    t.integer  "received_flow_cyto_day_14"
    t.integer  "received_flow_cyto_day_7"
    t.date     "flow_cyto_report_on"
    t.date     "response_flow_cyto_day_14_on"
    t.date     "response_flow_cyto_day_7_on"
    t.string   "flow_cyto_cd10",                             :limit => 10
    t.string   "flow_cyto_igm",                              :limit => 10
    t.string   "flow_cyto_igm_text",                         :limit => 50
    t.string   "flow_cyto_bm_kappa",                         :limit => 10
    t.string   "flow_cyto_bm_kappa_text",                    :limit => 50
    t.string   "flow_cyto_bm_lambda",                        :limit => 10
    t.string   "flow_cyto_bm_lambda_text",                   :limit => 50
    t.string   "flow_cyto_cd10_19",                          :limit => 10
    t.string   "flow_cyto_cd10_19_text",                     :limit => 50
    t.string   "flow_cyto_cd10_text",                        :limit => 50
    t.string   "flow_cyto_cd19",                             :limit => 10
    t.string   "flow_cyto_cd19_text",                        :limit => 50
    t.string   "flow_cyto_cd20",                             :limit => 10
    t.string   "flow_cyto_cd20_text",                        :limit => 50
    t.string   "flow_cyto_cd21",                             :limit => 10
    t.string   "flow_cyto_cd21_text",                        :limit => 50
    t.string   "flow_cyto_cd22",                             :limit => 10
    t.string   "flow_cyto_cd22_text",                        :limit => 50
    t.string   "flow_cyto_cd23",                             :limit => 10
    t.string   "flow_cyto_cd23_text",                        :limit => 50
    t.string   "flow_cyto_cd24",                             :limit => 10
    t.string   "flow_cyto_cd24_text",                        :limit => 50
    t.string   "flow_cyto_cd40",                             :limit => 10
    t.string   "flow_cyto_cd40_text",                        :limit => 50
    t.string   "flow_cyto_surface_ig",                       :limit => 10
    t.string   "flow_cyto_surface_ig_text",                  :limit => 50
    t.string   "flow_cyto_cd1a",                             :limit => 10
    t.string   "flow_cyto_cd1a_text",                        :limit => 50
    t.string   "flow_cyto_cd2",                              :limit => 10
    t.string   "flow_cyto_cd2_text",                         :limit => 50
    t.string   "flow_cyto_cd3",                              :limit => 10
    t.string   "flow_cyto_cd3_text",                         :limit => 50
    t.string   "flow_cyto_cd4",                              :limit => 10
    t.string   "flow_cyto_cd4_text",                         :limit => 50
    t.string   "flow_cyto_cd5",                              :limit => 10
    t.string   "flow_cyto_cd5_text",                         :limit => 50
    t.string   "flow_cyto_cd7",                              :limit => 10
    t.string   "flow_cyto_cd7_text",                         :limit => 50
    t.string   "flow_cyto_cd8",                              :limit => 10
    t.string   "flow_cyto_cd8_text",                         :limit => 50
    t.string   "flow_cyto_cd3_cd4",                          :limit => 10
    t.string   "flow_cyto_cd3_cd4_text",                     :limit => 50
    t.string   "flow_cyto_cd3_cd8",                          :limit => 10
    t.string   "flow_cyto_cd3_cd8_text",                     :limit => 50
    t.string   "flow_cyto_cd11b",                            :limit => 10
    t.string   "flow_cyto_cd11b_text",                       :limit => 50
    t.string   "flow_cyto_cd11c",                            :limit => 10
    t.string   "flow_cyto_cd11c_text",                       :limit => 50
    t.string   "flow_cyto_cd13",                             :limit => 10
    t.string   "flow_cyto_cd13_text",                        :limit => 50
    t.string   "flow_cyto_cd15",                             :limit => 10
    t.string   "flow_cyto_cd15_text",                        :limit => 50
    t.string   "flow_cyto_cd33",                             :limit => 10
    t.string   "flow_cyto_cd33_text",                        :limit => 50
    t.string   "flow_cyto_cd41",                             :limit => 10
    t.string   "flow_cyto_cd41_text",                        :limit => 50
    t.string   "flow_cyto_cdw65",                            :limit => 10
    t.string   "flow_cyto_cdw65_text",                       :limit => 50
    t.string   "flow_cyto_cd34",                             :limit => 10
    t.string   "flow_cyto_cd34_text",                        :limit => 50
    t.string   "flow_cyto_cd61",                             :limit => 10
    t.string   "flow_cyto_cd61_text",                        :limit => 50
    t.string   "flow_cyto_cd14",                             :limit => 10
    t.string   "flow_cyto_cd14_text",                        :limit => 50
    t.string   "flow_cyto_glycoa",                           :limit => 10
    t.string   "flow_cyto_glycoa_text",                      :limit => 50
    t.string   "flow_cyto_cd16",                             :limit => 10
    t.string   "flow_cyto_cd16_text",                        :limit => 50
    t.string   "flow_cyto_cd56",                             :limit => 10
    t.string   "flow_cyto_cd56_text",                        :limit => 50
    t.string   "flow_cyto_cd57",                             :limit => 10
    t.string   "flow_cyto_cd57_text",                        :limit => 50
    t.string   "flow_cyto_cd9",                              :limit => 10
    t.string   "flow_cyto_cd9_text",                         :limit => 50
    t.string   "flow_cyto_cd25",                             :limit => 10
    t.string   "flow_cyto_cd25_text",                        :limit => 50
    t.string   "flow_cyto_cd38",                             :limit => 10
    t.string   "flow_cyto_cd38_text",                        :limit => 50
    t.string   "flow_cyto_cd45",                             :limit => 10
    t.string   "flow_cyto_cd45_text",                        :limit => 50
    t.string   "flow_cyto_cd71",                             :limit => 10
    t.string   "flow_cyto_cd71_text",                        :limit => 50
    t.string   "flow_cyto_tdt",                              :limit => 10
    t.string   "flow_cyto_tdt_text",                         :limit => 50
    t.string   "flow_cyto_hladr",                            :limit => 10
    t.string   "flow_cyto_hladr_text",                       :limit => 50
    t.string   "flow_cyto_other_marker_1_name",              :limit => 20
    t.string   "flow_cyto_other_marker_1",                   :limit => 4
    t.string   "flow_cyto_other_marker_1_text",              :limit => 50
    t.string   "flow_cyto_other_marker_2_name",              :limit => 20
    t.string   "flow_cyto_other_marker_2",                   :limit => 4
    t.string   "flow_cyto_other_marker_2_text",              :limit => 50
    t.string   "flow_cyto_other_marker_3_name",              :limit => 20
    t.string   "flow_cyto_other_marker_3",                   :limit => 4
    t.string   "flow_cyto_other_marker_3_text",              :limit => 50
    t.string   "flow_cyto_other_marker_4_name",              :limit => 20
    t.string   "flow_cyto_other_marker_4",                   :limit => 4
    t.string   "flow_cyto_other_marker_4_text",              :limit => 50
    t.string   "flow_cyto_other_marker_5_name",              :limit => 20
    t.string   "flow_cyto_other_marker_5",                   :limit => 4
    t.string   "flow_cyto_other_marker_5_text",              :limit => 50
    t.text     "flow_cyto_remarks"
    t.integer  "tdt_often_found_flow_cytometry"
    t.integer  "tdt_report_found"
    t.date     "tdt_report_on"
    t.integer  "tdt_positive_or_negative"
    t.integer  "tdt_numerical_result"
    t.boolean  "tdt_found_in_flow_cyto_chart"
    t.boolean  "tdt_found_in_separate_report"
    t.text     "response_comment_day_7"
    t.text     "response_comment_day_14"
    t.integer  "cytogen_karyotype_done"
    t.integer  "cytogen_hospital_fish_done"
    t.string   "hospital_fish_results"
    t.integer  "cytogen_ucb_fish_done"
    t.string   "ucb_fish_results",                           :limit => 50
    t.string   "response_hladr_day_14",                      :limit => 10
    t.string   "response_hladr_day_7",                       :limit => 10
    t.integer  "histo_report_found"
    t.date     "histo_report_on"
    t.text     "histo_report_results"
    t.date     "diagnosed_on"
    t.date     "treatment_began_on"
    t.integer  "response_is_inconclusive_day_14"
    t.integer  "response_is_inconclusive_day_21"
    t.integer  "response_is_inconclusive_day_28"
    t.integer  "response_is_inconclusive_day_7"
    t.integer  "abstractor_id"
    t.date     "abstracted_on"
    t.integer  "reviewer_id"
    t.date     "reviewed_on"
    t.date     "data_entry_done_on"
    t.integer  "flow_cyto_num_results_available"
    t.string   "response_other1_value_day_14",               :limit => 4
    t.string   "response_other1_value_day_7",                :limit => 4
    t.string   "response_other2_value_day_14",               :limit => 4
    t.string   "response_other2_value_day_7",                :limit => 4
    t.string   "response_other3_value_day_14",               :limit => 4
    t.string   "response_other4_value_day_14",               :limit => 4
    t.string   "response_other5_value_day_14",               :limit => 4
    t.integer  "h_and_p_reports_found"
    t.boolean  "is_h_and_p_report_found"
    t.date     "h_and_p_reports_on"
    t.string   "physical_neuro",                             :limit => 5
    t.string   "physical_other_soft_2",                      :limit => 5
    t.integer  "vital_status_id"
    t.date     "dod"
    t.integer  "discharge_summary_found"
    t.string   "physical_gingival",                          :limit => 5
    t.string   "physical_leukemic_skin",                     :limit => 5
    t.string   "physical_lymph",                             :limit => 5
    t.string   "physical_spleen",                            :limit => 5
    t.string   "physical_testicle",                          :limit => 5
    t.string   "physical_other_soft",                        :limit => 5
    t.integer  "ploidy_report_found"
    t.date     "ploidy_report_on"
    t.string   "is_hypodiploid",                             :limit => 5
    t.string   "is_hyperdiploid",                            :limit => 5
    t.string   "is_diploid",                                 :limit => 5
    t.string   "dna_index",                                  :limit => 5
    t.string   "other_dna_measure",                          :limit => 15
    t.string   "ploidy_comment",                             :limit => 100
    t.integer  "hepatomegaly_present"
    t.integer  "splenomegaly_present"
    t.text     "response_comment"
    t.string   "response_other1_name_day_14",                :limit => 25
    t.string   "response_other1_name_day_7",                 :limit => 25
    t.string   "response_other2_name_day_14",                :limit => 25
    t.string   "response_other2_name_day_7",                 :limit => 25
    t.string   "response_other3_name_day_14",                :limit => 25
    t.string   "response_other4_name_day_14",                :limit => 25
    t.string   "response_other5_name_day_14",                :limit => 25
    t.string   "fab_classification",                         :limit => 50
    t.string   "diagnosis_icdo_description",                 :limit => 55
    t.string   "diagnosis_icdo_number",                      :limit => 50
    t.string   "cytogen_t1221",                              :limit => 9
    t.string   "cytogen_inv16",                              :limit => 9
    t.string   "cytogen_t119",                               :limit => 9
    t.string   "cytogen_t821",                               :limit => 9
    t.string   "cytogen_t1517",                              :limit => 9
    t.string   "cytogen_is_hyperdiploidy",                   :limit => 5
    t.string   "cytogen_chromosome_number",                  :limit => 3
    t.string   "cytogen_other_trans_1",                      :limit => 35
    t.string   "cytogen_other_trans_2",                      :limit => 35
    t.string   "cytogen_other_trans_3",                      :limit => 35
    t.string   "cytogen_other_trans_4",                      :limit => 35
    t.string   "cytogen_other_trans_5",                      :limit => 35
    t.string   "cytogen_other_trans_6",                      :limit => 35
    t.string   "cytogen_other_trans_7",                      :limit => 35
    t.string   "cytogen_other_trans_8",                      :limit => 35
    t.string   "cytogen_other_trans_9",                      :limit => 35
    t.string   "cytogen_other_trans_10",                     :limit => 35
    t.string   "cytogen_t922",                               :limit => 50
    t.string   "response_fab_subtype",                       :limit => 15
    t.string   "response_tdt_day_14",                        :limit => 10
    t.string   "response_tdt_day_7",                         :limit => 10
    t.integer  "abstract_version_id"
    t.float    "height_at_diagnosis"
    t.float    "weight_at_diagnosis"
    t.string   "hyperdiploidy_by"
    t.boolean  "cbc_percent_blasts_unknown",                                                               :default => false
    t.integer  "response_day_7_days_since_treatment_began"
    t.integer  "response_day_7_days_since_diagnosis"
    t.integer  "response_day_14_days_since_treatment_began"
    t.integer  "response_day_14_days_since_diagnosis"
    t.integer  "response_day_28_days_since_treatment_began"
    t.integer  "response_day_28_days_since_diagnosis"
    t.string   "entry_1_by_uid"
    t.string   "entry_2_by_uid"
    t.string   "merged_by_uid"
    t.date     "discharge_summary_found_on"
    t.datetime "created_at",                                                                                                  :null => false
    t.datetime "updated_at",                                                                                                  :null => false
  end

  add_index "abstracts", ["study_subject_id"], :name => "index_abstracts_on_study_subject_id"

  create_table "address_types", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "address_types", ["key"], :name => "index_address_types_on_key", :unique => true

  create_table "addresses", :force => true do |t|
    t.integer  "address_type_id"
    t.integer  "data_source_id"
    t.string   "line_1"
    t.string   "line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip",                 :limit => 10
    t.integer  "external_address_id"
    t.string   "county"
    t.string   "unit"
    t.string   "country"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "addresses", ["external_address_id"], :name => "index_addresses_on_external_address_id", :unique => true

  create_table "addressings", :force => true do |t|
    t.integer  "study_subject_id"
    t.integer  "address_id"
    t.integer  "current_address",      :default => 1
    t.integer  "address_at_diagnosis"
    t.date     "valid_from"
    t.date     "valid_to"
    t.integer  "is_valid"
    t.string   "why_invalid"
    t.boolean  "is_verified"
    t.string   "how_verified"
    t.date     "verified_on"
    t.string   "verified_by_uid"
    t.integer  "data_source_id"
    t.string   "other_data_source"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "addressings", ["address_id"], :name => "index_addressings_on_address_id"
  add_index "addressings", ["study_subject_id"], :name => "index_addressings_on_study_subject_id"

  create_table "aliquots", :force => true do |t|
    t.integer  "position"
    t.integer  "owner_id"
    t.integer  "sample_id"
    t.integer  "unit_id"
    t.string   "location"
    t.string   "mass"
    t.string   "external_aliquot_id"
    t.string   "external_aliquot_id_source"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "aliquots", ["owner_id"], :name => "index_aliquots_on_owner_id"
  add_index "aliquots", ["sample_id"], :name => "index_aliquots_on_sample_id"
  add_index "aliquots", ["unit_id"], :name => "index_aliquots_on_unit_id"

  create_table "analyses", :force => true do |t|
    t.integer  "analyst_id"
    t.integer  "project_id"
    t.string   "key",                            :null => false
    t.string   "description"
    t.integer  "analytic_file_creator_id"
    t.date     "analytic_file_created_date"
    t.date     "analytic_file_last_pulled_date"
    t.string   "analytic_file_location"
    t.string   "analytic_file_filename"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "analyses", ["key"], :name => "index_analyses_on_key", :unique => true

  create_table "analyses_study_subjects", :id => false, :force => true do |t|
    t.integer "analysis_id"
    t.integer "study_subject_id"
  end

  add_index "analyses_study_subjects", ["analysis_id"], :name => "index_analyses_study_subjects_on_analysis_id"
  add_index "analyses_study_subjects", ["study_subject_id"], :name => "index_analyses_study_subjects_on_study_subject_id"

  create_table "bc_requests", :force => true do |t|
    t.integer  "study_subject_id"
    t.date     "sent_on"
    t.string   "status"
    t.text     "notes"
    t.string   "request_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "birth_data", :force => true do |t|
    t.string   "abnormal_conditions"
    t.integer  "apgar_1min"
    t.integer  "apgar_5min"
    t.integer  "apgar_10min"
    t.integer  "birth_order"
    t.string   "birth_type"
    t.decimal  "birth_weight_gms",                  :precision => 10, :scale => 0
    t.string   "complications_labor_delivery"
    t.string   "complications_pregnancy"
    t.string   "county_of_delivery"
    t.integer  "daily_cigarette_cnt_1st_tri"
    t.integer  "daily_cigarette_cnt_2nd_tri"
    t.integer  "daily_cigarette_cnt_3rd_tri"
    t.integer  "daily_cigarette_cnt_3mo_preconc"
    t.date     "dob"
    t.string   "father_job_industry"
    t.date     "father_dob"
    t.string   "father_hispanic_origin_code"
    t.string   "father_first_name"
    t.string   "father_last_name"
    t.string   "father_middle_name"
    t.string   "father_occupation"
    t.string   "father_race_ethnicity"
    t.integer  "father_years_education"
    t.string   "fetal_presentation_at_birth"
    t.string   "first_name"
    t.boolean  "forceps_attempt_unsuccessful"
    t.date     "last_live_birth_on"
    t.date     "last_menses_on"
    t.string   "last_name"
    t.date     "last_termination_on"
    t.integer  "length_of_gestation_days"
    t.integer  "live_births_now_deceased"
    t.integer  "live_births_now_living"
    t.string   "local_registrar_district"
    t.string   "local_registrar_no"
    t.string   "method_of_delivery"
    t.string   "middle_name"
    t.string   "month_prenatal_care_began"
    t.string   "mother_residence_county_ef"
    t.string   "mother_residence_line_1"
    t.string   "mother_residence_zip"
    t.integer  "mother_weight_at_delivery"
    t.string   "mother_birthplace_state"
    t.string   "mother_residence_city"
    t.date     "mother_dob"
    t.string   "mother_first_name"
    t.integer  "mother_height"
    t.string   "mother_hispanic_origin_code"
    t.string   "mother_industry"
    t.string   "mother_maiden_name"
    t.string   "mother_middle_name"
    t.string   "mother_occupation"
    t.string   "mother_race_ethnicity"
    t.boolean  "mother_received_wic"
    t.string   "mother_residence_state"
    t.integer  "mother_weight_pre_pregnancy"
    t.integer  "mother_years_education"
    t.integer  "ob_gestation_estimate_at_delivery"
    t.integer  "prenatal_care_visit_count"
    t.string   "sex"
    t.string   "state_registrar_no"
    t.integer  "termination_count_20_plus_weeks"
    t.integer  "termination_count_before_20_weeks"
    t.boolean  "vacuum_attempt_unsuccessful"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "study_subject_id"
  end

  create_table "birth_datum_updates", :force => true do |t|
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size"
    t.datetime "csv_file_updated_at"
  end

  create_table "candidate_controls", :force => true do |t|
    t.string   "icf_master_id"
    t.string   "related_patid",         :limit => 5
    t.integer  "study_subject_id"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "dob"
    t.string   "state_registrar_no",    :limit => 25
    t.string   "local_registrar_no",    :limit => 25
    t.string   "sex"
    t.string   "birth_county"
    t.date     "assigned_on"
    t.integer  "mother_race_id"
    t.integer  "mother_hispanicity_id"
    t.integer  "father_race_id"
    t.integer  "father_hispanicity_id"
    t.string   "birth_type"
    t.string   "mother_maiden_name"
    t.integer  "mother_yrs_educ"
    t.integer  "father_yrs_educ"
    t.boolean  "reject_candidate",                    :default => false, :null => false
    t.string   "rejection_reason"
    t.string   "mother_first_name"
    t.string   "mother_middle_name"
    t.string   "mother_last_name"
    t.date     "mother_dob"
    t.integer  "mom_is_biomom"
    t.integer  "dad_is_biodad"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  create_table "context_contextables", :force => true do |t|
    t.integer  "context_id"
    t.integer  "contextable_id"
    t.string   "contextable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "contexts", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.text     "notes"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "contexts", ["description"], :name => "index_contexts_on_description", :unique => true
  add_index "contexts", ["key"], :name => "index_contexts_on_key", :unique => true

  create_table "counties", :force => true do |t|
    t.string   "name"
    t.string   "fips_code",    :limit => 5
    t.string   "state_abbrev", :limit => 2
    t.string   "usc_code",     :limit => 2
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "counties", ["state_abbrev"], :name => "index_counties_on_state_abbrev"

  create_table "data_sources", :force => true do |t|
    t.integer  "position"
    t.string   "data_origin"
    t.string   "key",                :null => false
    t.string   "description",        :null => false
    t.integer  "organization_id"
    t.string   "other_organization"
    t.integer  "person_id"
    t.string   "other_person"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "data_sources", ["key"], :name => "index_data_sources_on_key", :unique => true

  create_table "diagnoses", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "diagnoses", ["description"], :name => "index_diagnoses_on_description", :unique => true
  add_index "diagnoses", ["key"], :name => "index_diagnoses_on_key", :unique => true

  create_table "document_types", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "document_types", ["key"], :name => "index_document_types_on_key", :unique => true

  create_table "document_versions", :force => true do |t|
    t.integer  "position"
    t.integer  "document_type_id", :null => false
    t.string   "title"
    t.string   "description"
    t.string   "indicator"
    t.integer  "language_id"
    t.date     "began_use_on"
    t.date     "ended_use_on"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "position"
    t.integer  "study_subject_id"
    t.integer  "project_id"
    t.string   "recruitment_priority"
    t.integer  "tracing_status_id"
    t.integer  "is_candidate"
    t.integer  "is_eligible"
    t.integer  "ineligible_reason_id"
    t.string   "other_ineligible_reason"
    t.integer  "consented"
    t.date     "consented_on"
    t.integer  "refusal_reason_id"
    t.string   "other_refusal_reason"
    t.integer  "is_chosen"
    t.string   "reason_not_chosen"
    t.integer  "terminated_participation"
    t.string   "terminated_reason"
    t.integer  "is_complete"
    t.date     "completed_on"
    t.boolean  "is_closed"
    t.string   "reason_closed"
    t.text     "notes"
    t.integer  "document_version_id"
    t.integer  "project_outcome_id"
    t.date     "project_outcome_on"
    t.integer  "use_smp_future_rsrch"
    t.integer  "use_smp_future_cancer_rsrch"
    t.integer  "use_smp_future_other_rsrch"
    t.integer  "share_smp_with_others"
    t.integer  "contact_for_related_study"
    t.integer  "provide_saliva_smp"
    t.integer  "receive_study_findings"
    t.boolean  "refused_by_physician"
    t.boolean  "refused_by_family"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "enrollments", ["project_id", "study_subject_id"], :name => "index_enrollments_on_project_id_and_study_subject_id", :unique => true

  create_table "follow_up_types", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "follow_up_types", ["key"], :name => "index_follow_up_types_on_key", :unique => true

  create_table "follow_ups", :force => true do |t|
    t.integer  "section_id",        :null => false
    t.integer  "enrollment_id",     :null => false
    t.integer  "follow_up_type_id", :null => false
    t.date     "completed_on"
    t.string   "completed_by_uid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "gift_cards", :force => true do |t|
    t.integer  "study_subject_id"
    t.integer  "project_id"
    t.date     "issued_on"
    t.string   "expiration",       :limit => 25
    t.string   "vendor"
    t.string   "number",                         :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "gift_cards", ["number"], :name => "index_gift_cards_on_number", :unique => true

  create_table "guides", :force => true do |t|
    t.string   "controller"
    t.string   "action"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "guides", ["controller", "action"], :name => "index_guides_on_controller_and_action", :unique => true

  create_table "home_exposure_responses", :force => true do |t|
    t.integer  "study_subject_id"
    t.integer  "vacuum_has_disposable_bag"
    t.integer  "how_often_vacuumed_12mos"
    t.integer  "shoes_usually_off_inside_12mos"
    t.integer  "someone_ate_meat_12mos"
    t.integer  "freq_pan_fried_meat_12mos"
    t.integer  "freq_deep_fried_meat_12mos"
    t.integer  "freq_oven_fried_meat_12mos"
    t.integer  "freq_grilled_meat_outside_12mos"
    t.integer  "freq_other_high_temp_cooking_12mos"
    t.string   "other_type_high_temp_cooking"
    t.integer  "doneness_of_meat_exterior_12mos"
    t.integer  "job_is_plane_mechanic_12mos"
    t.integer  "job_is_artist_12mos"
    t.integer  "job_is_janitor_12mos"
    t.integer  "job_is_construction_12mos"
    t.integer  "job_is_dentist_12mos"
    t.integer  "job_is_electrician_12mos"
    t.integer  "job_is_engineer_12mos"
    t.integer  "job_is_farmer_12mos"
    t.integer  "job_is_gardener_12mos"
    t.integer  "job_is_lab_worker_12mos"
    t.integer  "job_is_manufacturer_12mos"
    t.integer  "job_auto_mechanic_12mos"
    t.integer  "job_is_patient_care_12mos"
    t.integer  "job_is_agr_packer_12mos"
    t.integer  "job_is_painter_12mos"
    t.integer  "job_is_pesticides_12mos"
    t.integer  "job_is_photographer_12mos"
    t.integer  "job_is_teacher_12mos"
    t.integer  "job_is_welder_12mos"
    t.integer  "used_flea_control_12mos"
    t.integer  "freq_used_flea_control_12mos"
    t.integer  "used_ant_control_12mos"
    t.integer  "freq_ant_control_12mos"
    t.integer  "used_bee_control_12mos"
    t.integer  "freq_bee_control_12mos"
    t.integer  "used_indoor_plant_prod_12mos"
    t.integer  "freq_indoor_plant_product_12mos"
    t.integer  "used_other_indoor_product_12mos"
    t.integer  "freq_other_indoor_product_12mos"
    t.integer  "used_indoor_foggers"
    t.integer  "freq_indoor_foggers_12mos"
    t.integer  "used_pro_pest_inside_12mos"
    t.integer  "freq_pro_pest_inside_12mos"
    t.integer  "used_pro_pest_outside_12mos"
    t.integer  "freq_used_pro_pest_outside_12mos"
    t.integer  "used_pro_lawn_service_12mos"
    t.integer  "freq_pro_lawn_service_12mos"
    t.integer  "used_lawn_products_12mos"
    t.integer  "freq_lawn_products_12mos"
    t.integer  "used_slug_control_12mos"
    t.integer  "freq_slug_control_12mos"
    t.integer  "used_rat_control_12mos"
    t.integer  "freq_rat_control_12mos"
    t.integer  "used_mothballs_12mos"
    t.integer  "cmty_sprayed_gypsy_moths_12mos"
    t.integer  "cmty_sprayed_medflies_12mos"
    t.integer  "cmty_sprayed_mosquitoes_12mos"
    t.integer  "cmty_sprayed_sharpshooters_12mos"
    t.integer  "cmty_sprayed_apple_moths_12mos"
    t.integer  "cmty_sprayed_other_pest_12mos"
    t.string   "other_pest_community_sprayed"
    t.integer  "type_of_residence"
    t.string   "other_type_of_residence"
    t.integer  "number_of_floors_in_residence"
    t.integer  "number_of_stories_in_building"
    t.integer  "year_home_built"
    t.integer  "home_square_footage"
    t.integer  "number_of_rooms_in_home"
    t.integer  "home_constructed_of"
    t.string   "other_home_material"
    t.integer  "home_has_attached_garage"
    t.integer  "vehicle_in_garage_1mo"
    t.integer  "freq_in_out_garage_1mo"
    t.integer  "home_has_electric_cooling"
    t.integer  "freq_windows_open_cold_mos_12mos"
    t.integer  "freq_windows_open_warm_mos_12mos"
    t.integer  "used_electric_heat_12mos"
    t.integer  "used_kerosene_heat_12mos"
    t.integer  "used_radiator_12mos"
    t.integer  "used_gas_heat_12mos"
    t.integer  "used_wood_burning_stove_12mos"
    t.integer  "freq_used_wood_stove_12mos"
    t.integer  "used_wood_fireplace_12mos"
    t.integer  "freq_used_wood_fireplace_12mos"
    t.integer  "used_fireplace_insert_12mos"
    t.integer  "used_gas_stove_12mos"
    t.integer  "used_gas_dryer_12mos"
    t.integer  "used_gas_water_heater_12mos"
    t.integer  "used_other_gas_appliance_12mos"
    t.string   "type_of_other_gas_appliance"
    t.integer  "painted_inside_home"
    t.integer  "carpeted_in_home"
    t.integer  "refloored_in_home"
    t.integer  "weather_proofed_home"
    t.integer  "replaced_home_windows"
    t.integer  "roof_work_on_home"
    t.integer  "construction_in_home"
    t.integer  "other_home_remodelling"
    t.string   "type_other_home_remodelling"
    t.integer  "regularly_smoked_indoors"
    t.integer  "regularly_smoked_indoors_12mos"
    t.integer  "regularly_smoked_outdoors"
    t.integer  "regularly_smoked_outdoors_12mos"
    t.integer  "used_smokeless_tobacco_12mos"
    t.integer  "qty_of_upholstered_furniture"
    t.integer  "qty_bought_after_2006"
    t.integer  "furniture_has_exposed_foam"
    t.integer  "home_has_carpets"
    t.integer  "percent_home_with_carpet"
    t.integer  "home_has_televisions"
    t.integer  "number_of_televisions_in_home"
    t.integer  "avg_number_hours_tvs_used"
    t.integer  "home_has_computers"
    t.integer  "number_of_computers_in_home"
    t.integer  "avg_number_hours_computers_used"
    t.text     "additional_comments"
    t.integer  "vacuum_bag_last_changed"
    t.integer  "vacuum_used_outside_home"
    t.boolean  "consent_read_over_phone"
    t.boolean  "respondent_requested_new_consent"
    t.boolean  "consent_reviewed_with_respondent"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "home_exposure_responses", ["study_subject_id"], :name => "index_home_exposure_responses_on_study_subject_id", :unique => true

  create_table "homex_outcomes", :force => true do |t|
    t.integer  "position"
    t.integer  "study_subject_id"
    t.integer  "sample_outcome_id"
    t.date     "sample_outcome_on"
    t.integer  "interview_outcome_id"
    t.date     "interview_outcome_on"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "homex_outcomes", ["study_subject_id"], :name => "index_homex_outcomes_on_study_subject_id", :unique => true

  create_table "hospitals", :force => true do |t|
    t.integer  "position"
    t.integer  "organization_id"
    t.boolean  "has_irb_waiver",  :default => false, :null => false
    t.boolean  "is_active",       :default => true,  :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "hospitals", ["organization_id"], :name => "index_hospitals_on_organization_id"

  create_table "icf_master_ids", :force => true do |t|
    t.string   "icf_master_id",    :limit => 9
    t.date     "assigned_on"
    t.integer  "study_subject_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "icf_master_ids", ["icf_master_id"], :name => "index_icf_master_ids_on_icf_master_id", :unique => true
  add_index "icf_master_ids", ["study_subject_id"], :name => "index_icf_master_ids_on_study_subject_id", :unique => true

  create_table "icf_master_tracker_changes", :force => true do |t|
    t.string   "icf_master_id",                          :null => false
    t.date     "master_tracker_date"
    t.boolean  "new_tracker_record",  :default => false, :null => false
    t.string   "modified_column"
    t.string   "previous_value"
    t.string   "new_value"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "icf_master_tracker_changes", ["icf_master_id"], :name => "index_icf_master_tracker_changes_on_icf_master_id"

  create_table "icf_master_tracker_updates", :force => true do |t|
    t.date     "master_tracker_date"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size"
    t.datetime "csv_file_updated_at"
  end

  create_table "icf_master_trackers", :force => true do |t|
    t.integer  "study_subject_id"
    t.boolean  "flagged_for_update",            :default => false
    t.text     "last_update_attempt_errors"
    t.datetime "last_update_attempted_at"
    t.string   "master_id"
    t.string   "master_id_mother"
    t.string   "language"
    t.string   "record_owner"
    t.string   "record_status"
    t.string   "record_status_date"
    t.string   "date_received"
    t.string   "last_attempt"
    t.string   "last_disposition"
    t.string   "curr_phone"
    t.string   "record_sent_for_matching"
    t.string   "record_received_from_matching"
    t.string   "sent_pre_incentive"
    t.string   "released_to_cati"
    t.string   "confirmed_cati_contact"
    t.string   "refused"
    t.string   "deceased_notification"
    t.string   "is_eligible"
    t.string   "ineligible_reason"
    t.string   "confirmation_packet_sent"
    t.string   "cati_protocol_exhausted"
    t.string   "new_phone_released_to_cati"
    t.string   "plea_notification_sent"
    t.string   "case_returned_for_new_info"
    t.string   "case_returned_from_berkeley"
    t.string   "cati_complete"
    t.string   "kit_mother_sent"
    t.string   "kit_infant_sent"
    t.string   "kit_child_sent"
    t.string   "kid_adolescent_sent"
    t.string   "kit_mother_refused_code"
    t.string   "kit_child_refused_code"
    t.string   "no_response_to_plea"
    t.string   "response_received_from_plea"
    t.string   "sent_to_in_person_followup"
    t.string   "kit_mother_received"
    t.string   "kit_child_received"
    t.string   "thank_you_sent"
    t.string   "physician_request_sent"
    t.string   "physician_response_received"
    t.string   "vaccine_auth_received"
    t.string   "recollect"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "icf_master_trackers", ["master_id"], :name => "index_icf_master_trackers_on_master_id", :unique => true

  create_table "ineligible_reasons", :force => true do |t|
    t.integer  "position"
    t.string   "key",                :null => false
    t.string   "description"
    t.string   "ineligible_context"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "ineligible_reasons", ["description"], :name => "index_ineligible_reasons_on_description", :unique => true
  add_index "ineligible_reasons", ["key"], :name => "index_ineligible_reasons_on_key", :unique => true

  create_table "instrument_types", :force => true do |t|
    t.integer  "position"
    t.integer  "project_id"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "instrument_types", ["description"], :name => "index_instrument_types_on_description", :unique => true
  add_index "instrument_types", ["key"], :name => "index_instrument_types_on_key", :unique => true

  create_table "instrument_versions", :force => true do |t|
    t.integer  "position"
    t.integer  "instrument_type_id"
    t.integer  "language_id"
    t.integer  "instrument_id"
    t.date     "began_use_on"
    t.date     "ended_use_on"
    t.string   "key",                :null => false
    t.string   "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "instrument_versions", ["description"], :name => "index_instrument_versions_on_description", :unique => true
  add_index "instrument_versions", ["key"], :name => "index_instrument_versions_on_key", :unique => true

  create_table "instruments", :force => true do |t|
    t.integer  "position"
    t.integer  "project_id"
    t.integer  "results_table_id"
    t.string   "key",                 :null => false
    t.string   "name",                :null => false
    t.string   "description"
    t.integer  "interview_method_id"
    t.date     "began_use_on"
    t.date     "ended_use_on"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "instruments", ["description"], :name => "index_instruments_on_description", :unique => true
  add_index "instruments", ["key"], :name => "index_instruments_on_key", :unique => true
  add_index "instruments", ["project_id"], :name => "index_instruments_on_project_id"

  create_table "interview_methods", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "interview_methods", ["key"], :name => "index_interview_methods_on_key", :unique => true

  create_table "interview_outcomes", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "interview_outcomes", ["key"], :name => "index_interview_outcomes_on_key", :unique => true

  create_table "interviews", :force => true do |t|
    t.integer  "position"
    t.integer  "study_subject_id"
    t.integer  "address_id"
    t.integer  "interviewer_id"
    t.integer  "instrument_version_id"
    t.integer  "interview_method_id"
    t.integer  "language_id"
    t.string   "respondent_first_name"
    t.string   "respondent_last_name"
    t.integer  "subject_relationship_id"
    t.string   "other_subject_relationship"
    t.date     "intro_letter_sent_on"
    t.boolean  "consent_read_over_phone"
    t.boolean  "respondent_requested_new_consent"
    t.boolean  "consent_reviewed_with_respondent"
    t.datetime "began_at"
    t.datetime "ended_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "interviews", ["study_subject_id"], :name => "index_interviews_on_study_subject_id"

  create_table "languages", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "languages", ["key"], :name => "index_languages_on_key", :unique => true

  create_table "operational_event_types", :force => true do |t|
    t.integer  "position"
    t.string   "key",            :null => false
    t.string   "description"
    t.string   "event_category"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "operational_event_types", ["description"], :name => "index_operational_event_types_on_description", :unique => true
  add_index "operational_event_types", ["key"], :name => "index_operational_event_types_on_key", :unique => true

  create_table "operational_events", :force => true do |t|
    t.integer  "operational_event_type_id"
    t.date     "occurred_on"
    t.integer  "study_subject_id"
    t.integer  "project_id"
    t.string   "description"
    t.text     "event_notes"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "operational_events", ["operational_event_type_id"], :name => "index_operational_events_on_operational_event_type_id"
  add_index "operational_events", ["project_id"], :name => "index_operational_events_on_project_id"
  add_index "operational_events", ["study_subject_id"], :name => "index_operational_events_on_study_subject_id"

  create_table "organizations", :force => true do |t|
    t.integer  "position"
    t.string   "key",        :null => false
    t.string   "name"
    t.integer  "person_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "organizations", ["key"], :name => "index_organizations_on_key", :unique => true
  add_index "organizations", ["name"], :name => "index_organizations_on_name", :unique => true

  create_table "pages", :force => true do |t|
    t.integer  "position"
    t.integer  "parent_id"
    t.boolean  "hide_menu",  :default => false
    t.string   "path"
    t.string   "title_en"
    t.string   "title_es"
    t.string   "menu_en"
    t.string   "menu_es"
    t.text     "body_en"
    t.text     "body_es"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["path"], :name => "index_pages_on_path", :unique => true

  create_table "patients", :force => true do |t|
    t.integer  "study_subject_id"
    t.date     "diagnosis_date"
    t.integer  "diagnosis_id"
    t.integer  "organization_id"
    t.date     "admit_date"
    t.date     "treatment_began_on"
    t.integer  "sample_was_collected"
    t.string   "admitting_oncologist"
    t.integer  "was_ca_resident_at_diagnosis"
    t.integer  "was_previously_treated"
    t.integer  "was_under_15_at_dx"
    t.string   "raf_zip",                      :limit => 10
    t.string   "raf_county"
    t.string   "hospital_no",                  :limit => 25
    t.string   "other_diagnosis"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "patients", ["hospital_no", "organization_id"], :name => "hosp_org", :unique => true
  add_index "patients", ["organization_id"], :name => "index_patients_on_organization_id"
  add_index "patients", ["study_subject_id"], :name => "index_patients_on_study_subject_id", :unique => true

  create_table "people", :force => true do |t|
    t.integer  "position"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "honorific",       :limit => 20
    t.integer  "person_type_id"
    t.integer  "organization_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "phone_numbers", :force => true do |t|
    t.integer  "position"
    t.integer  "study_subject_id"
    t.integer  "phone_type_id"
    t.integer  "data_source_id"
    t.string   "phone_number"
    t.boolean  "is_primary"
    t.integer  "is_valid"
    t.string   "why_invalid"
    t.boolean  "is_verified"
    t.string   "how_verified"
    t.date     "verified_on"
    t.string   "verified_by_uid"
    t.integer  "current_phone",     :default => 1
    t.string   "other_data_source"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "phone_numbers", ["study_subject_id"], :name => "index_phone_numbers_on_study_subject_id"

  create_table "phone_types", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "phone_types", ["key"], :name => "index_phone_types_on_key", :unique => true

  create_table "project_outcomes", :force => true do |t|
    t.integer  "position"
    t.integer  "project_id"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "project_outcomes", ["key"], :name => "index_project_outcomes_on_key", :unique => true

  create_table "projects", :force => true do |t|
    t.integer  "position"
    t.date     "began_on"
    t.date     "ended_on"
    t.string   "key",                  :null => false
    t.string   "description"
    t.text     "eligibility_criteria"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "projects", ["description"], :name => "index_projects_on_description", :unique => true
  add_index "projects", ["key"], :name => "index_projects_on_key", :unique => true

  create_table "races", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "races", ["description"], :name => "index_races_on_description", :unique => true
  add_index "races", ["key"], :name => "index_races_on_key", :unique => true

  create_table "refusal_reasons", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "refusal_reasons", ["description"], :name => "index_refusal_reasons_on_description", :unique => true
  add_index "refusal_reasons", ["key"], :name => "index_refusal_reasons_on_key", :unique => true

  create_table "roles", :force => true do |t|
    t.integer  "position"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "sample_collectors", :force => true do |t|
    t.integer  "organization_id"
    t.string   "other_organization"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "sample_collectors", ["organization_id"], :name => "index_sample_collectors_on_organization_id"

  create_table "sample_formats", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sample_formats", ["description"], :name => "index_sample_formats_on_description", :unique => true
  add_index "sample_formats", ["key"], :name => "index_sample_formats_on_key", :unique => true

  create_table "sample_kits", :force => true do |t|
    t.integer  "sample_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sample_outcomes", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sample_outcomes", ["key"], :name => "index_sample_outcomes_on_key", :unique => true

  create_table "sample_temperatures", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sample_temperatures", ["key"], :name => "index_sample_temperatures_on_key", :unique => true

  create_table "sample_types", :force => true do |t|
    t.integer  "position"
    t.integer  "parent_id"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sample_types", ["description"], :name => "index_sample_types_on_description", :unique => true
  add_index "sample_types", ["key"], :name => "index_sample_types_on_key", :unique => true
  add_index "sample_types", ["parent_id"], :name => "index_sample_types_on_parent_id"

  create_table "samples", :force => true do |t|
    t.integer  "parent_sample_id"
    t.integer  "sample_format_id"
    t.integer  "sample_type_id"
    t.integer  "project_id"
    t.integer  "study_subject_id"
    t.integer  "unit_id"
    t.integer  "location_id"
    t.integer  "sample_temperature_id"
    t.integer  "sample_collector_id"
    t.integer  "order_no"
    t.decimal  "quantity_in_sample",           :precision => 10, :scale => 0
    t.string   "aliquot_or_sample_on_receipt"
    t.datetime "sent_to_subject_at"
    t.datetime "collected_from_subject_at"
    t.datetime "shipped_to_ccls_at"
    t.datetime "received_by_ccls_at"
    t.datetime "sent_to_lab_at"
    t.datetime "received_by_lab_at"
    t.datetime "aliquotted_at"
    t.string   "external_id"
    t.string   "external_id_source"
    t.datetime "receipt_confirmed_at"
    t.string   "receipt_confirmed_by"
    t.boolean  "future_use_prohibited",                                       :default => false, :null => false
    t.string   "state"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
  end

  create_table "sections", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sections", ["key"], :name => "index_sections_on_key", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "states", :force => true do |t|
    t.integer  "position"
    t.string   "code",                           :null => false
    t.string   "name",                           :null => false
    t.string   "fips_country_code", :limit => 2, :null => false
    t.string   "fips_state_code",   :limit => 2, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "states", ["code"], :name => "index_states_on_code", :unique => true
  add_index "states", ["fips_country_code"], :name => "index_states_on_fips_country_code"
  add_index "states", ["fips_state_code"], :name => "index_states_on_fips_state_code", :unique => true
  add_index "states", ["name"], :name => "index_states_on_name", :unique => true

  create_table "study_subjects", :force => true do |t|
    t.integer  "subject_type_id"
    t.integer  "vital_status_id"
    t.integer  "hispanicity_id"
    t.date     "reference_date"
    t.string   "sex"
    t.boolean  "do_not_contact",                            :default => false, :null => false
    t.integer  "abstracts_count",                           :default => 0
    t.integer  "mother_yrs_educ"
    t.integer  "father_yrs_educ"
    t.string   "birth_type"
    t.integer  "mother_hispanicity_id"
    t.integer  "father_hispanicity_id"
    t.string   "birth_county"
    t.string   "is_duplicate_of",             :limit => 6
    t.integer  "mother_hispanicity_mex"
    t.integer  "father_hispanicity_mex"
    t.integer  "mom_is_biomom"
    t.integer  "dad_is_biodad"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "dob"
    t.date     "died_on"
    t.string   "mother_first_name"
    t.string   "mother_middle_name"
    t.string   "mother_maiden_name"
    t.string   "mother_last_name"
    t.string   "father_first_name"
    t.string   "father_middle_name"
    t.string   "father_last_name"
    t.string   "email"
    t.string   "guardian_first_name"
    t.string   "guardian_middle_name"
    t.string   "guardian_last_name"
    t.integer  "guardian_relationship_id"
    t.string   "other_guardian_relationship"
    t.integer  "mother_race_id"
    t.integer  "father_race_id"
    t.string   "maiden_name"
    t.string   "generational_suffix",         :limit => 10
    t.string   "father_generational_suffix",  :limit => 10
    t.string   "birth_year",                  :limit => 4
    t.string   "birth_city"
    t.string   "birth_state"
    t.string   "birth_country"
    t.string   "other_mother_race"
    t.string   "other_father_race"
    t.integer  "childid"
    t.string   "patid",                       :limit => 4
    t.string   "case_control_type",           :limit => 1
    t.integer  "orderno"
    t.string   "lab_no"
    t.string   "related_childid"
    t.string   "related_case_childid"
    t.string   "ssn"
    t.string   "subjectid",                   :limit => 6
    t.string   "matchingid",                  :limit => 6
    t.string   "familyid",                    :limit => 6
    t.string   "state_id_no"
    t.string   "childidwho",                  :limit => 10
    t.string   "studyid",                     :limit => 14
    t.string   "newid",                       :limit => 6
    t.string   "gbid",                        :limit => 26
    t.string   "lab_no_wiemels",              :limit => 25
    t.string   "idno_wiemels",                :limit => 10
    t.string   "accession_no",                :limit => 25
    t.string   "studyid_nohyphen",            :limit => 12
    t.string   "studyid_intonly_nohyphen",    :limit => 12
    t.string   "icf_master_id",               :limit => 9
    t.string   "state_registrar_no"
    t.string   "local_registrar_no"
    t.boolean  "is_matched"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "study_subjects", ["accession_no"], :name => "index_study_subjects_on_accession_no", :unique => true
  add_index "study_subjects", ["childid"], :name => "index_study_subjects_on_childid", :unique => true
  add_index "study_subjects", ["email"], :name => "index_study_subjects_on_email", :unique => true
  add_index "study_subjects", ["gbid"], :name => "index_study_subjects_on_gbid", :unique => true
  add_index "study_subjects", ["icf_master_id"], :name => "index_study_subjects_on_icf_master_id", :unique => true
  add_index "study_subjects", ["idno_wiemels"], :name => "index_study_subjects_on_idno_wiemels", :unique => true
  add_index "study_subjects", ["lab_no_wiemels"], :name => "index_study_subjects_on_lab_no_wiemels", :unique => true
  add_index "study_subjects", ["local_registrar_no"], :name => "index_study_subjects_on_local_registrar_no", :unique => true
  add_index "study_subjects", ["patid", "case_control_type", "orderno"], :name => "piccton", :unique => true
  add_index "study_subjects", ["ssn"], :name => "index_study_subjects_on_ssn", :unique => true
  add_index "study_subjects", ["state_id_no"], :name => "index_study_subjects_on_state_id_no", :unique => true
  add_index "study_subjects", ["state_registrar_no"], :name => "index_study_subjects_on_state_registrar_no", :unique => true
  add_index "study_subjects", ["studyid"], :name => "index_study_subjects_on_studyid", :unique => true
  add_index "study_subjects", ["studyid_intonly_nohyphen"], :name => "index_study_subjects_on_studyid_intonly_nohyphen", :unique => true
  add_index "study_subjects", ["studyid_nohyphen"], :name => "index_study_subjects_on_studyid_nohyphen", :unique => true
  add_index "study_subjects", ["subjectid"], :name => "index_study_subjects_on_subjectid", :unique => true

  create_table "subject_languages", :force => true do |t|
    t.integer  "study_subject_id"
    t.integer  "language_id"
    t.string   "other_language"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "subject_races", :force => true do |t|
    t.integer  "study_subject_id"
    t.integer  "race_id"
    t.boolean  "is_primary",       :default => false, :null => false
    t.string   "other_race"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "subject_relationships", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "subject_relationships", ["description"], :name => "index_subject_relationships_on_description", :unique => true
  add_index "subject_relationships", ["key"], :name => "index_subject_relationships_on_key", :unique => true

  create_table "subject_types", :force => true do |t|
    t.integer  "position"
    t.string   "key",                       :null => false
    t.string   "description"
    t.string   "related_case_control_type"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "subject_types", ["description"], :name => "index_subject_types_on_description", :unique => true
  add_index "subject_types", ["key"], :name => "index_subject_types_on_key", :unique => true

  create_table "tracing_statuses", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "tracing_statuses", ["description"], :name => "index_tracing_statuses_on_description", :unique => true
  add_index "tracing_statuses", ["key"], :name => "index_tracing_statuses_on_key", :unique => true

  create_table "transfers", :force => true do |t|
    t.integer  "position"
    t.integer  "aliquot_id"
    t.integer  "from_organization_id",                                :null => false
    t.integer  "to_organization_id",                                  :null => false
    t.decimal  "amount",               :precision => 10, :scale => 0
    t.string   "reason"
    t.boolean  "is_permanent"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  add_index "transfers", ["aliquot_id"], :name => "index_transfers_on_aliquot_id"
  add_index "transfers", ["from_organization_id"], :name => "index_transfers_on_from_organization_id"
  add_index "transfers", ["to_organization_id"], :name => "index_transfers_on_to_organization_id"

  create_table "units", :force => true do |t|
    t.integer  "position"
    t.integer  "context_id"
    t.string   "key",         :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "units", ["description"], :name => "index_units_on_description", :unique => true
  add_index "units", ["key"], :name => "index_units_on_key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "sn"
    t.string   "displayname"
    t.string   "mail"
    t.string   "telephonenumber"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "users", ["sn"], :name => "index_users_on_sn"
  add_index "users", ["uid"], :name => "index_users_on_uid", :unique => true

  create_table "vital_statuses", :force => true do |t|
    t.integer  "position"
    t.string   "key",         :null => false
    t.integer  "code"
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "vital_statuses", ["code"], :name => "index_vital_statuses_on_code", :unique => true
  add_index "vital_statuses", ["key"], :name => "index_vital_statuses_on_key", :unique => true

  create_table "zip_codes", :force => true do |t|
    t.string   "zip_code",   :limit => 5, :null => false
    t.string   "city",                    :null => false
    t.string   "state",                   :null => false
    t.string   "zip_class",               :null => false
    t.integer  "county_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "zip_codes", ["zip_code"], :name => "index_zip_codes_on_zip_code", :unique => true

end
