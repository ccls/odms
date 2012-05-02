require 'test_helper'

class AbstractsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Abstract',
#		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
#		:actions => [:edit,:update,:show,:destroy,:index],
		:actions => [:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_abstract
	}
	def factory_attributes(options={})
		#	:abstract worked yesterday, but not today???
		#	updates were not updating
		Factory.attributes_for(:complete_abstract,options)	
	end

	assert_access_with_login({ 
		:logins => site_administrators })
	assert_no_access_with_login({ 
		:logins => ( all_test_roles - site_administrators ) })
	assert_no_access_without_login

	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

#	setup :create_case_study_subject
#
#	site_administrators.each do |cu|
#
#		test "should NOT get new without study_subject_id and with #{cu} login" do
#			u = send(cu)
#			login_as u
#			get :new
#			assert_not_nil flash[:error]
#			assert !assigns(:abstract)
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should get new with invalid study_subject_id and #{cu} login" do
#			u = send(cu)
#			login_as u
#			get :new, :study_subject_id => 0
#			assert_not_nil flash[:error]
#			assert !assigns(:abstract)
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should get new with valid study_subject_id and #{cu} login" do
#			u = send(cu)
#			login_as u
#			get :new, :study_subject_id => @study_subject.id
#			assert_nil flash[:error]
#			assert assigns(:abstract)
#			assert_equal assigns(:abstract).study_subject_id, @study_subject.id
#		end
#
#		test "should set entry_1_by_uid on creation with #{cu} login" <<
#				" without abstract hash" do
#			u = send(cu)
#			login_as u
#			post :create, :study_subject_id => @study_subject.id
#			assert assigns(:abstract)
#			assert_equal u.uid, assigns(:abstract).entry_1_by_uid
#		end
#
#		test "should set entry_1_by_uid on creation with #{cu} login" do
#			u = send(cu)
#			login_as u
#			post :create, :study_subject_id => @study_subject.id,
#				:abstract => factory_attributes
##puts assigns(:abstract).histo_report_found
##puts assigns(:abstract).errors.inspect
#			assert assigns(:abstract)
#			assert_equal u.uid, assigns(:abstract).entry_1_by_uid
#		end
#
#		test "should set entry_1_by on creation if study_subject's first abstract " <<
#				"with #{cu} login" do
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',1) {
#				post :create, :study_subject_id => @study_subject.id,
#					:abstract => factory_attributes
#			}
#			assert assigns(:abstract)
#			assert_equal u, assigns(:abstract).entry_1_by
#		end
#
#		test "should set entry_2_by on creation if study_subject's second abstract " <<
#				"with #{cu} login" do
#			u = send(cu)
#			login_as u
#			Factory(:abstract, :study_subject => @study_subject)
#			assert_difference('Abstract.count',1) {
#				post :create, :study_subject_id => @study_subject.id,
#					:abstract => factory_attributes
##puts assigns(:abstract).histo_report_found
##puts assigns(:abstract).errors.inspect
#			}
#			assert assigns(:abstract)
#			assert_equal u, assigns(:abstract).entry_2_by
#		end
#
#		test "should NOT get compare if study_subject only has 0 abstract with #{cu} login" do
#			u = send(cu)
#			login_as u
#			get :compare, :study_subject_id => @study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should NOT get compare if study_subject only has 1 abstract with #{cu} login" do
#			u = send(cu)
#			login_as u
#			Factory(:abstract, :study_subject => @study_subject)
#			get :compare, :study_subject_id => @study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should get compare if study_subject has 2 abstracts with #{cu} login" do
#			u = send(cu)
#			login_as u
#			Factory(:abstract, :study_subject => @study_subject)
#			Factory(:abstract, :study_subject => @study_subject.reload)
#			get :compare, :study_subject_id => @study_subject.id
#			assert assigns(:abstracts)
#		end
#
#		test "should NOT merge if study_subject only has 0 abstract with #{cu} login" do
#			u = send(cu)
#			login_as u
#			post :merge, :study_subject_id => @study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should NOT merge if study_subject only has 1 abstract with #{cu} login" do
#			u = send(cu)
#			login_as u
#			Factory(:abstract, :study_subject => @study_subject)
#			post :merge, :study_subject_id => @study_subject.id
#			assert_redirected_to root_path
#		end
#
#		test "should set merged_by on merge of study_subject's abstracts with #{cu} login" do
#			u1 = send(cu)
#			u2 = send(cu)
#			u3 = send(cu)
#			login_as u3
#			Factory(:abstract, :study_subject => @study_subject,:current_user => u1)
#			Factory(:abstract, :study_subject => @study_subject.reload,:current_user => u2)
#			assert_difference('Abstract.count', -1) {
#				post :merge, :study_subject_id => @study_subject.id
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
#			assert_redirected_to abstract_path(assigns(:abstract))
#		end
#
#		test "should NOT create invalid abstract with #{cu} login" do
#			Abstract.any_instance.stubs(:valid?).returns(false)
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => @study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to abstracts_path
#		end
#
#		test "should NOT create abstract when save fails with #{cu} login" do
#			Abstract.any_instance.stubs(:create_or_update).returns(false)
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => @study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to abstracts_path
#		end
#
#		test "should NOT create merged invalid abstract with #{cu} login" do
#			Factory(:abstract, :study_subject => @study_subject)
#			Factory(:abstract, :study_subject => @study_subject.reload)
#			Abstract.any_instance.stubs(:valid?).returns(false)
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',0) do
#				post :merge, :study_subject_id => @study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'compare'
#		end
#
#		test "should NOT create merged abstract when save fails with #{cu} login" do
#			Factory(:abstract, :study_subject => @study_subject)
#			Factory(:abstract, :study_subject => @study_subject.reload)
#			Abstract.any_instance.stubs(:create_or_update).returns(false)
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',0) do
#				post :merge, :study_subject_id => @study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'compare'
#		end
#
#		test "should require valid study_subject_id on create with #{cu} login" do
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => 0
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should require valid study_subject_id on compare with #{cu} login" do
#			u = send(cu)
#			login_as u
#			get :compare, :study_subject_id => 0
#			assert_not_nil flash[:error]
#			assert_redirected_to study_subjects_path
#		end
#
#		test "should require valid study_subject_id on merge with #{cu} login" do
#			u = send(cu)
#			login_as u
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
#	non_site_administrators.each do |cu|
#
#		test "should NOT create abstract with #{cu} login" do
#			u = send(cu)
#			login_as u
#			assert_difference('Abstract.count',0) do
#				post :create, :study_subject_id => @study_subject.id
#			end
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT compare abstracts with #{cu} login" do
#			u = send(cu)
#			login_as u
#			Factory(:abstract, :study_subject => @study_subject)
#			Factory(:abstract, :study_subject => @study_subject.reload)
#			get :compare, :study_subject_id => @study_subject.id
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT merge abstracts with #{cu} login" do
#			u = send(cu)
#			login_as u
#			Factory(:abstract, :study_subject => @study_subject)
#			Factory(:abstract, :study_subject => @study_subject.reload)
#			post :merge, :study_subject_id => @study_subject.id
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#	end
#
#	test "should NOT create abstract without login" do
#		assert_difference('Abstract.count',0) do
#			post :create, :study_subject_id => @study_subject.id
#		end
#		assert_redirected_to_login
#	end
#
#	test "should NOT compare abstracts without login" do
#		Factory(:abstract, :study_subject => @study_subject)
#		Factory(:abstract, :study_subject => @study_subject.reload)
#		get :compare, :study_subject_id => @study_subject.id
#		assert_redirected_to_login
#	end
#
#	test "should NOT merge abstracts without login" do
#		Factory(:abstract, :study_subject => @study_subject)
#		Factory(:abstract, :study_subject => @study_subject.reload)
#		post :merge, :study_subject_id => @study_subject.id
#		assert_redirected_to_login
#	end
#
#protected
#
#	def create_case_study_subject
#		@study_subject = Factory(:case_study_subject)
#	end

end
