require 'test_helper'

class AbstractTest < ActiveSupport::TestCase

	assert_should_initially_belong_to :study_subject

	test "explicit Factory abstract test" do
		assert_difference('Abstract.count',1) {
			@abstract = FactoryBot.create(:abstract)
		}
		( not_nil = %w( id created_at updated_at study_subject_id 
				entry_1_by_uid entry_2_by_uid ) ).each do |c|
			assert_not_nil @abstract.send(c), "#{c} is nil"
		end
	end

	test "should return true if abstracts are the same" do
		abstract1 = FactoryBot.create(:abstract)
		abstract2 = FactoryBot.create(:abstract)
		assert abstract1.is_the_same_as?(abstract2)
	end

	test "should return false if abstracts are not the same" do
		abstract1 = FactoryBot.create(:abstract)
		abstract2 = FactoryBot.create(:abstract,
			:icdo_classification_description => 'something' )
		assert !abstract1.is_the_same_as?(abstract2)
	end

	test "should return empty hash if abstracts are the same" do
		abstract1 = FactoryBot.create(:abstract)
		abstract2 = FactoryBot.create(:abstract)
		assert_equal Hash.new, abstract1.diff(abstract2)
		assert       abstract1.diff(abstract2).empty?
	end

	test "should return hash if abstracts are not the same" do
		abstract1 = FactoryBot.create(:abstract)
		abstract2 = FactoryBot.create(:abstract,
			:icdo_classification_description => 'something' )
		assert !abstract1.diff(abstract2).empty?
		assert  abstract1.diff(abstract2).has_key?('icdo_classification_description')
	end

	test "should save a User as entry_1_by" do
		assert_difference('User.count',1) {
		assert_difference('Abstract.count',1) {
			abstract = FactoryBot.create(:abstract,
				:current_user_uid => FactoryBot.create(:user).uid)
			assert abstract.entry_1_by.is_a?(User)	#	will fail if using sqlite database
		} }
	end

	test "should save a User as entry_2_by" do
		assert_difference('User.count',1) {
		assert_difference('Abstract.count',1) {
			abstract = FactoryBot.create(:abstract,
				:current_user_uid => FactoryBot.create(:user).uid)
			assert abstract.entry_2_by.is_a?(User)	#	will fail if using sqlite database
		} }
	end

	test "should save a User as merged_by" do
		assert_difference('User.count',1) {
		assert_difference('Abstract.count',1) {
			abstract = FactoryBot.create(:abstract,
				:merged_by => FactoryBot.create(:user))
			assert_not_nil abstract.merged_by_uid
			assert abstract.merged_by.is_a?(User)
			assert abstract.merged?
		} }
	end

	test "should create first abstract for study_subject with current_user" do
		study_subject = FactoryBot.create(:case_study_subject)
		current_user = FactoryBot.create(:user)
		assert_difference('Abstract.count',1) {
			abstract = FactoryBot.create(:abstract,
				:current_user_uid => current_user.uid,
				:study_subject => study_subject)
			assert_equal abstract.entry_1_by, current_user
			assert_equal abstract.entry_2_by, current_user
			assert_equal abstract.study_subject, study_subject
		}
	end

	test "should create second abstract for study_subject with current_user" do
		study_subject = FactoryBot.create(:case_study_subject)
		current_user = FactoryBot.create(:user)
		FactoryBot.create(:abstract,
			:current_user_uid => current_user.uid,
			:study_subject => study_subject)
		assert_difference('Abstract.count',1) {
			abstract = FactoryBot.create(:abstract,
				:current_user_uid => current_user.uid,
				:study_subject => study_subject)
			assert_equal abstract.entry_1_by, current_user
			assert_equal abstract.entry_2_by, current_user
			assert_equal abstract.study_subject, study_subject
		}
	end

	test "should NOT create third abstract for study_subject with current_user " <<
			"without merging flag" do
		study_subject = FactoryBot.create(:case_study_subject)
		current_user = FactoryBot.create(:user)
		FactoryBot.create(:abstract,
			:current_user_uid => current_user.uid,
			:study_subject => study_subject)
		FactoryBot.create(:abstract,
			:current_user_uid => current_user.uid,
			:study_subject => study_subject)
		assert_difference('Abstract.count',0) {
			#	study_subject.reload is needed here
			abstract = create_abstract(:current_user_uid => current_user.uid,
				:study_subject => study_subject.reload)
			assert abstract.errors.include?(:study_subject_id)
			assert abstract.errors.matching?(:study_subject_id, 
				"Study Subject can only have 2 unmerged abstracts")
		}
	end

	test "should create third abstract for study_subject with current_user " <<
			"with merging flag" do
		study_subject = FactoryBot.create(:case_study_subject)
		current_user = FactoryBot.create(:user)
		FactoryBot.create(:abstract,
			:current_user_uid => current_user.uid,
			:study_subject => study_subject)
		FactoryBot.create(:abstract,
			:current_user_uid => current_user.uid,
			:study_subject => study_subject)	#.reload)
		#	yes, -1 , because when creating the merged, the other 2 go away
		assert_difference('Abstract.count',-1) {
			#	study_subject.reload is needed here
			abstract = FactoryBot.create(:abstract,
				:current_user_uid => current_user.uid,
				:study_subject => study_subject.reload,
				:merging => true)
			assert_equal abstract.merged_by, current_user
			assert_equal abstract.study_subject, study_subject
			assert_not_nil abstract.merged_by_uid
			assert abstract.merged?
		}
		assert_equal 1, study_subject.abstracts.count
		study_subject.reload	#	NEEDED
		assert study_subject.abstracts.first.merged?
	end

	test "should NOT create merged abstract if study_subject already has one" do
		study_subject = FactoryBot.create(:case_study_subject)
		a1 = FactoryBot.create(:abstract,
			:study_subject => study_subject)
		a1.merged_by = FactoryBot.create(:user)
		a1.save
		assert_not_nil study_subject.abstracts.merged
		assert !study_subject.abstracts.merged.empty?
		assert_not_nil a1.merged_by
		assert a1.merged?
		assert_difference('Abstract.count',0) {
			a2 = create_abstract( :study_subject => study_subject, :merging => true)
			assert a2.errors.include?(:study_subject_id)
			assert a2.errors.matching?(:study_subject_id,
				"Study Subject already has a merged abstract")
		}
	end

	assert_should_accept_only_good_values( 
		:bmb_report_found,
		:bmb_percentage_blasts_known,
		:bma_report_found,
		:bma_percentage_blasts_known,
		:ccs_report_found,
		:dfc_report_found,
		:dfc_numerical_data_available,
		:tdt_report_found,
		:ploidy_report_found,
		:hla_report_found,
		:cgs_report_found,
		:cgs_normal,
		:cgs_conventional_karyotype_done,
		:cgs_hospital_fish_done,
		:cgs_hyperdiploidy_detected,
		:cgs_t12_21,
		:cgs_inv16,
		:cgs_t1_19,
		:cgs_t8_21,
		:cgs_t9_22,
		:cgs_t15_17,
		:cgs_trisomy_4,
		:cgs_trisomy_5,
		:cgs_trisomy_10,
		:cgs_trisomy_17,
		:cgs_trisomy_21,
		:cgs_t4_11_q21_q23,
		:cgs_deletion_6q,
		:cgs_deletion_9p,
		:cgs_t16_16_p13_q22,
		:cgs_trisomy_8,
		:cgs_trisomy_x,
		:cgs_trisomy_6,
		:cgs_trisomy_14,
		:cgs_trisomy_18,
		:cgs_monosomy_7,
		:cgs_deletion_16_q22,
		:omg_abnormalities_found,
		:em_report_found,
		:cbc_report_found,
		:csf_report_found,
		:csf_blasts_present,
		:csf_pb_contamination,
		:ob_skin_report_found,
		:ob_skin_leukemic_cells_present,
		:ob_lymph_node_report_found,
		:ob_lymph_node_leukemic_cells_present,
		:ob_liver_report_found,
		:ob_liver_leukemic_cells_present,
		:ob_other_report_found,
		:ob_other_leukemic_cells_present,
		:cxr_report_found,
		:cct_report_found,
		:as_report_found,
		:as_normal,
		:as_sphenomegaly,
		:as_hepatomegaly,
		:as_lymphadenopathy,
		:as_other_abdominal_masses,
		:as_ascities,
		:ts_report_found,
		:hpr_report_found,
		:hpr_hepatomegaly,
		:hpr_splenomegaly,
		:hpr_down_syndrome_phenotype,
		:ds_report_found,
		:cp_report_found,
		:cp_induction_protocol_used,
		:bma07_report_found,
		:bma14_report_found,
		:bma28_report_found,
		:clinical_remission,
		:pe_report_found,
		:pe_gingival_infiltrates,
		:pe_leukemic_skin_infiltrates,
		:pe_lymphadenopathy,
		:pe_splenomegaly,
		:pe_hepatomegaly,
		:pe_testicular_mass,
		:pe_other_soft_tissue,
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_require_length( 
		:height_units,
		:weight_units,
    	:maximum => 5 )

	assert_should_require_length( 
		:height,
		:weight,
    	:maximum => 10 )

	assert_should_require_length( 
		:bmb_percentage_blasts,
		:bma_percentage_blasts,
		:ccs_peroxidase,
		:ccs_sudan_black,
		:ccs_periodic_acid_schiff,
		:ccs_chloroacetate_esterase,
		:ccs_non_specific_esterase,
		:ccs_alpha_naphthyl_butyrate_esterase,
		:ccs_toluidine_blue,
		:ccs_bcl_2,
		:ccs_other,
		:marker_bmk,
		:marker_bml,
		:marker_cd10,
		:marker_cd11b,
		:marker_cd11c,
		:marker_cd13,
		:marker_cd14,
		:marker_cd15,
		:marker_cd16,
		:marker_cd19,
		:marker_cd19_cd10,
		:marker_cd1a,
		:marker_cd2,
		:marker_cd20,
		:marker_cd21,
		:marker_cd22,
		:marker_cd23,
		:marker_cd24,
		:marker_cd25,
		:marker_cd3,
		:marker_cd33,
		:marker_cd34,
		:marker_cd38,
		:marker_cd3_cd4,
		:marker_cd3_cd8,
		:marker_cd4,
		:marker_cd40,
		:marker_cd41,
		:marker_cd45,
		:marker_cd5,
		:marker_cd56,
		:marker_cd57,
		:marker_cd61,
		:marker_cd7,
		:marker_cd71,
		:marker_cd8,
		:marker_cd9,
		:marker_cdw65,
		:marker_glycophorin_a,
		:marker_hla_dr,
		:marker_igm,
		:marker_sig,
		:marker_tdt,
		:omg_p16,
		:omg_p15,
		:omg_p53,
		:omg_ras,
		:omg_all1,
		:omg_wt1,
		:omg_bcr,
		:omg_etv6,
		:omg_fish,
		:cgs_hyperdiploidy_by,
		:cgs_hyperdiploidy_number_of_chromosomes,
		:cbc_hemoglobin,
		:cbc_leukocyte_count,
		:cbc_number_of_blasts,
		:cbc_percentage_blasts,
		:cbc_platelet_count,
		:csf_number_of_blasts,
		:csf_rbc,
		:csf_wbc,
		:cxr_result,
		:cct_result,
		:cp_induction_protocol_name_and_number,
		:bma07_classification,
		:bma07_percentage_of_blasts,
		:bma14_classification,
		:bma14_percentage_of_blasts,
		:bma28_classification,
		:bma28_percentage_of_blasts,
		:leukemia_class,
		:other_all_leukemia_class,
		:other_aml_leukemia_class,
		:icdo_classification_number,
		:leukemia_lineage,
		:ploidy_hypodiploid,
		:ploidy_pseudodiploid,
		:ploidy_hyperdiploid,
		:ploidy_diploid,
		:ploidy_dna_index,
		:ploidy_found_where,
		:tdt_found_where,
		:tdt_result,
		:tdt_numerical_result,
    	:maximum => 25 )

	assert_should_require_length( 
		:ob_other_site_organ,
		:pe_splenomegaly_size,
		:pe_hepatomegaly_size,
		:pe_other_soft_tissue_location,
		:pe_other_soft_tissue_size,
		:abstracted_by,
		:reviewed_by,
    	:maximum => 250 )

	assert_should_require_length( 
		:bmb_comments,
		:bma_comments,
		:other_markers,
		:marker_comments,
		:hla_results,
		:cgs_conventional_karyotyping_results,
		:cgs_hospital_fish_results,
		:csf_cytology,
		:em_comments,
		:cxr_mediastinal_mass_description,
		:cct_mediastinal_mass_description,
		:as_other_abnormal_findings,
		:ts_findings,
		:ds_clinical_diagnosis,
		:cp_therapeutic_agents,
		:icdo_classification_description,
		:ploidy_other_dna_measurement,
		:ploidy_notes,
		:cgs_others,
		:cgs_comments,
		:pe_lymphadenopathy_description,
		:pe_neurological_abnormalities,
		:pe_other_abnormal_findings,
			:maximum => 65000 )


	if Abstract.respond_to?(:solr_search)

		test "should search" do
			Sunspot.remove_all!					#	isn't always necessary
			Abstract.solr_reindex
			assert Abstract.search.hits.empty?
			FactoryBot.create(:abstract)
			Abstract.solr_reindex
			assert !Abstract.search.hits.empty?
		end

	else
#
#	Sunspot wasn't running when test started
#
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_abstract

end
