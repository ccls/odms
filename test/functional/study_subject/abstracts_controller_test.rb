require 'test_helper'

class StudySubject::AbstractsControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::AbstractsController

	def factory_attributes(options={})
		FactoryBot.attributes_for(:abstract,{:reviewed_by => 'Testing'}.merge(options))
	end

	site_editors.each do |cu|

		test "should NOT get index without study_subject_id and with #{cu} login" do
			login_as send(cu)
			assert_raises(ActionController::UrlGenerationError){
				get :index
			}
		end

		test "should get index with invalid study_subject_id and #{cu} login" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert !assigns(:abstracts)
			assert_redirected_to study_subjects_path
		end

		test "should get index with valid study_subject_id and #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'index'
			assert_nil flash[:error]
			assert assigns(:abstracts)	#	EMPTY THOUGH
		end

		test "should NOT get index with control study subject and #{cu} login" do
			study_subject = FactoryBot.create(:control_study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'not_case'
			assert_nil flash[:error]
			assert !assigns(:abstracts)
		end

		test "should NOT get index with mother study subject and #{cu} login" do
			study_subject = FactoryBot.create(:mother_study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'not_case'
			assert_nil flash[:error]
			assert !assigns(:abstracts)
		end

		test "should NOT get new without study_subject_id and with #{cu} login" do
			login_as send(cu)
			assert_raises(ActionController::UrlGenerationError){
				get :new
			}
		end

		test "should NOT get new with invalid study_subject_id and #{cu} login" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert !assigns(:abstract)
			assert_redirected_to study_subjects_path
		end

		test "should get new with valid study_subject_id and #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'new'
			assert_nil flash[:error]
			assert assigns(:abstract)
			assert_equal assigns(:abstract).study_subject_id, study_subject.id
		end

		test "should NOT get new with control study subject and #{cu} login" do
			study_subject = FactoryBot.create(:control_study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert !assigns(:abstract)
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT get new with mother study subject and #{cu} login" do
			study_subject = FactoryBot.create(:mother_study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert !assigns(:abstract)
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT create with control study subject and #{cu} login" do
			study_subject = FactoryBot.create(:control_study_subject)
			login_as send(cu)
			assert_difference('Abstract.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:abstract => factory_attributes
			}
			assert !assigns(:abstract)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT create with mother study subject and #{cu} login" do
			study_subject = FactoryBot.create(:mother_study_subject)
			login_as send(cu)
			assert_difference('Abstract.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:abstract => factory_attributes
			}
			assert !assigns(:abstract)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should create valid abstract for case subject with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			assert_difference('Abstract.count',1) do
				post :create, :study_subject_id => study_subject.id
			end
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_abstract_path(study_subject,assigns(:abstract))
		end

		test "should NOT create invalid abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			Abstract.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :create, :study_subject_id => study_subject.id
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template :new
		end

		test "should NOT create abstract when save fails with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			Abstract.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :create, :study_subject_id => study_subject.id
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template :new
		end

		test "should NOT create abstract with invalid study_subject_id and #{cu} login" do
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :create, :study_subject_id => 0
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should set entry_1_by_uid on creation with #{cu} login" <<
				" without abstract hash" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as u = send(cu)
			post :create, :study_subject_id => study_subject.id
			assert assigns(:abstract)
			assert_equal u.uid, assigns(:abstract).entry_1_by_uid
		end

		test "should set entry_1_by_uid on creation with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as u = send(cu)
			post :create, :study_subject_id => study_subject.id,
				:abstract => factory_attributes
			assert assigns(:abstract)
			assert_equal u.uid, assigns(:abstract).entry_1_by_uid
		end

		test "should set entry_1_by on creation if study_subject's first abstract " <<
				"with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as u = send(cu)
			assert_difference('Abstract.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:abstract => factory_attributes
			}
			assert assigns(:abstract)
			assert_equal u, assigns(:abstract).entry_1_by
		end

		test "should set entry_2_by on creation if study_subject's second abstract " <<
				"with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as u = send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			assert_difference('Abstract.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:abstract => factory_attributes
			}
			assert assigns(:abstract)
			assert_equal u, assigns(:abstract).entry_2_by
		end



		test "should show abstract with valid study_subject_id and abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			assert_not_nil abstract.study_subject_id
			login_as send(cu)
			get :show, :study_subject_id => abstract.study_subject_id, :id => abstract.id
			assert_response :success
			assert_template :show
		end

		test "should NOT show abstract with invalid abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :show, :study_subject_id => abstract.study_subject_id, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_abstracts_path(abstract.study_subject_id)
		end

		test "should NOT show abstract with invalid study_subject_id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :show, :study_subject_id => 0, :id => abstract.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should edit abstract with valid study_subject_id and abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			assert_not_nil abstract.study_subject_id
			login_as send(cu)
			get :edit, :study_subject_id => abstract.study_subject_id, :id => abstract.id
			assert_response :success
			assert_template :edit
		end

		test "should NOT edit abstract with valid study_subject_id and invalid abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :edit, :study_subject_id => abstract.study_subject_id, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_abstracts_path(abstract.study_subject_id)
		end

		test "should NOT edit abstract with invalid study_subject_id and valid abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :edit, :study_subject_id => 0, :id => abstract.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update abstract with valid study_subject_id and abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			assert_not_nil abstract.study_subject_id
			login_as send(cu)
			put :update, :study_subject_id => abstract.study_subject_id, :id => abstract.id,
				:abstract => factory_attributes
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_abstract_path(abstract.study_subject_id,abstract)
		end

		test "should NOT update abstract with invalid abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			put :update, :study_subject_id => abstract.study_subject_id, :id => 0,
				:abstract => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_abstracts_path(abstract.study_subject_id)
		end

		test "should NOT update abstract with invalid study_subject_id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			put :update, :study_subject_id => 0, :id => abstract.id,
				:abstract => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update abstract with invalid abstract and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			Abstract.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			put :update, :study_subject_id => abstract.study_subject_id, :id => abstract.id,
				:abstract => factory_attributes
			assert_not_nil flash[:error]
			assert_response :success
			assert_template :edit
		end

		test "should NOT update abstract when save fails and with #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			Abstract.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			put :update, :study_subject_id => abstract.study_subject_id, :id => abstract.id,
				:abstract => factory_attributes
			assert_not_nil flash[:error]
			assert_response :success
			assert_template :edit
		end






		test "should destroy abstract with valid study_subject_id and abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			assert_difference('Abstract.count', -1) {
				delete :destroy, :study_subject_id => abstract.study_subject_id, :id => abstract.id
			}
#			assert_not_nil flash[:notice]
			assert_nil     flash[:error]
			assert_redirected_to study_subject_abstracts_path(abstract.study_subject)
		end

		test "should NOT destroy abstract with valid study_subject_id and invalid abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			assert_difference('Abstract.count', 0) {
				delete :destroy, :study_subject_id => abstract.study_subject_id, :id => 0
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_abstracts_path(abstract.study_subject)
		end

		test "should NOT destroy abstract with invalid study_subject_id and valid abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			assert_difference('Abstract.count', 0) {
				delete :destroy, :study_subject_id => 0, :id => abstract.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end



		test "should NOT get compare if study_subject only has 0 abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			get :compare, :study_subject_id => study_subject.id
			assert_redirected_to root_path
		end

		test "should NOT get compare if study_subject only has 1 abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			get :compare, :study_subject_id => study_subject.id
			assert_redirected_to root_path
		end

		test "should get compare if study_subject has 2 abstracts with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject.reload)
			get :compare, :study_subject_id => study_subject.id
			assert assigns(:abstracts)
		end



		test "should NOT merge if study_subject only has 0 abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			post :merge, :study_subject_id => study_subject.id
			assert_redirected_to root_path
		end

		test "should NOT merge if study_subject only has 1 abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			post :merge, :study_subject_id => study_subject.id
			assert_redirected_to root_path
		end

		test "should set merged_by on merge of study_subject's abstracts with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			u1 = send(cu)
			u2 = send(cu)
			login_as u3 = send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject,
				:current_user_uid => u1.uid)
			FactoryBot.create(:abstract, :study_subject => study_subject.reload,
				:current_user_uid => u2.uid)
			assert_difference('Abstract.count', -1) {
				post :merge, :study_subject_id => study_subject.id,
					:abstract => { :reviewed_by => 'testing' }
			}
			assert assigns(:abstracts)
			assert assigns(:abstract)

#	in rails 2 this would've been the first 2.
#	Now in rails 3 with AREL, the query is executed later
#	so does include the merged, but for some reason also
#	includes the initial which have actually been deleted
#			assigns(:abstracts).each { |a| a.reload }	#	<-- will FAIL
#			assert !assigns(:abstracts).include?(assigns(:abstract))

			assert_equal u1, assigns(:abstract).entry_1_by
			assert_equal u2, assigns(:abstract).entry_2_by
			assert_equal u3, assigns(:abstract).merged_by
			assert_redirected_to study_subject_abstract_path(study_subject,assigns(:abstract))
		end

		test "should NOT create merged invalid abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject.reload)
			Abstract.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :merge, :study_subject_id => study_subject.id
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'compare'
		end

		test "should NOT create merged abstract when save fails with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject.reload)
			Abstract.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :merge, :study_subject_id => study_subject.id
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'compare'
		end

		test "should require valid study_subject_id on compare with #{cu} login" do
			login_as send(cu)
			get :compare, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should require valid study_subject_id on merge with #{cu} login" do
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :merge, :study_subject_id => 0
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end


	non_site_editors.each do |cu|

		test "should NOT get index with #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :index, :study_subject_id => abstract.study_subject_id
			assert_redirected_to root_path
		end

		test "should NOT get new abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_redirected_to root_path
		end

		test "should NOT create abstract with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			assert_difference('Abstract.count',0) do
				post :create, :study_subject_id => study_subject.id
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT show abstract with #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :show, :study_subject_id => abstract.study_subject_id, :id => abstract.id
			assert_redirected_to root_path
		end

		test "should NOT edit abstract with #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			get :edit, :study_subject_id => abstract.study_subject_id, :id => abstract.id
			assert_redirected_to root_path
		end

		test "should NOT update abstract with #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			put :update, :study_subject_id => abstract.study_subject_id, :id => abstract.id,
				:abstract => factory_attributes
			assert_redirected_to root_path
		end

		test "should NOT destroy abstract with valid study_subject_id and abstract id and #{cu} login" do
			abstract = FactoryBot.create(:abstract).reload
			login_as send(cu)
			assert_difference('Abstract.count',0){
				delete :destroy, :study_subject_id => abstract.study_subject_id, :id => abstract.id
			}
			assert_redirected_to root_path
		end

		test "should NOT compare abstracts with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject.reload)
			get :compare, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT merge abstracts with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			FactoryBot.create(:abstract, :study_subject => study_subject)
			FactoryBot.create(:abstract, :study_subject => study_subject.reload)
			post :merge, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get index without login" do
		abstract = FactoryBot.create(:abstract).reload
		get :index, :study_subject_id => abstract.study_subject_id
		assert_redirected_to_login
	end

	test "should NOT get new without login" do
		study_subject = FactoryBot.create(:case_study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create abstract without login" do
		study_subject = FactoryBot.create(:case_study_subject)
		assert_difference('Abstract.count',0) do
			post :create, :study_subject_id => study_subject.id
		end
		assert_redirected_to_login
	end

	test "should NOT show abstract with without login" do
		abstract = FactoryBot.create(:abstract).reload
		get :show, :study_subject_id => abstract.study_subject_id, :id => abstract.id
		assert_redirected_to_login
	end

	test "should NOT edit abstract with without login" do
		abstract = FactoryBot.create(:abstract).reload
		get :edit, :study_subject_id => abstract.study_subject_id, :id => abstract.id
		assert_redirected_to_login
	end

	test "should NOT update abstract with without login" do
		abstract = FactoryBot.create(:abstract).reload
		put :update, :study_subject_id => abstract.study_subject_id, :id => abstract.id,
			:abstract => factory_attributes
		assert_redirected_to_login
	end

	test "should NOT destroy abstract with valid study_subject_id and abstract id without login" do
		abstract = FactoryBot.create(:abstract).reload
		assert_difference('Abstract.count',0){
			delete :destroy, :study_subject_id => abstract.study_subject_id, :id => abstract.id
		}
		assert_redirected_to_login
	end

	test "should NOT compare abstracts without login" do
		study_subject = FactoryBot.create(:case_study_subject)
		FactoryBot.create(:abstract, :study_subject => study_subject)
		FactoryBot.create(:abstract, :study_subject => study_subject.reload)
		get :compare, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT merge abstracts without login" do
		study_subject = FactoryBot.create(:case_study_subject)
		FactoryBot.create(:abstract, :study_subject => study_subject)
		FactoryBot.create(:abstract, :study_subject => study_subject.reload)
		post :merge, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :abstract, 
[:current_user_uid, :bmb_report_found, :bmb_test_date, :bmb_percentage_blasts_known, :bmb_percentage_blasts, :bmb_comments, :bma_report_found, :bma_test_date, :bma_percentage_blasts_known, :bma_percentage_blasts, :bma_comments, :ccs_report_found, :ccs_test_date, :ccs_peroxidase, :ccs_sudan_black, :ccs_periodic_acid_schiff, :ccs_chloroacetate_esterase, :ccs_non_specific_esterase, :ccs_alpha_naphthyl_butyrate_esterase, :ccs_toluidine_blue, :ccs_bcl_2, :ccs_other, :dfc_report_found, :dfc_test_date, :dfc_numerical_data_available, :marker_bmk, :marker_bml, :marker_cd10, :marker_cd11b, :marker_cd11c, :marker_cd13, :marker_cd14, :marker_cd15, :marker_cd16, :marker_cd19, :marker_cd19_cd10, :marker_cd1a, :marker_cd2, :marker_cd20, :marker_cd21, :marker_cd22, :marker_cd23, :marker_cd24, :marker_cd25, :marker_cd3, :marker_cd33, :marker_cd34, :marker_cd38, :marker_cd3_cd4, :marker_cd3_cd8, :marker_cd4, :marker_cd40, :marker_cd41, :marker_cd45, :marker_cd5, :marker_cd56, :marker_cd57, :marker_cd61, :marker_cd7, :marker_cd71, :marker_cd8, :marker_cd9, :marker_cdw65, :marker_glycophorin_a, :marker_hla_dr, :marker_igm, :marker_sig, :marker_tdt, :other_markers, :marker_comments, :tdt_report_found, :tdt_test_date, :tdt_found_where, :tdt_result, :tdt_numerical_result, :ploidy_report_found, :ploidy_test_date, :ploidy_found_where, :ploidy_hypodiploid, :ploidy_pseudodiploid, :ploidy_hyperdiploid, :ploidy_diploid, :ploidy_dna_index, :ploidy_other_dna_measurement, :ploidy_notes, :hla_report_found, :hla_test_date, :hla_results, :cgs_report_found, :cgs_test_date, :cgs_normal, :cgs_conventional_karyotype_done, :cgs_hospital_fish_done, :cgs_hyperdiploidy_detected, :cgs_hyperdiploidy_by, :cgs_hyperdiploidy_number_of_chromosomes, :cgs_t12_21, :cgs_inv16, :cgs_t1_19, :cgs_t8_21, :cgs_t9_22, :cgs_t15_17, :cgs_trisomy_4, :cgs_trisomy_5, :cgs_trisomy_10, :cgs_trisomy_17, :cgs_trisomy_21, :cgs_t4_11_q21_q23, :cgs_deletion_6q, :cgs_deletion_9p, :cgs_t16_16_p13_q22, :cgs_trisomy_8, :cgs_trisomy_x, :cgs_trisomy_6, :cgs_trisomy_14, :cgs_trisomy_18, :cgs_monosomy_7, :cgs_deletion_16_q22, :cgs_others, :cgs_conventional_karyotyping_results, :cgs_hospital_fish_results, :cgs_comments, :omg_abnormalities_found, :omg_test_date, :omg_p16, :omg_p15, :omg_p53, :omg_ras, :omg_all1, :omg_wt1, :omg_bcr, :omg_etv6, :omg_fish, :em_report_found, :em_test_date, :em_comments, :cbc_report_found, :cbc_test_date, :cbc_hemoglobin, :cbc_leukocyte_count, :cbc_number_of_blasts, :cbc_percentage_blasts, :cbc_platelet_count, :csf_report_found, :csf_test_date, :csf_blasts_present, :csf_cytology, :csf_number_of_blasts, :csf_pb_contamination, :csf_rbc, :csf_wbc, :ob_skin_report_found, :ob_skin_date, :ob_skin_leukemic_cells_present, :ob_lymph_node_report_found, :ob_lymph_node_date, :ob_lymph_node_leukemic_cells_present, :ob_liver_report_found, :ob_liver_date, :ob_liver_leukemic_cells_present, :ob_other_report_found, :ob_other_date, :ob_other_site_organ, :ob_other_leukemic_cells_present, :cxr_report_found, :cxr_test_date, :cxr_result, :cxr_mediastinal_mass_description, :cct_report_found, :cct_test_date, :cct_result, :cct_mediastinal_mass_description, :as_report_found, :as_test_date, :as_normal, :as_sphenomegaly, :as_hepatomegaly, :as_lymphadenopathy, :as_other_abdominal_masses, :as_ascities, :as_other_abnormal_findings, :ts_report_found, :ts_test_date, :ts_findings, :hpr_report_found, :hpr_test_date, :hpr_hepatomegaly, :hpr_splenomegaly, :hpr_down_syndrome_phenotype, :height, :height_units, :weight, :weight_units, :ds_report_found, :ds_test_date, :ds_clinical_diagnosis, :cp_report_found, :cp_induction_protocol_used, :cp_induction_protocol_name_and_number, :cp_therapeutic_agents, :bma07_report_found, :bma07_test_date, :bma07_classification, :bma07_inconclusive_results, :bma07_percentage_of_blasts, :bma14_report_found, :bma14_test_date, :bma14_classification, :bma14_inconclusive_results, :bma14_percentage_of_blasts, :bma28_report_found, :bma28_test_date, :bma28_classification, :bma28_inconclusive_results, :bma28_percentage_of_blasts, :clinical_remission, :leukemia_class, :other_all_leukemia_class, :other_aml_leukemia_class, :icdo_classification_number, :icdo_classification_description, :leukemia_lineage, :pe_report_found, :pe_test_date, :pe_gingival_infiltrates, :pe_leukemic_skin_infiltrates, :pe_lymphadenopathy, :pe_lymphadenopathy_description, :pe_splenomegaly, :pe_splenomegaly_size, :pe_hepatomegaly, :pe_hepatomegaly_size, :pe_testicular_mass, :pe_other_soft_tissue, :pe_other_soft_tissue_location, :pe_other_soft_tissue_size, :pe_neurological_abnormalities, :pe_other_abnormal_findings, :abstracted_by, :abstracted_on, :reviewed_by, :reviewed_on],
[:entry_1_by_uid, :entry_2_by_uid, :merged_by_uid, :study_subject_id])

end
