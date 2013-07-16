require 'test_helper'

class AbstractTest < ActiveSupport::TestCase

	assert_should_initially_belong_to :study_subject

#	assert_should_protect( :study_subject_id, :study_subject, :entry_1_by_uid, 
#		:entry_2_by_uid, :merged_by_uid )
#
#	assert_should_not_require( Abstract.db_fields )
#	assert_should_not_require_unique( Abstract.db_fields )
#	assert_should_not_protect( Abstract.db_fields )
##	assert_should_not_require( Abstract.comparable_attribute_names )
##	assert_should_not_require_unique( Abstract.comparable_attribute_names )
##	assert_should_not_protect( Abstract.comparable_attribute_names )

	test "explicit Factory abstract test" do
		assert_difference('Abstract.count',1) {
			@abstract = FactoryGirl.create(:abstract)
		}
##		( not_nil = %w( id created_at updated_at cbc_percent_blasts_unknown ) ).each do |c|
#		( not_nil = %w( id created_at updated_at cbc_percent_blasts_unknown study_subject_id entry_1_by_uid entry_2_by_uid ) ).each do |c|
#			assert_not_nil @abstract.send(c), "#{c} is nil"
#		end
#		( Abstract.column_names - not_nil ).each do |c|
#			assert_nil @abstract.send(c), "#{c} is not nil"
#		end
	end

