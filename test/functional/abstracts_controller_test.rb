require 'test_helper'

class AbstractsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Abstract',
		:actions => [:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_abstract
	}
	assert_access_with_login({ 
		:logins => site_editors })
	assert_no_access_with_login({ 
		:logins => ( all_test_roles - site_editors ) })
	assert_no_access_without_login

	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	def factory_attributes(options={})
		Factory.attributes_for(:complete_abstract,{
		}.merge(options))
	end

#	Still shallow, except new, create, and index (in StudySubjectAbstractsController)
#	Probably never need the stuff below.

#	site_editors.each do |cu|
#
#		test "should show with #{cu} login" do
#pending
#		end
#
#		test "should NOT show with mismatched study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT show with invalid study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT show with invalid id #{cu} login" do
#pending
#		end
#
#		test "should edit with #{cu} login" do
#pending
#		end
#
#		test "should NOT edit with mismatched study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT edit with invalid study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT edit with invalid id #{cu} login" do
#pending
#		end
#
#		test "should update with #{cu} login" do
#pending
#		end
#
#		test "should NOT update with save failure and #{cu} login" do
#pending
#		end
#
#		test "should NOT update with invalid and #{cu} login" do
#pending
#		end
#
#		test "should NOT update with mismatched study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT update with invalid study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT update with invalid id #{cu} login" do
#pending
#		end
#
#		test "should destroy with #{cu} login" do
#pending
#		end
#
#		test "should NOT destroy with mismatched study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT destroy with invalid study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT destroy with invalid id #{cu} login" do
#pending
#		end
#
#		test "should get index with #{cu} login" do
#pending
#		end
#
#		test "should NOT get index with mismatched study_subject_id #{cu} login" do
#pending
#		end
#
#		test "should NOT get index with invalid study_subject_id #{cu} login" do
#pending
#		end
#
#	end
#
#	non_site_editors.each do |cu|
#
#		test "should NOT show with #{cu} login" do
#pending
#		end
#
#		test "should NOT edit with #{cu} login" do
#pending
#		end
#
#		test "should NOT update with #{cu} login" do
#pending
#		end
#
#		test "should NOT destroy with #{cu} login" do
#pending
#		end
#
#		test "should NOT get index with #{cu} login" do
#pending
#		end
#
#	end
#
#	#	not logged in ..
#
#	test "should NOT show without login" do
#pending
#	end
#
#	test "should NOT edit without login" do
#pending
#	end
#
#	test "should NOT update without login" do
#pending
#	end
#
#	test "should NOT destroy without login" do
#pending
#	end
#
#	test "should NOT get index without login" do
#pending
#	end

end
