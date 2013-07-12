require 'test_helper'

class StudySubject::AbstractsControllerTest < ActionController::TestCase
#
##
##	TODO add edit and update tests and actions eventually
##
#
#	site_editors.each do |cu|
#
#
#		test "should show abstract with valid study_subject_id and abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			assert_not_nil abstract.study_subject_id
#			login_as send(cu)
#			get :show, :study_subject_id => abstract.study_subject_id, :id => abstract.id
#			assert_response :success
#			assert_nil flash[:error]
#		end
#
#		test "should NOT show abstract with valid study_subject_id and invalid abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			get :show, :study_subject_id => abstract.study_subject_id, :id => 0
#			assert_not_nil flash[:error]
#			assert_redirected_to abstracts_path
#		end
#
#		test "should NOT show abstract with invalid study_subject_id and valid abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			get :show, :study_subject_id => 0, :id => abstract.id
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should destroy abstract with valid study_subject_id and abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			assert_difference('Abstract.count', -1) {
#				delete :destroy, :study_subject_id => abstract.study_subject_id, :id => abstract.id
#			}
##			assert_not_nil flash[:notice]
#			assert_nil     flash[:error]
#			assert_redirected_to study_subject_abstracts_path(abstract.study_subject)
#		end
#
#		test "should NOT destroy abstract with valid study_subject_id and invalid abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			assert_difference('Abstract.count', 0) {
#				delete :destroy, :study_subject_id => abstract.study_subject_id, :id => 0
#			}
#			assert_not_nil flash[:error]
#			assert_redirected_to abstracts_path
#		end
#
#		test "should NOT destroy abstract with invalid study_subject_id and valid abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			assert_difference('Abstract.count', 0) {
#				delete :destroy, :study_subject_id => 0, :id => abstract.id
#			}
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#
#		test "should NOT get index without study_subject_id and with #{cu} login" do
#			login_as send(cu)
#assert_raises(ActionController::RoutingError){
#			get :index
#}
##			assert_not_nil flash[:error]
##			assert !assigns(:abstracts)
##			assert_redirected_to study_subjects_path
#		end
#
#		test "should get index with invalid study_subject_id and #{cu} login" do
#			login_as send(cu)
#			get :index, :study_subject_id => 0
#			assert_not_nil flash[:error]
#			assert !assigns(:abstracts)
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should get index with valid study_subject_id and #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			get :index, :study_subject_id => study_subject.id
#			assert_response :success
#			assert_template 'index'
#			assert_nil flash[:error]
#			assert assigns(:abstracts)	#	EMPTY THOUGH
#		end
#
#		test "should NOT get index with control study subject and #{cu} login" do
#			study_subject = FactoryGirl.create(:control_study_subject)
#			login_as send(cu)
#			get :index, :study_subject_id => study_subject.id
#			assert_response :success
#			assert_template 'not_case'
#			assert_nil flash[:error]
#			assert !assigns(:abstracts)
#		end
#
#		test "should NOT get index with mother study subject and #{cu} login" do
#			study_subject = FactoryGirl.create(:mother_study_subject)
#			login_as send(cu)
#			get :index, :study_subject_id => study_subject.id
#			assert_response :success
#			assert_template 'not_case'
#			assert_nil flash[:error]
#			assert !assigns(:abstracts)
#		end
#
#		test "should NOT get new without study_subject_id and with #{cu} login" do
#			login_as send(cu)
#assert_raises(ActionController::RoutingError){
#			get :new
#}
##			assert_not_nil flash[:error]
##			assert !assigns(:abstract)
##			assert_redirected_to study_subjects_path
#		end
#
#		test "should NOT get new with invalid study_subject_id and #{cu} login" do
#			login_as send(cu)
#			get :new, :study_subject_id => 0
#			assert_not_nil flash[:error]
#			assert !assigns(:abstract)
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should get new with valid study_subject_id and #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			get :new, :study_subject_id => study_subject.id
#			assert_response :success
#			assert_template 'new'
#			assert_nil flash[:error]
#			assert assigns(:abstract)
#			assert_equal assigns(:abstract).study_subject_id, study_subject.id
#		end
#
#		test "should NOT get new with control study subject and #{cu} login" do
#			study_subject = FactoryGirl.create(:control_study_subject)
#			login_as send(cu)
#			get :new, :study_subject_id => study_subject.id
#			assert_not_nil flash[:error]
#			assert !assigns(:abstract)
#			assert_redirected_to study_subject_path(study_subject)
#		end
#
#		test "should NOT get new with mother study subject and #{cu} login" do
#			study_subject = FactoryGirl.create(:mother_study_subject)
#			login_as send(cu)
#			get :new, :study_subject_id => study_subject.id
#			assert_not_nil flash[:error]
#			assert !assigns(:abstract)
#			assert_redirected_to study_subject_path(study_subject)
#		end
#
#		test "should set entry_1_by_uid on creation with #{cu} login" <<
#				" without abstract hash" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as u = send(cu)
#			post :create, :study_subject_id => study_subject.id
#			assert assigns(:abstract)
#			assert_equal u.uid, assigns(:abstract).entry_1_by_uid
#		end
#
#		test "should set entry_1_by_uid on creation with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as u = send(cu)
#			post :create, :study_subject_id => study_subject.id,
#				:abstract => factory_attributes
#			assert assigns(:abstract)
#			assert_equal u.uid, assigns(:abstract).entry_1_by_uid
#		end
#
#		test "should set entry_1_by on creation if study_subject's first abstract " <<
#				"with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as u = send(cu)
#			assert_difference('Abstract.count',1) {
#				post :create, :study_subject_id => study_subject.id,
#					:abstract => factory_attributes
#			}
#			assert assigns(:abstract)
#			assert_equal u, assigns(:abstract).entry_1_by
#		end
#
#		test "should set entry_2_by on creation if study_subject's second abstract " <<
#				"with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as u = send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			assert_difference('Abstract.count',1) {
#				post :create, :study_subject_id => study_subject.id,
#					:abstract => factory_attributes
#			}
#			assert assigns(:abstract)
#			assert_equal u, assigns(:abstract).entry_2_by
#		end
#
#		test "should NOT create with control study subject and #{cu} login" do
#			study_subject = FactoryGirl.create(:control_study_subject)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) {
#				post :create, :study_subject_id => study_subject.id,
#					:abstract => factory_attributes
#			}
#			assert !assigns(:abstract)
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subject_path(study_subject)
#		end
#
#		test "should NOT create with mother study subject and #{cu} login" do
#			study_subject = FactoryGirl.create(:mother_study_subject)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) {
#				post :create, :study_subject_id => study_subject.id,
#					:abstract => factory_attributes
#			}
#			assert !assigns(:abstract)
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subject_path(study_subject)
#		end
#
#		test "should NOT get compare if study_subject only has 0 abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			get :compare, :study_subject_id => study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should NOT get compare if study_subject only has 1 abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			get :compare, :study_subject_id => study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should get compare if study_subject has 2 abstracts with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#			get :compare, :study_subject_id => study_subject.id
#			assert assigns(:abstracts)
#		end
#
#		test "should NOT merge if study_subject only has 0 abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			post :merge, :study_subject_id => study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should NOT merge if study_subject only has 1 abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			post :merge, :study_subject_id => study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should set merged_by on merge of study_subject's abstracts with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			u1 = send(cu)
#			u2 = send(cu)
#			login_as u3 = send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject,:current_user => u1)
#			FactoryGirl.create(:abstract, :study_subject => study_subject.reload,:current_user => u2)
#			assert_difference('Abstract.count', -1) {
#				post :merge, :study_subject_id => study_subject.id
#			}
#			assert assigns(:abstracts)
#			assert assigns(:abstract)
#
##	in rails 2 this would've been the first 2.
##	Now in rails 3 with AREL, the query is executed later
##	so does include the merged, but for some reason also
##	includes the initial which have actually been deleted
##			assigns(:abstracts).each { |a| a.reload }	#	<-- will FAIL
##			assert !assigns(:abstracts).include?(assigns(:abstract))
#
#			assert_equal u1, assigns(:abstract).entry_1_by
#			assert_equal u2, assigns(:abstract).entry_2_by
#			assert_equal u3, assigns(:abstract).merged_by
##			assert_redirected_to abstract_path(assigns(:abstract))
#			assert_redirected_to study_subject_abstract_path(study_subject,assigns(:abstract))
#		end
#
#		test "should NOT create invalid abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			Abstract.any_instance.stubs(:valid?).returns(false)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subject_abstracts_path(study_subject)
#		end
#
#		test "should NOT create abstract when save fails with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			Abstract.any_instance.stubs(:create_or_update).returns(false)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subject_abstracts_path(study_subject)
#		end
#
#		test "should NOT create merged invalid abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#			Abstract.any_instance.stubs(:valid?).returns(false)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :merge, :study_subject_id => study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'compare'
#		end
#
#		test "should NOT create merged abstract when save fails with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#			Abstract.any_instance.stubs(:create_or_update).returns(false)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :merge, :study_subject_id => study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'compare'
#		end
#
#		test "should require valid study_subject_id on create with #{cu} login" do
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => 0
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should require valid study_subject_id on compare with #{cu} login" do
#			login_as send(cu)
#			get :compare, :study_subject_id => 0
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should require valid study_subject_id on merge with #{cu} login" do
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :merge, :study_subject_id => 0
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#	end
#
#
#	non_site_editors.each do |cu|
#
#		test "should NOT get abstract index with valid study_subject_id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			get :index, :study_subject_id => abstract.study_subject_id
#			assert_redirected_to root_path
#		end
#
#		test "should NOT show abstract with valid study_subject_id and abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			get :show, :study_subject_id => abstract.study_subject_id, :id => abstract.id
#			assert_redirected_to root_path
#		end
#
#		test "should NOT destroy abstract with valid study_subject_id and abstract id and #{cu} login" do
#			abstract = FactoryGirl.create(:abstract).reload
#			login_as send(cu)
#			assert_difference('Abstract.count',0){
#				delete :destroy, :study_subject_id => abstract.study_subject_id, :id => abstract.id
#			}
#			assert_redirected_to root_path
#		end
#
#		test "should NOT create abstract with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT compare abstracts with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#			get :compare, :study_subject_id => study_subject.id
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT merge abstracts with #{cu} login" do
#			study_subject = FactoryGirl.create(:case_study_subject)
#			login_as send(cu)
#			FactoryGirl.create(:abstract, :study_subject => study_subject)
#			FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#			post :merge, :study_subject_id => study_subject.id
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#	end
#
#	test "should NOT get abstract index with valid study_subject_id without login" do
#		abstract = FactoryGirl.create(:abstract).reload
#		get :index, :study_subject_id => abstract.study_subject_id
#		assert_redirected_to_login
#	end
#
#	test "should NOT show abstract with valid study_subject_id and abstract id without login" do
#		abstract = FactoryGirl.create(:abstract).reload
#		get :show, :study_subject_id => abstract.study_subject_id, :id => abstract.id
#		assert_redirected_to_login
#	end
#
#	test "should NOT destroy abstract with valid study_subject_id and abstract id without login" do
#		abstract = FactoryGirl.create(:abstract).reload
#		assert_difference('Abstract.count',0){
#			delete :destroy, :study_subject_id => abstract.study_subject_id, :id => abstract.id
#		}
#		assert_redirected_to_login
#	end
#
#	test "should NOT create abstract without login" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		assert_difference('Abstract.count',0) do
#			post :create, :study_subject_id => study_subject.id
#		end
#		assert_redirected_to_login
#	end
#
#	test "should NOT compare abstracts without login" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		FactoryGirl.create(:abstract, :study_subject => study_subject)
#		FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#		get :compare, :study_subject_id => study_subject.id
#		assert_redirected_to_login
#	end
#
#	test "should NOT merge abstracts without login" do
#		study_subject = FactoryGirl.create(:case_study_subject)
#		FactoryGirl.create(:abstract, :study_subject => study_subject)
#		FactoryGirl.create(:abstract, :study_subject => study_subject.reload)
#		post :merge, :study_subject_id => study_subject.id
#		assert_redirected_to_login
#	end
#
end
