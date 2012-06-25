require 'test_helper'

class ReceiveSamplesControllerTest < ActionController::TestCase

#	I don't think that any of the auto tests will work.
#	Well, 'new' might, but there are a lot of other
#	variables to test.

#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Sample',
#		:actions => [:new,:create],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_sample
#	}
	def factory_attributes(options={})
#			:sample_source
#			:storage_temperature
#			:collected_at
#			:shipped_at
#			:received_by_ccls_at
		#	Being more explicit to reflect what is actually on the form
		{
			:project_id     => Project['ccls'].id,
			:sample_type_id => Factory(:sample_type).id
		}.merge(options)
	end

#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login

#	assert_no_route(:get,:index)
#	assert_no_route(:get, :show)
#	assert_no_route(:get, :edit)
#	assert_no_route(:put, :update)
#	assert_no_route(:delete, :destroy)

	site_editors.each do |cu|

		test "should get new receive sample with #{cu} login" do
			login_as send(cu)
			get :new
			assert_new_success
			assert !assigns(:study_subjects)
		end

		test "should get new receive sample with #{cu} login" <<
				" and blank q" do
			login_as send(cu)
			get :new, :q => ''
#			assert_no_study_subjects_found
			assert_new_success
		end

#		test "should get new receive sample with #{cu} login" <<
#				" and blank studyid" do
#			login_as send(cu)
#			get :new, :studyid => ''
#			assert_no_study_subjects_found
#		end
#
#		test "should get new receive sample with #{cu} login" <<
#				" and blank icf_master_id" do
#			login_as send(cu)
#			get :new, :icf_master_id => ''
#			assert_no_study_subjects_found
#		end
#
#		test "should get new receive sample with #{cu} login" <<
#				" and blank studyid and icf_master_id" do
#			login_as send(cu)
#			get :new, :studyid => '', :icf_master_id => ''
#			assert_no_study_subjects_found
#		end

		test "should get new receive sample with #{cu} login" <<
				" and nonexistant studyid" do
			login_as send(cu)
			get :new, :q => '1234-A-5'
			assert_no_study_subjects_found
		end

		test "should get new receive sample with #{cu} login" <<
				" and nonexistant icf_master_id" do
			login_as send(cu)
			get :new, :q => '123456789'
			assert_no_study_subjects_found
		end

#		test "should get new receive sample with #{cu} login" <<
#				" and nonexistant studyid and nonexistant icf_master_id" do
#			login_as send(cu)
#			get :new, :studyid => '1234-A-5', :icf_master_id => '123456789'
#			assert_no_study_subjects_found
#		end

		test "should get new receive sample with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_no_study_subjects_found
		end

