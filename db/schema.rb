# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150514180041) do

  create_table "abstracts", force: true do |t|
    t.string   "entry_1_by_uid"
    t.string   "entry_2_by_uid"
    t.string   "merged_by_uid"
    t.integer  "study_subject_id"
    t.integer  "bmb_report_found",                        limit: 2
    t.date     "bmb_test_date"
    t.integer  "bmb_percentage_blasts_known",             limit: 2
    t.string   "bmb_percentage_blasts",                   limit: 25
    t.text     "bmb_comments"
    t.integer  "bma_report_found",                        limit: 2
    t.date     "bma_test_date"
    t.integer  "bma_percentage_blasts_known",             limit: 2
    t.string   "bma_percentage_blasts",                   limit: 25
    t.text     "bma_comments"
    t.integer  "ccs_report_found",                        limit: 2
    t.date     "ccs_test_date"
    t.string   "ccs_peroxidase",                          limit: 25
    t.string   "ccs_sudan_black",                         limit: 25
    t.string   "ccs_periodic_acid_schiff",                limit: 25
    t.string   "ccs_chloroacetate_esterase",              limit: 25
    t.string   "ccs_non_specific_esterase",               limit: 25
    t.string   "ccs_alpha_naphthyl_butyrate_esterase",    limit: 25
    t.string   "ccs_toluidine_blue",                      limit: 25
    t.string   "ccs_bcl_2",                               limit: 25
    t.string   "ccs_other",                               limit: 25
    t.integer  "dfc_report_found",                        limit: 2
    t.date     "dfc_test_date"
    t.integer  "dfc_numerical_data_available",            limit: 2
    t.string   "marker_bmk",                              limit: 25
    t.string   "marker_bml",                              limit: 25
    t.string   "marker_cd10",                             limit: 25
    t.string   "marker_cd11b",                            limit: 25
    t.string   "marker_cd11c",                            limit: 25
    t.string   "marker_cd13",                             limit: 25
    t.string   "marker_cd14",                             limit: 25
    t.string   "marker_cd15",                             limit: 25
    t.string   "marker_cd16",                             limit: 25
    t.string   "marker_cd19",                             limit: 25
    t.string   "marker_cd19_cd10",                        limit: 25
    t.string   "marker_cd1a",                             limit: 25
    t.string   "marker_cd2",                              limit: 25
    t.string   "marker_cd20",                             limit: 25
    t.string   "marker_cd21",                             limit: 25
    t.string   "marker_cd22",                             limit: 25
    t.string   "marker_cd23",                             limit: 25
    t.string   "marker_cd24",                             limit: 25
    t.string   "marker_cd25",                             limit: 25
    t.string   "marker_cd3",                              limit: 25
    t.string   "marker_cd33",                             limit: 25
    t.string   "marker_cd34",                             limit: 25
    t.string   "marker_cd38",                             limit: 25
    t.string   "marker_cd3_cd4",                          limit: 25
    t.string   "marker_cd3_cd8",                          limit: 25
    t.string   "marker_cd4",                              limit: 25
    t.string   "marker_cd40",                             limit: 25
    t.string   "marker_cd41",                             limit: 25
    t.string   "marker_cd45",                             limit: 25
    t.string   "marker_cd5",                              limit: 25
    t.string   "marker_cd56",                             limit: 25
    t.string   "marker_cd57",                             limit: 25
    t.string   "marker_cd61",                             limit: 25
    t.string   "marker_cd7",                              limit: 25
    t.string   "marker_cd71",                             limit: 25
    t.string   "marker_cd8",                              limit: 25
    t.string   "marker_cd9",                              limit: 25
    t.string   "marker_cdw65",                            limit: 25
    t.string   "marker_glycophorin_a",                    limit: 25
    t.string   "marker_hla_dr",                           limit: 25
    t.string   "marker_igm",                              limit: 25
    t.string   "marker_sig",                              limit: 25
    t.string   "marker_tdt",                              limit: 25
    t.text     "other_markers"
    t.text     "marker_comments"
    t.integer  "tdt_report_found",                        limit: 2
    t.date     "tdt_test_date"
    t.string   "tdt_found_where",                         limit: 25
    t.string   "tdt_result",                              limit: 25
    t.string   "tdt_numerical_result",                    limit: 25
    t.integer  "ploidy_report_found",                     limit: 2
    t.date     "ploidy_test_date"
    t.string   "ploidy_found_where",                      limit: 25
    t.string   "ploidy_hypodiploid",                      limit: 25
    t.string   "ploidy_pseudodiploid",                    limit: 25
    t.string   "ploidy_hyperdiploid",                     limit: 25
    t.string   "ploidy_diploid",                          limit: 25
    t.string   "ploidy_dna_index",                        limit: 25
    t.text     "ploidy_other_dna_measurement"
    t.text     "ploidy_notes"
    t.integer  "hla_report_found",                        limit: 2
    t.date     "hla_test_date"
    t.text     "hla_results"
    t.integer  "cgs_report_found",                        limit: 2
    t.date     "cgs_test_date"
    t.integer  "cgs_normal",                              limit: 2
    t.integer  "cgs_conventional_karyotype_done",         limit: 2
    t.integer  "cgs_hospital_fish_done",                  limit: 2
    t.integer  "cgs_hyperdiploidy_detected",              limit: 2
    t.string   "cgs_hyperdiploidy_by",                    limit: 25
    t.string   "cgs_hyperdiploidy_number_of_chromosomes", limit: 25
    t.integer  "cgs_t12_21",                              limit: 2
    t.integer  "cgs_inv16",                               limit: 2
    t.integer  "cgs_t1_19",                               limit: 2
    t.integer  "cgs_t8_21",                               limit: 2
    t.integer  "cgs_t9_22",                               limit: 2
    t.integer  "cgs_t15_17",                              limit: 2
    t.integer  "cgs_trisomy_4",                           limit: 2
    t.integer  "cgs_trisomy_5",                           limit: 2
    t.integer  "cgs_trisomy_10",                          limit: 2
    t.integer  "cgs_trisomy_17",                          limit: 2
    t.integer  "cgs_trisomy_21",                          limit: 2
    t.integer  "cgs_t4_11_q21_q23",                       limit: 2
    t.integer  "cgs_deletion_6q",                         limit: 2
    t.integer  "cgs_deletion_9p",                         limit: 2
    t.integer  "cgs_t16_16_p13_q22",                      limit: 2
    t.integer  "cgs_trisomy_8",                           limit: 2
    t.integer  "cgs_trisomy_x",                           limit: 2
    t.integer  "cgs_trisomy_6",                           limit: 2
    t.integer  "cgs_trisomy_14",                          limit: 2
    t.integer  "cgs_trisomy_18",                          limit: 2
    t.integer  "cgs_monosomy_7",                          limit: 2
    t.integer  "cgs_deletion_16_q22",                     limit: 2
    t.text     "cgs_others"
    t.text     "cgs_conventional_karyotyping_results"
    t.text     "cgs_hospital_fish_results"
    t.text     "cgs_comments"
    t.integer  "omg_abnormalities_found",                 limit: 2
    t.date     "omg_test_date"
    t.string   "omg_p16",                                 limit: 25
    t.string   "omg_p15",                                 limit: 25
    t.string   "omg_p53",                                 limit: 25
    t.string   "omg_ras",                                 limit: 25
    t.string   "omg_all1",                                limit: 25
    t.string   "omg_wt1",                                 limit: 25
    t.string   "omg_bcr",                                 limit: 25
    t.string   "omg_etv6",                                limit: 25
    t.string   "omg_fish",                                limit: 25
    t.integer  "em_report_found",                         limit: 2
    t.date     "em_test_date"
    t.text     "em_comments"
    t.integer  "cbc_report_found",                        limit: 2
    t.date     "cbc_test_date"
    t.string   "cbc_hemoglobin",                          limit: 25
    t.string   "cbc_leukocyte_count",                     limit: 25
    t.string   "cbc_number_of_blasts",                    limit: 25
    t.string   "cbc_percentage_blasts",                   limit: 25
    t.string   "cbc_platelet_count",                      limit: 25
    t.integer  "csf_report_found",                        limit: 2
    t.date     "csf_test_date"
    t.integer  "csf_blasts_present",                      limit: 2
    t.text     "csf_cytology"
    t.string   "csf_number_of_blasts",                    limit: 25
    t.integer  "csf_pb_contamination",                    limit: 2
    t.string   "csf_rbc",                                 limit: 25
    t.string   "csf_wbc",                                 limit: 25
    t.integer  "ob_skin_report_found",                    limit: 2
    t.date     "ob_skin_date"
    t.integer  "ob_skin_leukemic_cells_present",          limit: 2
    t.integer  "ob_lymph_node_report_found",              limit: 2
    t.date     "ob_lymph_node_date"
    t.integer  "ob_lymph_node_leukemic_cells_present",    limit: 2
    t.integer  "ob_liver_report_found",                   limit: 2
    t.date     "ob_liver_date"
    t.integer  "ob_liver_leukemic_cells_present",         limit: 2
    t.integer  "ob_other_report_found",                   limit: 2
    t.date     "ob_other_date"
    t.string   "ob_other_site_organ"
    t.integer  "ob_other_leukemic_cells_present",         limit: 2
    t.integer  "cxr_report_found",                        limit: 2
    t.date     "cxr_test_date"
    t.string   "cxr_result",                              limit: 25
    t.text     "cxr_mediastinal_mass_description"
    t.integer  "cct_report_found",                        limit: 2
    t.date     "cct_test_date"
    t.string   "cct_result",                              limit: 25
    t.text     "cct_mediastinal_mass_description"
    t.integer  "as_report_found",                         limit: 2
    t.date     "as_test_date"
    t.integer  "as_normal",                               limit: 2
    t.integer  "as_sphenomegaly",                         limit: 2
    t.integer  "as_hepatomegaly",                         limit: 2
    t.integer  "as_lymphadenopathy",                      limit: 2
    t.integer  "as_other_abdominal_masses",               limit: 2
    t.integer  "as_ascities",                             limit: 2
    t.text     "as_other_abnormal_findings"
    t.integer  "ts_report_found",                         limit: 2
    t.date     "ts_test_date"
    t.text     "ts_findings"
    t.integer  "hpr_report_found",                        limit: 2
    t.date     "hpr_test_date"
    t.integer  "hpr_hepatomegaly",                        limit: 2
    t.integer  "hpr_splenomegaly",                        limit: 2
    t.integer  "hpr_down_syndrome_phenotype",             limit: 2
    t.string   "height",                                  limit: 10
    t.string   "height_units",                            limit: 5
    t.string   "weight",                                  limit: 10
    t.string   "weight_units",                            limit: 5
    t.integer  "ds_report_found",                         limit: 2
    t.date     "ds_test_date"
    t.text     "ds_clinical_diagnosis"
    t.integer  "cp_report_found",                         limit: 2
    t.integer  "cp_induction_protocol_used",              limit: 2
    t.string   "cp_induction_protocol_name_and_number"
    t.text     "cp_therapeutic_agents"
    t.integer  "bma07_report_found",                      limit: 2
    t.date     "bma07_test_date"
    t.string   "bma07_classification",                    limit: 25
    t.boolean  "bma07_inconclusive_results"
    t.string   "bma07_percentage_of_blasts",              limit: 25
    t.integer  "bma14_report_found",                      limit: 2
    t.date     "bma14_test_date"
    t.string   "bma14_classification",                    limit: 25
    t.boolean  "bma14_inconclusive_results"
    t.string   "bma14_percentage_of_blasts",              limit: 25
    t.integer  "bma28_report_found",                      limit: 2
    t.date     "bma28_test_date"
    t.string   "bma28_classification",                    limit: 25
    t.boolean  "bma28_inconclusive_results"
    t.string   "bma28_percentage_of_blasts",              limit: 25
    t.integer  "clinical_remission",                      limit: 2
    t.string   "leukemia_class",                          limit: 25
    t.string   "other_all_leukemia_class",                limit: 25
    t.string   "other_aml_leukemia_class",                limit: 25
    t.string   "icdo_classification_number",              limit: 25
    t.text     "icdo_classification_description"
    t.string   "leukemia_lineage",                        limit: 25
    t.integer  "pe_report_found",                         limit: 2
    t.date     "pe_test_date"
    t.integer  "pe_gingival_infiltrates",                 limit: 2
    t.integer  "pe_leukemic_skin_infiltrates",            limit: 2
    t.integer  "pe_lymphadenopathy",                      limit: 2
    t.text     "pe_lymphadenopathy_description"
    t.integer  "pe_splenomegaly",                         limit: 2
    t.string   "pe_splenomegaly_size"
    t.integer  "pe_hepatomegaly",                         limit: 2
    t.string   "pe_hepatomegaly_size"
    t.integer  "pe_testicular_mass",                      limit: 2
    t.integer  "pe_other_soft_tissue",                    limit: 2
    t.string   "pe_other_soft_tissue_location"
    t.string   "pe_other_soft_tissue_size"
    t.text     "pe_neurological_abnormalities"
    t.text     "pe_other_abnormal_findings"
    t.string   "abstracted_by"
    t.date     "abstracted_on"
    t.string   "reviewed_by"
    t.date     "reviewed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", force: true do |t|
    t.integer  "study_subject_id"
    t.integer  "current_address",                 default: 1
    t.integer  "address_at_diagnosis"
    t.string   "other_data_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.string   "data_source"
    t.string   "line_1"
    t.string   "line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip",                  limit: 10
    t.integer  "external_address_id"
    t.string   "county"
    t.string   "unit"
    t.string   "country"
    t.boolean  "needs_geocoded",                  default: true
    t.boolean  "geocoding_failed",                default: false
    t.float    "longitude",            limit: 24
    t.float    "latitude",             limit: 24
    t.text     "geocoding_response"
    t.string   "address_type"
  end

  add_index "addresses", ["external_address_id"], name: "index_addresses_on_external_address_id", unique: true, using: :btree
  add_index "addresses", ["needs_geocoded", "geocoding_failed"], name: "index_addresses_on_needs_geocoded_and_geocoding_failed", using: :btree
  add_index "addresses", ["study_subject_id"], name: "index_addresses_on_study_subject_id", using: :btree

  create_table "alternate_contacts", force: true do |t|
    t.integer  "study_subject_id"
    t.string   "name"
    t.string   "relation"
    t.string   "line_1"
    t.string   "line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_number_1"
    t.string   "phone_number_2"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alternate_contacts", ["study_subject_id"], name: "index_alternate_contacts_on_study_subject_id", using: :btree

  create_table "bc_requests", force: true do |t|
    t.integer  "study_subject_id"
    t.date     "sent_on"
    t.string   "status"
    t.text     "notes"
    t.boolean  "is_found"
    t.date     "returned_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "birth_data", force: true do |t|
    t.integer  "birth_datum_update_id"
    t.integer  "study_subject_id"
    t.string   "master_id"
    t.string   "found_in_state_db"
    t.string   "birth_state"
    t.string   "match_confidence"
    t.string   "case_control_flag"
    t.integer  "length_of_gestation_weeks"
    t.integer  "father_race_ethn_1"
    t.integer  "father_race_ethn_2"
    t.integer  "father_race_ethn_3"
    t.integer  "mother_race_ethn_1"
    t.integer  "mother_race_ethn_2"
    t.integer  "mother_race_ethn_3"
    t.string   "abnormal_conditions"
    t.integer  "apgar_1min"
    t.integer  "apgar_5min"
    t.integer  "apgar_10min"
    t.integer  "birth_order"
    t.string   "birth_type"
    t.decimal  "birth_weight_gms",                            precision: 8, scale: 2
    t.string   "complications_labor_delivery"
    t.string   "complications_pregnancy"
    t.string   "county_of_delivery"
    t.integer  "daily_cigarette_cnt_1st_tri"
    t.integer  "daily_cigarette_cnt_2nd_tri"
    t.integer  "daily_cigarette_cnt_3rd_tri"
    t.integer  "daily_cigarette_cnt_3mo_preconc"
    t.date     "dob"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "father_industry"
    t.date     "father_dob"
    t.string   "father_hispanic_origin_code"
    t.string   "father_first_name"
    t.string   "father_middle_name"
    t.string   "father_last_name"
    t.string   "father_occupation"
    t.integer  "father_yrs_educ"
    t.string   "fetal_presentation_at_birth"
    t.string   "forceps_attempt_unsuccessful"
    t.date     "last_live_birth_on"
    t.date     "last_menses_on"
    t.date     "last_termination_on"
    t.integer  "length_of_gestation_days"
    t.integer  "live_births_now_deceased"
    t.integer  "live_births_now_living"
    t.string   "local_registrar_district"
    t.string   "local_registrar_no"
    t.string   "method_of_delivery"
    t.string   "month_prenatal_care_began"
    t.string   "mother_residence_line_1"
    t.string   "mother_residence_city"
    t.string   "mother_residence_county"
    t.string   "mother_residence_county_ef"
    t.string   "mother_residence_state"
    t.string   "mother_residence_zip"
    t.integer  "mother_weight_at_delivery"
    t.string   "mother_birthplace"
    t.string   "mother_birthplace_state"
    t.date     "mother_dob"
    t.string   "mother_first_name"
    t.string   "mother_middle_name"
    t.string   "mother_maiden_name"
    t.integer  "mother_height"
    t.string   "mother_hispanic_origin_code"
    t.string   "mother_industry"
    t.string   "mother_occupation"
    t.string   "mother_received_wic"
    t.integer  "mother_weight_pre_pregnancy"
    t.integer  "mother_yrs_educ"
    t.integer  "ob_gestation_estimate_at_delivery"
    t.integer  "prenatal_care_visit_count"
    t.string   "sex"
    t.string   "state_registrar_no"
    t.integer  "term_count_20_plus_weeks"
    t.integer  "term_count_pre_20_weeks"
    t.string   "vacuum_attempt_unsuccessful"
    t.integer  "control_number"
    t.string   "father_ssn"
    t.string   "mother_ssn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "birth_data_file_name"
    t.integer  "childid"
    t.string   "deceased"
    t.date     "case_dob"
    t.text     "ccls_import_notes"
    t.text     "study_subject_changes"
    t.string   "derived_state_file_no_last6",       limit: 6
    t.string   "derived_local_file_no_last6",       limit: 6
  end

  add_index "birth_data", ["study_subject_id"], name: "index_birth_data_on_study_subject_id", using: :btree

  create_table "blood_spot_requests", force: true do |t|
    t.integer  "study_subject_id"
    t.date     "sent_on"
    t.date     "returned_on"
    t.boolean  "is_found"
    t.string   "status"
    t.text     "notes"
    t.string   "request_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "candidate_controls", force: true do |t|
    t.integer  "birth_datum_id"
    t.string   "related_patid",    limit: 5
    t.integer  "study_subject_id"
    t.date     "assigned_on"
    t.boolean  "reject_candidate",           default: false, null: false
    t.string   "rejection_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counties", force: true do |t|
    t.string   "name"
    t.string   "fips_code",    limit: 5
    t.string   "state_abbrev", limit: 2
    t.string   "usc_code",     limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counties", ["state_abbrev"], name: "index_counties_on_state_abbrev", using: :btree

  create_table "enrollments", force: true do |t|
    t.integer  "study_subject_id"
    t.integer  "project_id"
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
    t.text     "notes"
    t.integer  "use_smp_future_rsrch"
    t.integer  "use_smp_future_cancer_rsrch"
    t.integer  "use_smp_future_other_rsrch"
    t.integer  "share_smp_with_others"
    t.integer  "contact_for_related_study"
    t.integer  "provide_saliva_smp"
    t.integer  "receive_study_findings"
    t.boolean  "refused_by_physician"
    t.boolean  "refused_by_family"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "assigned_for_interview_at"
    t.date     "interview_completed_on"
    t.string   "tracing_status"
    t.datetime "vaccine_authorization_received_at"
  end

  add_index "enrollments", ["project_id", "study_subject_id"], name: "index_enrollments_on_project_id_and_study_subject_id", unique: true, using: :btree
  add_index "enrollments", ["study_subject_id"], name: "index_enrollments_on_study_subject_id", using: :btree

  create_table "guides", force: true do |t|
    t.string   "controller"
    t.string   "action"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guides", ["controller", "action"], name: "index_guides_on_controller_and_action", unique: true, using: :btree

  create_table "hospitals", force: true do |t|
    t.integer  "organization_id"
    t.boolean  "has_irb_waiver",  default: false, null: false
    t.boolean  "is_active",       default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hospitals", ["organization_id"], name: "index_hospitals_on_organization_id", using: :btree

  create_table "icf_master_ids", force: true do |t|
    t.string   "icf_master_id",    limit: 9
    t.date     "assigned_on"
    t.integer  "study_subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "icf_master_ids", ["icf_master_id"], name: "index_icf_master_ids_on_icf_master_id", unique: true, using: :btree
  add_index "icf_master_ids", ["study_subject_id"], name: "index_icf_master_ids_on_study_subject_id", unique: true, using: :btree

  create_table "ineligible_reasons", force: true do |t|
    t.integer  "position"
    t.string   "key",         null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ineligible_reasons", ["description"], name: "index_ineligible_reasons_on_description", unique: true, using: :btree
  add_index "ineligible_reasons", ["key"], name: "index_ineligible_reasons_on_key", unique: true, using: :btree

  create_table "languages", force: true do |t|
    t.integer  "position"
    t.string   "key",         null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code"
  end

  add_index "languages", ["code"], name: "index_languages_on_code", unique: true, using: :btree
  add_index "languages", ["key"], name: "index_languages_on_key", unique: true, using: :btree

  create_table "medical_record_requests", force: true do |t|
    t.integer  "study_subject_id"
    t.date     "sent_on"
    t.date     "returned_on"
    t.boolean  "is_found"
    t.string   "status"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operational_event_types", force: true do |t|
    t.integer  "position"
    t.string   "key",            null: false
    t.string   "description"
    t.string   "event_category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operational_event_types", ["description"], name: "index_operational_event_types_on_description", unique: true, using: :btree
  add_index "operational_event_types", ["key"], name: "index_operational_event_types_on_key", unique: true, using: :btree

  create_table "operational_events", force: true do |t|
    t.integer  "operational_event_type_id"
    t.datetime "occurred_at"
    t.integer  "study_subject_id"
    t.integer  "project_id"
    t.string   "description"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operational_events", ["operational_event_type_id"], name: "oe_oeti", using: :btree
  add_index "operational_events", ["project_id"], name: "oe_pi", using: :btree
  add_index "operational_events", ["study_subject_id"], name: "oe_ssi", using: :btree

  create_table "organizations", force: true do |t|
    t.integer  "position"
    t.string   "key",        null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["key"], name: "index_organizations_on_key", unique: true, using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "pages", force: true do |t|
    t.integer  "position"
    t.integer  "parent_id"
    t.boolean  "hide_menu",  default: false
    t.string   "path"
    t.string   "title_en"
    t.string   "title_es"
    t.string   "menu_en"
    t.string   "menu_es"
    t.text     "body_en"
    t.text     "body_es"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", unique: true, using: :btree

  create_table "patients", force: true do |t|
    t.integer  "study_subject_id"
    t.date     "diagnosis_date"
    t.integer  "organization_id"
    t.date     "admit_date"
    t.integer  "sample_was_collected"
    t.string   "admitting_oncologist"
    t.integer  "was_ca_resident_at_diagnosis"
    t.integer  "was_previously_treated"
    t.integer  "was_under_15_at_dx"
    t.string   "raf_zip",                      limit: 10
    t.string   "raf_county"
    t.string   "hospital_no",                  limit: 25
    t.string   "other_diagnosis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagnosis"
  end

  add_index "patients", ["hospital_no", "organization_id"], name: "hosp_org", unique: true, using: :btree
  add_index "patients", ["organization_id"], name: "index_patients_on_organization_id", using: :btree
  add_index "patients", ["study_subject_id"], name: "index_patients_on_study_subject_id", unique: true, using: :btree

  create_table "phone_numbers", force: true do |t|
    t.integer  "position"
    t.integer  "study_subject_id"
    t.string   "phone_number"
    t.boolean  "is_primary"
    t.integer  "current_phone",     default: 1
    t.string   "other_data_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_type"
    t.string   "data_source"
  end

  add_index "phone_numbers", ["study_subject_id"], name: "index_phone_numbers_on_study_subject_id", using: :btree

  create_table "projects", force: true do |t|
    t.integer  "position"
    t.date     "began_on"
    t.date     "ended_on"
    t.string   "key",                  null: false
    t.string   "description"
    t.text     "eligibility_criteria"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["description"], name: "index_projects_on_description", unique: true, using: :btree
  add_index "projects", ["key"], name: "index_projects_on_key", unique: true, using: :btree

  create_table "races", force: true do |t|
    t.integer  "position"
    t.string   "key",         null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code"
  end

  add_index "races", ["code"], name: "index_races_on_code", unique: true, using: :btree
  add_index "races", ["description"], name: "index_races_on_description", unique: true, using: :btree
  add_index "races", ["key"], name: "index_races_on_key", unique: true, using: :btree

  create_table "refusal_reasons", force: true do |t|
    t.integer  "position"
    t.string   "key",         null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refusal_reasons", ["description"], name: "index_refusal_reasons_on_description", unique: true, using: :btree
  add_index "refusal_reasons", ["key"], name: "index_refusal_reasons_on_key", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.integer  "position"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "sample_locations", force: true do |t|
    t.integer  "organization_id"
    t.boolean  "is_active",       default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sample_locations", ["organization_id"], name: "index_sample_locations_on_organization_id", using: :btree

  create_table "sample_transfers", force: true do |t|
    t.integer  "sample_id"
    t.integer  "source_org_id"
    t.integer  "destination_org_id"
    t.date     "sent_on"
    t.string   "status"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_types", force: true do |t|
    t.integer  "position"
    t.integer  "parent_id"
    t.string   "key",                                null: false
    t.string   "description"
    t.boolean  "for_new_sample",      default: true, null: false
    t.integer  "t2k_sample_type_id"
    t.string   "gegl_sample_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sample_types", ["description"], name: "index_sample_types_on_description", unique: true, using: :btree
  add_index "sample_types", ["key"], name: "index_sample_types_on_key", unique: true, using: :btree
  add_index "sample_types", ["parent_id"], name: "index_sample_types_on_parent_id", using: :btree

  create_table "samples", force: true do |t|
    t.integer  "parent_sample_id"
    t.integer  "sample_type_id"
    t.integer  "project_id"
    t.integer  "study_subject_id"
    t.integer  "location_id"
    t.string   "aliquot_or_sample_on_receipt"
    t.datetime "sent_to_subject_at"
    t.datetime "collected_from_subject_at"
    t.datetime "shipped_to_ccls_at"
    t.datetime "received_by_ccls_at"
    t.datetime "sent_to_lab_at"
    t.datetime "received_by_lab_at"
    t.string   "external_id"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sample_format"
    t.string   "sample_temperature"
    t.text     "notes"
  end

  add_index "samples", ["study_subject_id"], name: "index_samples_on_study_subject_id", using: :btree

  create_table "states", force: true do |t|
    t.integer  "position"
    t.string   "code",                        null: false
    t.string   "name",                        null: false
    t.string   "fips_country_code", limit: 2, null: false
    t.string   "fips_state_code",   limit: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree
  add_index "states", ["fips_country_code"], name: "index_states_on_fips_country_code", using: :btree
  add_index "states", ["fips_state_code"], name: "index_states_on_fips_state_code", unique: true, using: :btree
  add_index "states", ["name"], name: "index_states_on_name", unique: true, using: :btree

  create_table "study_subjects", force: true do |t|
    t.integer  "hispanicity"
    t.date     "reference_date"
    t.string   "sex"
    t.boolean  "do_not_contact",                         default: false, null: false
    t.integer  "mother_yrs_educ"
    t.integer  "father_yrs_educ"
    t.string   "birth_type"
    t.integer  "mother_hispanicity"
    t.integer  "father_hispanicity"
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
    t.string   "guardian_first_name"
    t.string   "guardian_middle_name"
    t.string   "guardian_last_name"
    t.string   "other_guardian_relationship"
    t.integer  "mother_race_code"
    t.integer  "father_race_code"
    t.string   "maiden_name"
    t.string   "birth_year",                  limit: 4
    t.string   "birth_city"
    t.string   "birth_state"
    t.string   "birth_country"
    t.string   "other_mother_race"
    t.string   "other_father_race"
    t.integer  "childid"
    t.string   "patid",                       limit: 4
    t.string   "case_control_type",           limit: 1
    t.integer  "orderno"
    t.string   "related_childid"
    t.string   "related_case_childid"
    t.string   "subjectid",                   limit: 6
    t.string   "matchingid",                  limit: 6
    t.string   "familyid",                    limit: 6
    t.string   "state_id_no"
    t.string   "childidwho",                  limit: 10
    t.string   "studyid",                     limit: 14
    t.string   "newid",                       limit: 6
    t.string   "icf_master_id",               limit: 9
    t.string   "state_registrar_no"
    t.string   "local_registrar_no"
    t.boolean  "is_matched"
    t.integer  "phase"
    t.integer  "hispanicity_mex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vital_status",                limit: 20
    t.integer  "addresses_count",                        default: 0
    t.integer  "abstracts_count",                        default: 0
    t.string   "case_icf_master_id",          limit: 9
    t.string   "mother_icf_master_id",        limit: 9
    t.string   "subject_type",                limit: 20
    t.integer  "samples_count",                          default: 0
    t.integer  "cdcid"
    t.integer  "operational_events_count",               default: 0
    t.integer  "phone_numbers_count",                    default: 0
    t.integer  "interviews_count",                       default: 0
    t.boolean  "needs_reindexed",                        default: false
    t.integer  "enrollments_count",                      default: 0
    t.integer  "replication_id"
    t.string   "guardian_relationship"
  end

  add_index "study_subjects", ["childid"], name: "index_study_subjects_on_childid", unique: true, using: :btree
  add_index "study_subjects", ["familyid"], name: "index_study_subjects_on_familyid", using: :btree
  add_index "study_subjects", ["icf_master_id"], name: "index_study_subjects_on_icf_master_id", unique: true, using: :btree
  add_index "study_subjects", ["local_registrar_no"], name: "index_study_subjects_on_local_registrar_no", unique: true, using: :btree
  add_index "study_subjects", ["matchingid"], name: "index_study_subjects_on_matchingid", using: :btree
  add_index "study_subjects", ["needs_reindexed"], name: "index_study_subjects_on_needs_reindexed", using: :btree
  add_index "study_subjects", ["patid", "case_control_type", "orderno"], name: "piccton", unique: true, using: :btree
  add_index "study_subjects", ["phase", "case_icf_master_id"], name: "index_study_subjects_on_phase_and_case_icf_master_id", using: :btree
  add_index "study_subjects", ["phase", "mother_icf_master_id"], name: "index_study_subjects_on_phase_and_mother_icf_master_id", using: :btree
  add_index "study_subjects", ["replication_id"], name: "index_study_subjects_on_replication_id", using: :btree
  add_index "study_subjects", ["state_id_no"], name: "index_study_subjects_on_state_id_no", unique: true, using: :btree
  add_index "study_subjects", ["state_registrar_no"], name: "index_study_subjects_on_state_registrar_no", unique: true, using: :btree
  add_index "study_subjects", ["studyid"], name: "index_study_subjects_on_studyid", unique: true, using: :btree
  add_index "study_subjects", ["subject_type"], name: "index_study_subjects_on_subject_type", using: :btree
  add_index "study_subjects", ["subjectid"], name: "index_study_subjects_on_subjectid", unique: true, using: :btree
  add_index "study_subjects", ["vital_status"], name: "index_study_subjects_on_vital_status", using: :btree

  create_table "subject_languages", force: true do |t|
    t.integer  "study_subject_id"
    t.integer  "language_code"
    t.string   "other_language"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_languages", ["study_subject_id"], name: "index_subject_languages_on_study_subject_id", using: :btree

  create_table "subject_races", force: true do |t|
    t.integer  "study_subject_id"
    t.integer  "race_code"
    t.boolean  "is_primary",       default: false, null: false
    t.string   "other_race"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_races", ["study_subject_id"], name: "index_subject_races_on_study_subject_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "uid"
    t.string   "sn"
    t.string   "displayname"
    t.string   "mail"
    t.string   "telephonenumber"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["sn"], name: "index_users_on_sn", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

  create_table "zip_codes", force: true do |t|
    t.string   "zip_code",   limit: 5, null: false
    t.string   "city",                 null: false
    t.string   "state",                null: false
    t.string   "zip_class",            null: false
    t.integer  "county_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zip_codes", ["zip_code"], name: "index_zip_codes_on_zip_code", unique: true, using: :btree

end
