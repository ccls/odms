require 'test_helper'

class StudySubjectPhoneNumbersTest < ActiveSupport::TestCase

	assert_should_have_many( :phone_numbers, :model => 'StudySubject' )

	test "should create study_subject and accept_nested_attributes_for phone_numbers" do
		assert_difference( 'PhoneNumber.count', 1) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:phone_numbers_attributes => [FactoryGirl.attributes_for(:phone_number,
					:data_source => 'unknown data source',
					:phone_type  => 'Home' )])
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should create study_subject and ignore blank phone_number" do
		assert_difference( 'PhoneNumber.count', 0) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:phone_numbers_attributes => [FactoryGirl.attributes_for(:phone_number,
					:data_source  => 'unknown data source',
					:phone_number => '' )])
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should NOT destroy phone_numbers with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('PhoneNumber.count',1) {
			@study_subject = FactoryGirl.create(:phone_number).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('PhoneNumber.count',0) {
			@study_subject.destroy
		} }
	end

	test "should have a current primary phone" do
		phone = FactoryGirl.create(:current_primary_phone_number)
		assert_equal phone, phone.study_subject.current_primary_phone
	end

	test "should have a current alternate phone" do
		phone = FactoryGirl.create(:current_alternate_phone_number)
		assert_equal phone, phone.study_subject.current_alternate_phone
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
