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

ActiveRecord::Schema.define(version: 20170628030121) do

  create_table "abstracts", force: :cascade do |t|
    t.string   "entry_1_by_uid",                          limit: 255
    t.string   "entry_2_by_uid",                          limit: 255
    t.string   "merged_by_uid",                           limit: 255
    t.integer  "study_subject_id",                        limit: 4
    t.integer  "bmb_report_found",                        limit: 2
    t.date     "bmb_test_date"
    t.integer  "bmb_percentage_blasts_known",             limit: 2
    t.string   "bmb_percentage_blasts",                   limit: 25
    t.text     "bmb_comments",                            limit: 65535
    t.integer  "bma_report_found",                        limit: 2
    t.date     "bma_test_date"
    t.integer  "bma_percentage_blasts_known",             limit: 2
    t.string   "bma_percentage_blasts",                   limit: 25
    t.text     "bma_comments",                            limit: 65535
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
    t.text     "other_markers",                           limit: 65535
    t.text     "marker_comments",                         limit: 65535
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
    t.text     "ploidy_other_dna_measurement",            limit: 65535
    t.text     "ploidy_notes",                            limit: 65535
    t.integer  "hla_report_found",                        limit: 2
    t.date     "hla_test_date"
    t.text     "hla_results",                             limit: 65535
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
    t.text     "cgs_others",                              limit: 65535
    t.text     "cgs_conventional_karyotyping_results",    limit: 65535
    t.text     "cgs_hospital_fish_results",               limit: 65535
    t.text     "cgs_comments",                            limit: 65535
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
    t.text     "em_comments",                             limit: 65535
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
    t.text     "csf_cytology",                            limit: 65535
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
    t.string   "ob_other_site_organ",                     limit: 255
    t.integer  "ob_other_leukemic_cells_present",         limit: 2
    t.integer  "cxr_report_found",                        limit: 2
    t.date     "cxr_test_date"
    t.string   "cxr_result",                              limit: 25
    t.text     "cxr_mediastinal_mass_description",        limit: 65535
    t.integer  "cct_report_found",                        limit: 2
    t.date     "cct_test_date"
    t.string   "cct_result",                              limit: 25
    t.text     "cct_mediastinal_mass_description",        limit: 65535
    t.integer  "as_report_found",                         limit: 2
    t.date     "as_test_date"
    t.integer  "as_normal",                               limit: 2
    t.integer  "as_sphenomegaly",                         limit: 2
    t.integer  "as_hepatomegaly",                         limit: 2
    t.integer  "as_lymphadenopathy",                      limit: 2
    t.integer  "as_other_abdominal_masses",               limit: 2
    t.integer  "as_ascities",                             limit: 2
    t.text     "as_other_abnormal_findings",              limit: 65535
    t.integer  "ts_report_found",                         limit: 2
    t.date     "ts_test_date"
    t.text     "ts_findings",                             limit: 65535
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
    t.text     "ds_clinical_diagnosis",                   limit: 65535
    t.integer  "cp_report_found",                         limit: 2
    t.integer  "cp_induction_protocol_used",              limit: 2
    t.string   "cp_induction_protocol_name_and_number",   limit: 255
    t.text     "cp_therapeutic_agents",                   limit: 65535
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
    t.text     "icdo_classification_description",         limit: 65535
    t.string   "leukemia_lineage",                        limit: 25
    t.integer  "pe_report_found",                         limit: 2
    t.date     "pe_test_date"
    t.integer  "pe_gingival_infiltrates",                 limit: 2
    t.integer  "pe_leukemic_skin_infiltrates",            limit: 2
    t.integer  "pe_lymphadenopathy",                      limit: 2
    t.text     "pe_lymphadenopathy_description",          limit: 65535
    t.integer  "pe_splenomegaly",                         limit: 2
    t.string   "pe_splenomegaly_size",                    limit: 255
    t.integer  "pe_hepatomegaly",                         limit: 2
    t.string   "pe_hepatomegaly_size",                    limit: 255
    t.integer  "pe_testicular_mass",                      limit: 2
    t.integer  "pe_other_soft_tissue",                    limit: 2
    t.string   "pe_other_soft_tissue_location",           limit: 255
    t.string   "pe_other_soft_tissue_size",               limit: 255
    t.text     "pe_neurological_abnormalities",           limit: 65535
    t.text     "pe_other_abnormal_findings",              limit: 65535
    t.string   "abstracted_by",                           limit: 255
    t.date     "abstracted_on"
    t.string   "reviewed_by",                             limit: 255
    t.date     "reviewed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", force: :cascade do |t|
    t.integer  "study_subject_id",     limit: 4
    t.integer  "current_address",      limit: 4,     default: 1
    t.integer  "address_at_diagnosis", limit: 4
    t.string   "other_data_source",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes",                limit: 65535
    t.string   "data_source",          limit: 255
    t.string   "line_1",               limit: 255
    t.string   "line_2",               limit: 255
    t.string   "city",                 limit: 255
    t.string   "state",                limit: 255
    t.string   "zip",                  limit: 10
    t.integer  "external_address_id",  limit: 4
    t.string   "county",               limit: 255
    t.string   "unit",                 limit: 255
    t.string   "country",              limit: 255
    t.boolean  "needs_geocoded",                     default: true
    t.boolean  "geocoding_failed",                   default: false
    t.float    "longitude",            limit: 24
    t.float    "latitude",             limit: 24
    t.text     "geocoding_response",   limit: 65535
    t.string   "address_type",         limit: 255
  end

  add_index "addresses", ["external_address_id"], name: "index_addresses_on_external_address_id", unique: true, using: :btree
  add_index "addresses", ["needs_geocoded", "geocoding_failed"], name: "index_addresses_on_needs_geocoded_and_geocoding_failed", using: :btree
  add_index "addresses", ["study_subject_id"], name: "index_addresses_on_study_subject_id", using: :btree

  create_table "alternate_contacts", force: :cascade do |t|
    t.integer  "study_subject_id", limit: 4
    t.string   "name",             limit: 255
    t.string   "relation",         limit: 255
    t.string   "line_1",           limit: 255
    t.string   "line_2",           limit: 255
    t.string   "city",             limit: 255
    t.string   "state",            limit: 255
    t.string   "zip",              limit: 255
    t.string   "phone_number_1",   limit: 255
    t.string   "phone_number_2",   limit: 255
    t.text     "notes",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alternate_contacts", ["study_subject_id"], name: "index_alternate_contacts_on_study_subject_id", using: :btree

  create_table "bc_requests", force: :cascade do |t|
    t.integer  "study_subject_id", limit: 4
    t.date     "sent_on"
    t.string   "status",           limit: 255
    t.text     "notes",            limit: 65535
    t.boolean  "is_found"
    t.date     "returned_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "birth_data", force: :cascade do |t|
    t.integer  "study_subject_id",                       limit: 4
    t.string   "master_id",                              limit: 255
    t.string   "found_in_state_db",                      limit: 255
    t.string   "birth_state",                            limit: 255
    t.string   "match_confidence",                       limit: 255
    t.string   "case_control_flag",                      limit: 255
    t.integer  "length_of_gestation_weeks",              limit: 4
    t.integer  "father_race_ethn_1",                     limit: 4
    t.integer  "father_race_ethn_2",                     limit: 4
    t.integer  "father_race_ethn_3",                     limit: 4
    t.integer  "mother_race_ethn_1",                     limit: 4
    t.integer  "mother_race_ethn_2",                     limit: 4
    t.integer  "mother_race_ethn_3",                     limit: 4
    t.string   "abnormal_conditions",                    limit: 255
    t.integer  "apgar_1min",                             limit: 4
    t.integer  "apgar_5min",                             limit: 4
    t.integer  "apgar_10min",                            limit: 4
    t.integer  "birth_order",                            limit: 4
    t.string   "birth_type",                             limit: 255
    t.decimal  "birth_weight_gms",                                     precision: 8, scale: 2
    t.string   "complications_labor_delivery",           limit: 255
    t.string   "complications_pregnancy",                limit: 255
    t.string   "county_of_delivery",                     limit: 255
    t.integer  "daily_cigarette_cnt_1st_tri",            limit: 4
    t.integer  "daily_cigarette_cnt_2nd_tri",            limit: 4
    t.integer  "daily_cigarette_cnt_3rd_tri",            limit: 4
    t.integer  "daily_cigarette_cnt_3mo_preconc",        limit: 4
    t.date     "dob"
    t.string   "first_name",                             limit: 255
    t.string   "middle_name",                            limit: 255
    t.string   "last_name",                              limit: 255
    t.string   "father_industry",                        limit: 255
    t.date     "father_dob"
    t.string   "father_hispanic_origin_code",            limit: 255
    t.string   "father_first_name",                      limit: 255
    t.string   "father_middle_name",                     limit: 255
    t.string   "father_last_name",                       limit: 255
    t.string   "father_occupation",                      limit: 255
    t.integer  "father_yrs_educ",                        limit: 4
    t.string   "fetal_presentation_at_birth",            limit: 255
    t.string   "forceps_attempt_unsuccessful",           limit: 255
    t.date     "last_live_birth_on"
    t.date     "last_menses_on"
    t.date     "last_termination_on"
    t.integer  "length_of_gestation_days",               limit: 4
    t.integer  "live_births_now_deceased",               limit: 4
    t.integer  "live_births_now_living",                 limit: 4
    t.string   "local_registrar_district",               limit: 255
    t.string   "do_not_use_local_registrar_no",          limit: 255
    t.string   "method_of_delivery",                     limit: 255
    t.string   "month_prenatal_care_began",              limit: 255
    t.string   "mother_residence_line_1",                limit: 255
    t.string   "mother_residence_city",                  limit: 255
    t.string   "mother_residence_county",                limit: 255
    t.string   "mother_residence_county_ef",             limit: 255
    t.string   "mother_residence_state",                 limit: 255
    t.string   "mother_residence_zip",                   limit: 255
    t.integer  "mother_weight_at_delivery",              limit: 4
    t.string   "mother_birthplace",                      limit: 255
    t.string   "mother_birthplace_state",                limit: 255
    t.date     "mother_dob"
    t.string   "mother_first_name",                      limit: 255
    t.string   "mother_middle_name",                     limit: 255
    t.string   "mother_maiden_name",                     limit: 255
    t.integer  "mother_height",                          limit: 4
    t.string   "mother_hispanic_origin_code",            limit: 255
    t.string   "mother_industry",                        limit: 255
    t.string   "mother_occupation",                      limit: 255
    t.string   "mother_received_wic",                    limit: 255
    t.integer  "mother_weight_pre_pregnancy",            limit: 4
    t.integer  "mother_yrs_educ",                        limit: 4
    t.integer  "ob_gestation_estimate_at_delivery",      limit: 4
    t.integer  "prenatal_care_visit_count",              limit: 4
    t.string   "sex",                                    limit: 255
    t.string   "do_not_use_state_registrar_no",          limit: 255
    t.integer  "term_count_20_plus_weeks",               limit: 4
    t.integer  "term_count_pre_20_weeks",                limit: 4
    t.string   "vacuum_attempt_unsuccessful",            limit: 255
    t.integer  "control_number",                         limit: 4
    t.string   "father_ssn",                             limit: 255
    t.string   "mother_ssn",                             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "birth_data_file_name",                   limit: 255
    t.integer  "childid",                                limit: 4
    t.string   "deceased",                               limit: 255
    t.date     "case_dob"
    t.text     "ccls_import_notes",                      limit: 65535
    t.text     "study_subject_changes",                  limit: 65535
    t.string   "do_not_use_derived_state_file_no_last6", limit: 6
    t.string   "do_not_use_derived_local_file_no_last6", limit: 6
  end

  add_index "birth_data", ["study_subject_id"], name: "index_birth_data_on_study_subject_id", using: :btree

  create_table "blood_spot_requests", force: :cascade do |t|
    t.integer  "study_subject_id", limit: 4
    t.date     "sent_on"
    t.date     "returned_on"
    t.boolean  "is_found"
    t.string   "status",           limit: 255
    t.text     "notes",            limit: 65535
    t.string   "request_type",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "candidate_controls", force: :cascade do |t|
    t.integer  "birth_datum_id",   limit: 4
    t.string   "related_patid",    limit: 5
    t.integer  "study_subject_id", limit: 4
    t.date     "assigned_on"
    t.boolean  "reject_candidate",             default: false, null: false
    t.string   "rejection_reason", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counties", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "fips_code",    limit: 5
    t.string   "state_abbrev", limit: 2
    t.string   "usc_code",     limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counties", ["state_abbrev"], name: "index_counties_on_state_abbrev", using: :btree

  create_table "enrollments", force: :cascade do |t|
    t.integer  "study_subject_id",                  limit: 4
    t.integer  "project_id",                        limit: 4
    t.integer  "is_candidate",                      limit: 4
    t.integer  "is_eligible",                       limit: 4
    t.integer  "ineligible_reason_id",              limit: 4
    t.string   "other_ineligible_reason",           limit: 255
    t.integer  "consented",                         limit: 4
    t.date     "consented_on"
    t.integer  "refusal_reason_id",                 limit: 4
    t.string   "other_refusal_reason",              limit: 255
    t.integer  "is_chosen",                         limit: 4
    t.string   "reason_not_chosen",                 limit: 255
    t.integer  "terminated_participation",          limit: 4
    t.string   "terminated_reason",                 limit: 255
    t.integer  "is_complete",                       limit: 4
    t.date     "completed_on"
    t.text     "notes",                             limit: 65535
    t.integer  "use_smp_future_rsrch",              limit: 4
    t.integer  "use_smp_future_cancer_rsrch",       limit: 4
    t.integer  "use_smp_future_other_rsrch",        limit: 4
    t.integer  "share_smp_with_others",             limit: 4
    t.integer  "contact_for_related_study",         limit: 4
    t.integer  "provide_saliva_smp",                limit: 4
    t.integer  "receive_study_findings",            limit: 4
    t.boolean  "refused_by_physician"
    t.boolean  "refused_by_family"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "assigned_for_interview_at"
    t.date     "interview_completed_on"
    t.string   "tracing_status",                    limit: 255
    t.datetime "vaccine_authorization_received_at"
  end

  add_index "enrollments", ["project_id", "study_subject_id"], name: "index_enrollments_on_project_id_and_study_subject_id", unique: true, using: :btree
  add_index "enrollments", ["study_subject_id"], name: "index_enrollments_on_study_subject_id", using: :btree

  create_table "guides", force: :cascade do |t|
    t.string   "controller", limit: 255
    t.string   "action",     limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guides", ["controller", "action"], name: "index_guides_on_controller_and_action", unique: true, using: :btree

  create_table "hospitals", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.boolean  "has_irb_waiver",            default: false, null: false
    t.boolean  "is_active",                 default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hospitals", ["organization_id"], name: "index_hospitals_on_organization_id", using: :btree

  create_table "icf_master_ids", force: :cascade do |t|
    t.string   "icf_master_id",    limit: 9
    t.date     "assigned_on"
    t.integer  "study_subject_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "icf_master_ids", ["icf_master_id"], name: "index_icf_master_ids_on_icf_master_id", unique: true, using: :btree
  add_index "icf_master_ids", ["study_subject_id"], name: "index_icf_master_ids_on_study_subject_id", unique: true, using: :btree

  create_table "ineligible_reasons", force: :cascade do |t|
    t.integer  "position",    limit: 4
    t.string   "key",         limit: 255, null: false
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ineligible_reasons", ["description"], name: "index_ineligible_reasons_on_description", unique: true, using: :btree
  add_index "ineligible_reasons", ["key"], name: "index_ineligible_reasons_on_key", unique: true, using: :btree

  create_table "languages", force: :cascade do |t|
    t.integer  "position",    limit: 4
    t.string   "key",         limit: 255, null: false
    t.integer  "code",        limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["code"], name: "index_languages_on_code", unique: true, using: :btree
  add_index "languages", ["key"], name: "index_languages_on_key", unique: true, using: :btree

  create_table "medical_record_requests", force: :cascade do |t|
    t.integer  "study_subject_id", limit: 4
    t.date     "sent_on"
    t.date     "returned_on"
    t.boolean  "is_found"
    t.string   "status",           limit: 255
    t.text     "notes",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operational_event_types", force: :cascade do |t|
    t.integer  "position",       limit: 4
    t.string   "key",            limit: 255, null: false
    t.string   "description",    limit: 255
    t.string   "event_category", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operational_event_types", ["description"], name: "index_operational_event_types_on_description", unique: true, using: :btree
  add_index "operational_event_types", ["key"], name: "index_operational_event_types_on_key", unique: true, using: :btree

  create_table "operational_events", force: :cascade do |t|
    t.integer  "operational_event_type_id", limit: 4
    t.datetime "occurred_at"
    t.integer  "study_subject_id",          limit: 4
    t.integer  "project_id",                limit: 4
    t.string   "description",               limit: 255
    t.text     "notes",                     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operational_events", ["operational_event_type_id"], name: "oe_oeti", using: :btree
  add_index "operational_events", ["project_id"], name: "oe_pi", using: :btree
  add_index "operational_events", ["study_subject_id"], name: "oe_ssi", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.integer  "position",   limit: 4
    t.string   "key",        limit: 255, null: false
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["key"], name: "index_organizations_on_key", unique: true, using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "position",   limit: 4
    t.integer  "parent_id",  limit: 4
    t.boolean  "hide_menu",                default: false
    t.string   "path",       limit: 255
    t.string   "title_en",   limit: 255
    t.string   "title_es",   limit: 255
    t.string   "menu_en",    limit: 255
    t.string   "menu_es",    limit: 255
    t.text     "body_en",    limit: 65535
    t.text     "body_es",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", unique: true, using: :btree

  create_table "patients", force: :cascade do |t|
    t.integer  "study_subject_id",             limit: 4
    t.date     "diagnosis_date"
    t.integer  "organization_id",              limit: 4
    t.date     "admit_date"
    t.integer  "sample_was_collected",         limit: 4
    t.string   "admitting_oncologist",         limit: 255
    t.integer  "was_ca_resident_at_diagnosis", limit: 4
    t.integer  "was_previously_treated",       limit: 4
    t.integer  "was_under_15_at_dx",           limit: 4
    t.string   "raf_zip",                      limit: 10
    t.string   "raf_county",                   limit: 255
    t.string   "hospital_no",                  limit: 25
    t.string   "other_diagnosis",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagnosis",                    limit: 255
  end

  add_index "patients", ["hospital_no", "organization_id"], name: "hosp_org", unique: true, using: :btree
  add_index "patients", ["organization_id"], name: "index_patients_on_organization_id", using: :btree
  add_index "patients", ["study_subject_id"], name: "index_patients_on_study_subject_id", unique: true, using: :btree

  create_table "phone_numbers", force: :cascade do |t|
    t.integer  "position",          limit: 4
    t.integer  "study_subject_id",  limit: 4
    t.string   "phone_number",      limit: 255
    t.boolean  "is_primary"
    t.integer  "current_phone",     limit: 4,   default: 1
    t.string   "other_data_source", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_type",        limit: 255
    t.string   "data_source",       limit: 255
  end

  add_index "phone_numbers", ["study_subject_id"], name: "index_phone_numbers_on_study_subject_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "position",             limit: 4
    t.date     "began_on"
    t.date     "ended_on"
    t.string   "key",                  limit: 255,   null: false
    t.string   "description",          limit: 255
    t.text     "eligibility_criteria", limit: 65535
    t.string   "label",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["description"], name: "index_projects_on_description", unique: true, using: :btree
  add_index "projects", ["key"], name: "index_projects_on_key", unique: true, using: :btree

  create_table "races", force: :cascade do |t|
    t.integer  "position",    limit: 4
    t.string   "key",         limit: 255, null: false
    t.integer  "code",        limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "races", ["code"], name: "index_races_on_code", unique: true, using: :btree
  add_index "races", ["description"], name: "index_races_on_description", unique: true, using: :btree
  add_index "races", ["key"], name: "index_races_on_key", unique: true, using: :btree

  create_table "refusal_reasons", force: :cascade do |t|
    t.integer  "position",    limit: 4
    t.string   "key",         limit: 255, null: false
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refusal_reasons", ["description"], name: "index_refusal_reasons_on_description", unique: true, using: :btree
  add_index "refusal_reasons", ["key"], name: "index_refusal_reasons_on_key", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "position",   limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "sample_locations", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.boolean  "is_active",                 default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sample_locations", ["organization_id"], name: "index_sample_locations_on_organization_id", using: :btree

  create_table "sample_transfers", force: :cascade do |t|
    t.integer  "sample_id",          limit: 4
    t.integer  "source_org_id",      limit: 4
    t.integer  "destination_org_id", limit: 4
    t.date     "sent_on"
    t.string   "status",             limit: 255
    t.text     "notes",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_types", force: :cascade do |t|
    t.integer  "position",            limit: 4
    t.integer  "parent_id",           limit: 4
    t.string   "key",                 limit: 255,                null: false
    t.string   "description",         limit: 255
    t.boolean  "for_new_sample",                  default: true, null: false
    t.integer  "t2k_sample_type_id",  limit: 4
    t.string   "gegl_sample_type_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sample_types", ["description"], name: "index_sample_types_on_description", unique: true, using: :btree
  add_index "sample_types", ["key"], name: "index_sample_types_on_key", unique: true, using: :btree
  add_index "sample_types", ["parent_id"], name: "index_sample_types_on_parent_id", using: :btree

  create_table "samples", force: :cascade do |t|
    t.integer  "parent_sample_id",             limit: 4
    t.integer  "sample_type_id",               limit: 4
    t.integer  "project_id",                   limit: 4
    t.integer  "study_subject_id",             limit: 4
    t.integer  "organization_id",              limit: 4
    t.string   "aliquot_or_sample_on_receipt", limit: 255
    t.datetime "sent_to_subject_at"
    t.datetime "collected_from_subject_at"
    t.datetime "shipped_to_ccls_at"
    t.datetime "received_by_ccls_at"
    t.datetime "sent_to_lab_at"
    t.datetime "received_by_lab_at"
    t.string   "external_id",                  limit: 255
    t.string   "external_id_source",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sample_format",                limit: 255
    t.string   "sample_temperature",           limit: 255
    t.text     "notes",                        limit: 65535
    t.integer  "ucsf_item_no",                 limit: 4
    t.integer  "ucb_labno",                    limit: 4
    t.boolean  "ucb_biospecimen_flag"
    t.string   "cdc_id",                       limit: 25
    t.string   "cdc_barcode_id",               limit: 25
  end

  add_index "samples", ["study_subject_id"], name: "index_samples_on_study_subject_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.integer  "position",          limit: 4
    t.string   "code",              limit: 255, null: false
    t.string   "name",              limit: 255, null: false
    t.string   "fips_country_code", limit: 2,   null: false
    t.string   "fips_state_code",   limit: 2,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree
  add_index "states", ["fips_country_code"], name: "index_states_on_fips_country_code", using: :btree
  add_index "states", ["fips_state_code"], name: "index_states_on_fips_state_code", unique: true, using: :btree
  add_index "states", ["name"], name: "index_states_on_name", unique: true, using: :btree

  create_table "study_subjects", force: :cascade do |t|
    t.integer  "hispanicity",                   limit: 4
    t.date     "reference_date"
    t.string   "sex",                           limit: 255
    t.boolean  "do_not_contact",                            default: false, null: false
    t.integer  "mother_yrs_educ",               limit: 4
    t.integer  "father_yrs_educ",               limit: 4
    t.string   "birth_type",                    limit: 255
    t.integer  "mother_hispanicity",            limit: 4
    t.integer  "father_hispanicity",            limit: 4
    t.integer  "mother_hispanicity_mex",        limit: 4
    t.integer  "father_hispanicity_mex",        limit: 4
    t.integer  "mom_is_biomom",                 limit: 4
    t.integer  "dad_is_biodad",                 limit: 4
    t.string   "first_name",                    limit: 255
    t.string   "middle_name",                   limit: 255
    t.string   "last_name",                     limit: 255
    t.date     "dob"
    t.date     "died_on"
    t.string   "mother_first_name",             limit: 255
    t.string   "mother_middle_name",            limit: 255
    t.string   "mother_maiden_name",            limit: 255
    t.string   "mother_last_name",              limit: 255
    t.string   "father_first_name",             limit: 255
    t.string   "father_middle_name",            limit: 255
    t.string   "father_last_name",              limit: 255
    t.string   "guardian_first_name",           limit: 255
    t.string   "guardian_middle_name",          limit: 255
    t.string   "guardian_last_name",            limit: 255
    t.string   "other_guardian_relationship",   limit: 255
    t.integer  "mother_race_code",              limit: 4
    t.integer  "father_race_code",              limit: 4
    t.string   "maiden_name",                   limit: 255
    t.string   "birth_year",                    limit: 4
    t.string   "birth_city",                    limit: 255
    t.string   "birth_state",                   limit: 255
    t.string   "birth_country",                 limit: 255
    t.string   "other_mother_race",             limit: 255
    t.string   "other_father_race",             limit: 255
    t.integer  "childid",                       limit: 4
    t.string   "patid",                         limit: 4
    t.string   "case_control_type",             limit: 1
    t.integer  "orderno",                       limit: 4
    t.string   "related_childid",               limit: 255
    t.string   "related_case_childid",          limit: 255
    t.string   "subjectid",                     limit: 6
    t.string   "matchingid",                    limit: 6
    t.string   "familyid",                      limit: 6
    t.string   "do_not_use_state_id_no",        limit: 255
    t.string   "childidwho",                    limit: 10
    t.string   "studyid",                       limit: 14
    t.string   "newid",                         limit: 6
    t.string   "icf_master_id",                 limit: 9
    t.string   "do_not_use_state_registrar_no", limit: 255
    t.string   "do_not_use_local_registrar_no", limit: 255
    t.boolean  "is_matched"
    t.integer  "phase",                         limit: 4
    t.integer  "hispanicity_mex",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vital_status",                  limit: 20
    t.integer  "addresses_count",               limit: 4,   default: 0
    t.integer  "abstracts_count",               limit: 4,   default: 0
    t.string   "case_icf_master_id",            limit: 9
    t.string   "mother_icf_master_id",          limit: 9
    t.string   "subject_type",                  limit: 20
    t.integer  "samples_count",                 limit: 4,   default: 0
    t.integer  "cdcid",                         limit: 4
    t.integer  "operational_events_count",      limit: 4,   default: 0
    t.integer  "phone_numbers_count",           limit: 4,   default: 0
    t.integer  "interviews_count",              limit: 4,   default: 0
    t.boolean  "needs_reindexed",                           default: false
    t.integer  "enrollments_count",             limit: 4,   default: 0
    t.integer  "replication_id",                limit: 4
    t.string   "guardian_relationship",         limit: 255
    t.string   "sfn_from_cdph",                 limit: 10
  end

  add_index "study_subjects", ["childid"], name: "index_study_subjects_on_childid", unique: true, using: :btree
  add_index "study_subjects", ["do_not_use_local_registrar_no"], name: "index_study_subjects_on_do_not_use_local_registrar_no", unique: true, using: :btree
  add_index "study_subjects", ["do_not_use_state_id_no"], name: "index_study_subjects_on_do_not_use_state_id_no", unique: true, using: :btree
  add_index "study_subjects", ["do_not_use_state_registrar_no"], name: "index_study_subjects_on_do_not_use_state_registrar_no", unique: true, using: :btree
  add_index "study_subjects", ["familyid"], name: "index_study_subjects_on_familyid", using: :btree
  add_index "study_subjects", ["icf_master_id"], name: "index_study_subjects_on_icf_master_id", unique: true, using: :btree
  add_index "study_subjects", ["matchingid"], name: "index_study_subjects_on_matchingid", using: :btree
  add_index "study_subjects", ["needs_reindexed"], name: "index_study_subjects_on_needs_reindexed", using: :btree
  add_index "study_subjects", ["patid", "case_control_type", "orderno"], name: "piccton", unique: true, using: :btree
  add_index "study_subjects", ["phase", "case_icf_master_id"], name: "index_study_subjects_on_phase_and_case_icf_master_id", using: :btree
  add_index "study_subjects", ["phase", "mother_icf_master_id"], name: "index_study_subjects_on_phase_and_mother_icf_master_id", using: :btree
  add_index "study_subjects", ["replication_id"], name: "index_study_subjects_on_replication_id", using: :btree
  add_index "study_subjects", ["studyid"], name: "index_study_subjects_on_studyid", unique: true, using: :btree
  add_index "study_subjects", ["subject_type"], name: "index_study_subjects_on_subject_type", using: :btree
  add_index "study_subjects", ["subjectid"], name: "index_study_subjects_on_subjectid", unique: true, using: :btree
  add_index "study_subjects", ["vital_status"], name: "index_study_subjects_on_vital_status", using: :btree

  create_table "subject_languages", force: :cascade do |t|
    t.integer  "study_subject_id", limit: 4
    t.integer  "language_code",    limit: 4
    t.string   "other_language",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_languages", ["study_subject_id"], name: "index_subject_languages_on_study_subject_id", using: :btree

  create_table "subject_races", force: :cascade do |t|
    t.integer  "study_subject_id", limit: 4
    t.integer  "race_code",        limit: 4
    t.boolean  "is_primary",                   default: false, null: false
    t.string   "other_race",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_races", ["study_subject_id"], name: "index_subject_races_on_study_subject_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "uid",             limit: 255
    t.string   "sn",              limit: 255
    t.string   "displayname",     limit: 255
    t.string   "mail",            limit: 255
    t.string   "telephonenumber", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["sn"], name: "index_users_on_sn", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

  create_table "zip_codes", force: :cascade do |t|
    t.string   "zip_code",   limit: 5,   null: false
    t.string   "city",       limit: 255, null: false
    t.string   "state",      limit: 255, null: false
    t.string   "zip_class",  limit: 255, null: false
    t.integer  "county_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zip_codes", ["zip_code"], name: "index_zip_codes_on_zip_code", unique: true, using: :btree

end