#	MULTIPLE STUDY SUBJECTS FOUND
#
#		test "should get new receive sample with #{cu} login" <<
#				" and studyid and icf_master_id of multiple child case subjects" do
#			s1 = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
#			assert_not_nil s1.icf_master_id
#			s2 = Factory(:complete_case_study_subject)
#			login_as send(cu)
#			get :new, :studyid => s2.studyid, :icf_master_id => s1.icf_master_id
#			assert_new_success
#			assert_not_nil flash[:warn]
#			assert_match /Multiple Study Subjects Found/, flash[:warn]
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#		end
#
#		test "should get new receive sample with #{cu} login" <<
#				" and studyid and icf_master_id of multiple child control subjects" do
#			s1 = Factory(:complete_control_study_subject, :icf_master_id => '123456789' )
#			assert_not_nil s1.icf_master_id
#			s2 = Factory(:complete_control_study_subject, :studyid => '1234-X-9')
#			login_as send(cu)
#			get :new, :studyid => s2.studyid, :icf_master_id => s1.icf_master_id
#			assert_new_success
#			assert_not_nil flash[:warn]
#			assert_match /Multiple Study Subjects Found/, flash[:warn]
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#		end
#
#		test "should get new receive sample with #{cu} login" <<
#				" and studyid and icf_master_id of multiple child mixed subjects" do
#			s1 = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
#			assert_not_nil s1.icf_master_id
#			s2 = Factory(:complete_control_study_subject, :studyid => '1234-X-9')
#			login_as send(cu)
#			get :new, :studyid => s2.studyid, :icf_master_id => s1.icf_master_id
#			assert_new_success
#			assert_not_nil flash[:warn]
#			assert_match /Multiple Study Subjects Found/, flash[:warn]
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#		end
#
#	SINGLE STUDY SUBJECT FOUND

		test "should get new receive sample with #{cu} login" <<
				" and studyid of subject" do
			study_subject = Factory(:complete_case_study_subject)
			login_as send(cu)
			get :new, :q => study_subject.studyid
			assert_found_single_study_subject(study_subject)
		end

		test "should NOT get new receive sample with #{cu} login" <<
				" and patid as studyid of subject" do
			study_subject = Factory(:complete_case_study_subject)
			login_as send(cu)
			get :new, :q => study_subject.patid
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end

		test "should NOT get new receive sample with #{cu} login" <<
				" and case_control_type as studyid of subject" do
			study_subject = Factory(:complete_case_study_subject)
			login_as send(cu)
			get :new, :q => study_subject.case_control_type
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end

		test "should get new receive sample with #{cu} login" <<
				" and icf_master_id of subject" do
			study_subject = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
			assert_not_nil study_subject.icf_master_id
			login_as send(cu)
			get :new, :q => study_subject.icf_master_id
			assert_found_single_study_subject(study_subject)
		end

		test "should NOT get new receive sample with #{cu} login" <<
				" and first 3 of icf_master_id of subject" do
			study_subject = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
			assert_not_nil study_subject.icf_master_id
			login_as send(cu)
			get :new, :q => study_subject.icf_master_id[0..2]
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end

		test "should NOT get new receive sample with #{cu} login" <<
				" and middle 3 of icf_master_id of subject" do
			study_subject = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
			assert_not_nil study_subject.icf_master_id
			login_as send(cu)
			get :new, :q => study_subject.icf_master_id[3..5]
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end

		test "should NOT get new receive sample with #{cu} login" <<
				" and last 3 of icf_master_id of subject" do
			study_subject = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
			assert_not_nil study_subject.icf_master_id
			login_as send(cu)
			get :new, :q => study_subject.icf_master_id[6..8]
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end

		test "should NOT get new receive sample with #{cu} login" <<
				" and first and last 3 of icf_master_id of subject" do
			study_subject = Factory(:complete_case_study_subject, :icf_master_id => '123456789' )
			assert_not_nil study_subject.icf_master_id
			login_as send(cu)
			get :new, :q => [study_subject.icf_master_id[0..2],
				study_subject.icf_master_id[6..8]].join('  ')
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end

		test "should get new receive sample with #{cu} login" <<
				" and case study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_found_single_study_subject(study_subject)
		end

		test "should get new receive sample with #{cu} login" <<
				" and control study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:control_study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_found_single_study_subject(study_subject)
		end

		test "should get new receive sample with #{cu} login" <<
				" and mother study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:mother_study_subject)
#	just mother, no child
			get :new, :study_subject_id => study_subject.id
#			assert_found_single_study_subject(study_subject)
			assert_no_study_subjects_found
		end






#	TODO what if subject has no enrollments
#	TODO what if subject has no consented enrollments







		test "should get new receive sample with #{cu} login" <<
				" for control mother study subject id" do
			login_as send(cu)
			study_subject = Factory(:control_study_subject)
			mother = study_subject.create_mother
			get :new, :study_subject_id => mother.id
			#	subject is child, NOT mother
			assert_equal assigns(:study_subject), study_subject
		end

		test "should get new receive sample with #{cu} login" <<
				" for case mother study subject id" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			mother = study_subject.create_mother
			get :new, :study_subject_id => mother.id
			#	subject is child, NOT mother
			assert_equal assigns(:study_subject), study_subject
		end

		test "should get new receive sample with #{cu} login" <<
				" for control mother icf master id" do
			login_as send(cu)
			study_subject = Factory(:control_study_subject)
			Factory(:icf_master_id, :icf_master_id => 'ID4MOM01')
			mother = study_subject.create_mother
			assert_not_nil mother.icf_master_id
			get :new, :q => mother.icf_master_id
			#	subject is child, NOT mother
			assert_equal assigns(:study_subject), study_subject
		end

		test "should get new receive sample with #{cu} login" <<
				" for case mother icf master id" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			Factory(:icf_master_id, :icf_master_id => 'ID4MOM02')
			mother = study_subject.create_mother
			assert_not_nil mother.icf_master_id
			get :new, :q => mother.icf_master_id
			#	subject is child, NOT mother
			assert_equal assigns(:study_subject), study_subject
		end

		#
		#	mother has no studyid, so shouldn't matter, so no tests
		#