#	test "explicit Factory complete_abstract test" do
#		assert_difference('Abstract.count',1) {
#			#	this factory randomly sets values, some of which can be nil
#			FactoryGirl.create(:complete_abstract)
#		}
#	end
#
#	test "should not convert weight if weight_units is null" do
#		abstract = FactoryGirl.create(:abstract,:weight_at_diagnosis => 100)
#		assert_equal 100, abstract.reload.weight_at_diagnosis
#	end
#
#	test "should not convert weight if weight_units is kg" do
#		abstract = FactoryGirl.create(:abstract,:weight_at_diagnosis => 100, :weight_units => 'kg')
#		assert_equal 100, abstract.reload.weight_at_diagnosis
#	end
#
#	test "should convert weight to kg if weight_units is lb" do
#		abstract = FactoryGirl.create(:abstract,:weight_at_diagnosis => 100, :weight_units => 'lb')
#		abstract.reload
#		assert_nil       abstract.weight_units
#		assert_not_equal 100,   abstract.weight_at_diagnosis
#		assert_in_delta   45.3, abstract.weight_at_diagnosis, 0.1
#	end
#
#	test "should not convert height if height_units is null" do
#		abstract = FactoryGirl.create(:abstract,:height_at_diagnosis => 100)
#		assert_equal 100, abstract.reload.height_at_diagnosis
#	end
#
#	test "should not convert height if height_units is cm" do
#		abstract = FactoryGirl.create(:abstract,:height_at_diagnosis => 100, :height_units => 'cm')
#		assert_equal 100, abstract.reload.height_at_diagnosis
#	end
#
#	test "should convert height to cm if height_units is in" do
#		abstract = FactoryGirl.create(:abstract,:height_at_diagnosis => 100, :height_units => 'in')
#		abstract.reload
#		assert_nil       abstract.height_units
#		assert_not_equal 100, abstract.height_at_diagnosis
#		assert_in_delta  254, abstract.height_at_diagnosis, 0.1
#	end
#
##	test "should return an array of ignorable columns" do
##		abstract = FactoryGirl.create(:abstract)
##		assert_equal abstract.ignorable_columns,
##			["id", "entry_1_by_uid", "entry_2_by_uid", "merged_by_uid", 
##				"created_at", "updated_at", "study_subject_id"]
##	end
##
##	test "should return hash of comparable attributes" do
##		abstract = FactoryGirl.create(:abstract)
##		assert abstract.comparable_attributes.is_a?(Hash)
##	end
#
#	test "should return true if abstracts are the same" do
#		abstract1 = FactoryGirl.create(:abstract)
#		abstract2 = FactoryGirl.create(:abstract)
#		assert abstract1.is_the_same_as?(abstract2)
#	end
#
#	test "should return false if abstracts are not the same" do
#		abstract1 = FactoryGirl.create(:abstract)
#		abstract2 = FactoryGirl.create(:abstract, :height_at_diagnosis => 100 )
#		assert !abstract1.is_the_same_as?(abstract2)
#	end
#
#	test "should return empty hash if abstracts are the same" do
#		abstract1 = FactoryGirl.create(:abstract)
#		abstract2 = FactoryGirl.create(:abstract)
#		assert_equal Hash.new, abstract1.diff(abstract2)
#		assert       abstract1.diff(abstract2).empty?
#	end
#
#	test "should return hash if abstracts are not the same" do
#		abstract1 = FactoryGirl.create(:abstract)
#		abstract2 = FactoryGirl.create(:abstract, :height_at_diagnosis => 100 )
#		assert !abstract1.diff(abstract2).empty?
#		assert  abstract1.diff(abstract2).has_key?('height_at_diagnosis')
#	end
#
#	test "should NOT set days since diagnosis fields on create without diagnosed_on" do
#		abstract = FactoryGirl.create(:abstract)
#		assert_nil abstract.diagnosed_on
#		assert_nil abstract.response_day_7_days_since_diagnosis
#		assert_nil abstract.response_day_14_days_since_diagnosis
#		assert_nil abstract.response_day_28_days_since_diagnosis
#	end
#
#	test "should NOT set days since diagnosis fields on create without response_report_on" do
#		abstract = FactoryGirl.create(:abstract,
#			:diagnosed_on              => ( Date.current - 10.days ),
#			:response_report_on_day_7  => nil,
#			:response_report_on_day_14 => nil,
#			:response_report_on_day_28 => nil
#		)
#		assert_not_nil abstract.diagnosed_on
#		assert_nil abstract.response_day_7_days_since_diagnosis
#		assert_nil abstract.response_day_14_days_since_diagnosis
#		assert_nil abstract.response_day_28_days_since_diagnosis
#	end
#
#	test "should set days since diagnosis fields on create with diagnosed_on" do
#		today = Date.current
#		abstract = FactoryGirl.create(:abstract,
#			:diagnosed_on              => ( today - 40.days ),
#			:response_report_on_day_7  => ( today - 30.days ),
#			:response_report_on_day_14 => ( today - 20.days ),
#			:response_report_on_day_28 => ( today - 10.days )
#		)
#		assert_not_nil abstract.diagnosed_on
#		assert_not_nil abstract.response_day_7_days_since_diagnosis
#		assert_equal 10, abstract.response_day_7_days_since_diagnosis
#		assert_not_nil abstract.response_day_14_days_since_diagnosis
#		assert_equal 20, abstract.response_day_14_days_since_diagnosis
#		assert_not_nil abstract.response_day_28_days_since_diagnosis
#		assert_equal 30, abstract.response_day_28_days_since_diagnosis
#	end
#
#	test "should NOT set days since treatment_began fields on create" <<
#			" without treatment_began_on" do
#		abstract = FactoryGirl.create(:abstract)
#		assert_nil abstract.treatment_began_on
#		assert_nil abstract.response_day_7_days_since_treatment_began
#		assert_nil abstract.response_day_14_days_since_treatment_began
#		assert_nil abstract.response_day_28_days_since_treatment_began
#	end
#
#	test "should NOT set days since treatment_began fields on create" <<
#			" without response_report_on" do
#		abstract = FactoryGirl.create(:abstract,
#			:treatment_began_on        => ( Date.current - 10.days ),
#			:response_report_on_day_7  => nil,
#			:response_report_on_day_14 => nil,
#			:response_report_on_day_28 => nil
#		)
#		assert_not_nil abstract.treatment_began_on
#		assert_nil abstract.response_day_7_days_since_treatment_began
#		assert_nil abstract.response_day_14_days_since_treatment_began
#		assert_nil abstract.response_day_28_days_since_treatment_began
#	end
#
#	test "should set days since treatment_began fields on create" <<
#			" with treatment_began_on" do
#		today = Date.current
#		abstract = FactoryGirl.create(:abstract,
#			:treatment_began_on        => ( today - 40.days ),
#			:response_report_on_day_7  => ( today - 30.days ),
#			:response_report_on_day_14 => ( today - 20.days ),
#			:response_report_on_day_28 => ( today - 10.days )
#		)
#		assert_not_nil abstract.treatment_began_on
#		assert_not_nil abstract.response_day_7_days_since_treatment_began
#		assert_equal 10, abstract.response_day_7_days_since_treatment_began
#		assert_not_nil abstract.response_day_14_days_since_treatment_began
#		assert_equal 20, abstract.response_day_14_days_since_treatment_began
#		assert_not_nil abstract.response_day_28_days_since_treatment_began
#		assert_equal 30, abstract.response_day_28_days_since_treatment_began
#	end
#
#	test "should save a User as entry_1_by" do
#		assert_difference('User.count',1) {
#		assert_difference('Abstract.count',1) {
#			abstract = FactoryGirl.create(:abstract,:entry_1_by => FactoryGirl.create(:user))
#			assert abstract.entry_1_by.is_a?(User)	#	will fail if using sqlite database
#		} }
#	end
#
#	test "should save a User as entry_2_by" do
#		assert_difference('User.count',1) {
#		assert_difference('Abstract.count',1) {
#			abstract = FactoryGirl.create(:abstract,:entry_2_by => FactoryGirl.create(:user))
#			assert abstract.entry_2_by.is_a?(User)	#	will fail if using sqlite database
#		} }
#	end
#
#	test "should save a User as merged_by" do
#		assert_difference('User.count',1) {
#		assert_difference('Abstract.count',1) {
#			abstract = FactoryGirl.create(:abstract,:merged_by => FactoryGirl.create(:user))
#			assert_not_nil abstract.merged_by_uid
#			assert abstract.merged_by.is_a?(User)
#			assert abstract.merged?
#		} }
#	end
#
#	test "should create first abstract for study_subject with current_user" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		current_user = FactoryGirl.create(:user)
#		assert_difference('Abstract.count',1) {
#			abstract = FactoryGirl.create(:abstract,:current_user => current_user,
#				:study_subject => study_subject)
#			assert_equal abstract.entry_1_by, current_user
#			assert_equal abstract.entry_2_by, current_user
#			assert_equal abstract.study_subject, study_subject
#		}
#	end
#
#	test "should create second abstract for study_subject with current_user" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		current_user = FactoryGirl.create(:user)
#		FactoryGirl.create(:abstract,:current_user => current_user,
#			:study_subject => study_subject)
#		assert_difference('Abstract.count',1) {
#			abstract = FactoryGirl.create(:abstract,:current_user => current_user,
#				:study_subject => study_subject)
#			assert_equal abstract.entry_1_by, current_user
#			assert_equal abstract.entry_2_by, current_user
#			assert_equal abstract.study_subject, study_subject
#		}
#	end
#
#	test "should NOT create third abstract for study_subject with current_user " <<
#			"without merging flag" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		current_user = FactoryGirl.create(:user)
#		FactoryGirl.create(:abstract,:current_user => current_user,
#			:study_subject => study_subject)
#		FactoryGirl.create(:abstract,:current_user => current_user,
#			:study_subject => study_subject)
#		assert_difference('Abstract.count',0) {
#			#	study_subject.reload is needed here
#			abstract = create_abstract(:current_user => current_user,
#				:study_subject => study_subject.reload)
#			assert abstract.errors.include?(:study_subject_id)
#		}
#	end
#
#	test "should create third abstract for study_subject with current_user " <<
#			"with merging flag" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		current_user = FactoryGirl.create(:user)
#		FactoryGirl.create(:abstract,:current_user => current_user,
#			:study_subject => study_subject)
#		FactoryGirl.create(:abstract,:current_user => current_user,
#			:study_subject => study_subject)	#.reload)
#		#	yes, -1 , because when creating the merged, the other 2 go away
#		assert_difference('Abstract.count',-1) {
#			#	study_subject.reload is needed here
#			abstract = FactoryGirl.create(:abstract,:current_user => current_user,
#				:study_subject => study_subject.reload, :merging => true)
#			assert_equal abstract.merged_by, current_user
#			assert_equal abstract.study_subject, study_subject
#			assert_not_nil abstract.merged_by_uid
#			assert abstract.merged?
#		}
#		assert_equal 1, study_subject.abstracts.count
#		study_subject.reload	#	NEEDED
#		assert study_subject.abstracts.first.merged?
#	end
#
#	test "should NOT create merged abstract if study_subject already has one" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		a1 = FactoryGirl.create(:abstract,:study_subject => study_subject)
#		a1.merged_by = FactoryGirl.create(:user)
#		a1.save
#		assert_not_nil study_subject.abstracts.merged
#		assert !study_subject.abstracts.merged.empty?
#		assert_not_nil a1.merged_by
#		assert a1.merged?
#		assert_difference('Abstract.count',0) {
#			a2 = create_abstract( :study_subject => study_subject, :merging => true)
#			assert a2.errors.include?(:study_subject_id)
#		}
#	end
#
#	test "should return abstract sections for class" do
#		sections = Abstract.sections
#		assert  Abstract.class_variable_defined?("@@sections")
#		assert sections.is_a?(Array)
#		assert sections.length >= 15
#		assert sections.first.is_a?(Hash)
#	end
#
##	test "should return abstract fields for class" do
##		fields = Abstract.fields
##		assert  Abstract.class_variable_defined?("@@fields")
##		assert fields.is_a?(Array)
##		assert fields.length >= 15
##		assert fields.first.is_a?(Hash)
##	end
##
##	test "should return abstract fields for instance" do
##		fields = Abstract.new.fields
##		assert  Abstract.class_variable_defined?("@@fields")
##		assert fields.is_a?(Array)
##		assert fields.length >= 15
##		assert fields.first.is_a?(Hash)
##	end
#
#	test "should return abstract db_fields for class" do
#		db_fields = Abstract.db_fields
##		assert  Abstract.class_variable_defined?("@@fields")
#		assert db_fields.is_a?(Array)
#		assert db_fields.length >= 15
#		assert db_fields.first.is_a?(String)
#	end
#
#	test "should return abstract db_fields for instance" do
#		db_fields = Abstract.new.db_fields
##		assert  Abstract.class_variable_defined?("@@fields")
#		assert db_fields.is_a?(Array)
#		assert db_fields.length >= 15
#		assert db_fields.first.is_a?(String)
#	end

	assert_should_accept_only_good_values( 
		:bmb_report_found,
		:bmb_percentage_blasts_known,
		:bma_report_found,
		:bma_percentage_blasts_known,
		:dfc_report_found,
		:dfc_numerical_data_available,
		:tdt_report_found,
		:ploidy_report_found,
		:hla_report_found,
		:cs_report_found,
		:cs_conventional_karyotype_done,
		:cs_hospital_fish_done,
		:cs_hyperdiploidy_detected,
		:translocation_t12_21,
		:translocation_inv16,
		:translocation_t1_19,
		:translocation_t8_21,
		:translocation_t9_22,
		:translocation_t15_17,
		:trisomy_4,
		:trisomy_5,
		:trisomy_10,
		:trisomy_17,
		:trisomy_21,
		:cbc_report_found,
		:csf_report_found,
		:csf_blasts_present,
		:csf_pb_contamination,
		:cxr_report_found,
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
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_require_length( 
		:bmb_percentage_blasts,
		:bma_percentage_blasts,
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
		:cs_hyperdiploidy_by,
		:cs_hyperdiploidy_number_of_chromosomes,
		:cbc_hemoglobin,
		:cbc_leukocyte_count,
		:cbc_number_of_blasts,
		:cbc_percentage_blasts,
		:cbc_platelet_count,
		:csf_number_of_blasts,
		:csf_rbc,
		:csf_wbc,
		:cxr_result,
		:height_in_cm,
		:height_in_in,
		:weight_in_kg,
		:weight_in_lb	,
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
		:bmb_comments,
		:bma_comments,
		:other_markers,
		:marker_comments,
		:hla_results,
		:cs_conventional_karyotyping_results,
		:cs_hospital_fish_results,
		:csf_cytology,
		:cxr_mediastinal_mass_description,
		:ds_clinical_diagnosis,
		:cp_therapeutic_agents,
		:icdo_classification_description,
		:ploidy_other_dna_measurement,
		:ploidy_notes,
		:cs_comments,
			:maximum => 65000 )


protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_abstract

end