#		test "should get new receive sample with #{cu} login" <<
#				" for control studyid and mother icf master id" do
#			#	rather than getting multiple subjects, should just be child
#			login_as send(cu)
#			study_subject = Factory(:control_study_subject, :studyid => '1234-X-9')
#			assert_not_nil study_subject.studyid
#			Factory(:icf_master_id, :icf_master_id => 'ID4MOM03')
#			mother = study_subject.create_mother
#			assert_not_nil mother.icf_master_id
#			get :new, :studyid => study_subject.studyid,
#				:icf_master_id => mother.icf_master_id
#			#	subject is child, NOT mother
#			assert_equal assigns(:study_subject), study_subject
#		end
#
#		test "should get new receive sample with #{cu} login" <<
#				" for case studyid and mother icf master id" do
#			#	rather than getting multiple subjects, should just be child
#			login_as send(cu)
#			study_subject = Factory(:case_study_subject)
#			assert_not_nil study_subject.studyid
#			Factory(:icf_master_id, :icf_master_id => 'ID4MOM04')
#			mother = study_subject.create_mother
#			assert_not_nil mother.icf_master_id
#			get :new, :studyid => study_subject.studyid,
#				:icf_master_id => mother.icf_master_id
#			#	subject is child, NOT mother
#			assert_equal assigns(:study_subject), study_subject
#		end

#
#		created samples depend on params[:sample_source] 
#			( this is NOT part of the sample params )
#





		test "should create new sample default for child with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil assigns(:sample).received_by_ccls_at
			#	It is very difficult to compare equality of datetime
			#	but this test could easily be off by a day due to time zones.
			assert_equal   assigns(:sample).received_by_ccls_at.to_date, Date.today
			assert_equal   assigns(:sample).study_subject, study_subject
			assert_create_success
		end

		test "should create new sample for child with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample_source => 'child',
					:sample => factory_attributes
			end
			assert_not_nil assigns(:sample).received_by_ccls_at
			#	It is very difficult to compare equality of datetime
			#	but this test could easily be off by a day due to time zones.
			assert_equal   assigns(:sample).received_by_ccls_at.to_date, Date.today
			assert_equal   assigns(:sample).study_subject, study_subject
			assert_create_success
		end

		test "should create new sample for mother with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			study_subject.create_mother
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample_source => 'mother',
					:sample => factory_attributes
			end
			assert_not_nil assigns(:sample).received_by_ccls_at
			#	It is very difficult to compare equality of datetime
			#	but this test could easily be off by a day due to time zones.
			assert_equal   assigns(:sample).received_by_ccls_at.to_date, Date.today
			assert_equal   assigns(:sample).study_subject, study_subject.mother
			assert_create_success
		end

#	TODO what if is no mother?
#	TODO what if study subject is mother?




		test "should NOT create with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to new_receive_sample_path
		end

		test "should NOT create with #{cu} login " <<
				"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = Factory(:case_study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create with #{cu} login " <<
				"and save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = Factory(:case_study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new receive sample with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:case_study_subject)
			assert_difference('Sample.count',0){
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get new receive sample without login" do
		get :new
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = Factory(:case_study_subject)
		assert_difference('Sample.count',0){
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
		}
		assert_redirected_to_login
	end

protected

	def assert_found_single_study_subject(study_subject=nil)
		assert_new_success
		assert_nil flash[:warn]
		unless study_subject.nil?
			assert_equal study_subject, assigns(:study_subject)
		end
		assert assigns(:sample)
	end

	def assert_no_study_subjects_found
		assert_new_success
		assert_not_nil flash[:warn]
		assert_match /No Study Subjects Found/, flash[:warn]
		assert !assigns(:study_subjects)
	end

	def assert_create_success
		assert_not_nil flash[:notice]
		assert_new_success
	end

	def assert_new_success
		assert_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

end
