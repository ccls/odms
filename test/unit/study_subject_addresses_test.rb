require 'test_helper'

class StudySubjectAddressesTest < ActiveSupport::TestCase

	assert_should_have_many(:addressings, :model => 'StudySubject')

	test "should create study_subject and accept_nested_attributes_for addressings" do
		assert_difference( 'Address.count', 1) {
		assert_difference( 'Addressing.count', 1) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:addressings_attributes => [FactoryGirl.attributes_for(:addressing,
					:data_source => 'unknown data source',
					:address_attributes => FactoryGirl.attributes_for(:address,
					:address_type => 'Residence' ) )])
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} } }
	end

	test "should create study_subject and ignore blank address" do
		assert_difference( 'Address.count', 0) {
		assert_difference( 'Addressing.count', 0) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:addressings_attributes => [FactoryGirl.attributes_for(:addressing,
					:data_source => 'unknown data source',
					:address_attributes => { :address_type => 'Residence' } )])
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} } }
	end

	test "should create study_subject and require address with flag" do
		assert_difference( 'Address.count', 0) {
		assert_difference( 'Addressing.count', 0) {
		assert_difference( "StudySubject.count", 0 ) {
			study_subject = create_study_subject(
				:addressings_attributes => [FactoryGirl.attributes_for(:addressing,
					:data_source => 'unknown data source',
					:address_required   => true,
					:address_attributes => { :address_type => 'Residence' } )])
			assert study_subject.errors.matching?('addressings.address.line_1',"can't be blank")
			assert study_subject.errors.matching?('addressings.address.city',"can't be blank")
			assert study_subject.errors.matching?('addressings.address.state',"can't be blank")
			assert study_subject.errors.matching?('addressings.address.zip',"can't be blank")
		} } }
	end

	test "should update study_subject with addressing" do
		addressing = FactoryGirl.create(:addressing)
		addressing.study_subject.update_attributes(
			:addressings_attributes => { '0' => { 'id' => addressing.id } } )
	end

	test "should respond to residence_addresses_count" do
		study_subject = create_study_subject
		assert study_subject.respond_to?(:residence_addresses_count)
		assert_equal 0, study_subject.residence_addresses_count
		study_subject.update_attributes(
				:addressings_attributes => [FactoryGirl.attributes_for(:addressing,
					:data_source => 'unknown data source',
					:address_attributes => FactoryGirl.attributes_for(:address,
					{ :address_type => 'Residence' } ))])
		assert_equal 1, study_subject.reload.residence_addresses_count
		study_subject.update_attributes(
				:addressings_attributes => [FactoryGirl.attributes_for(:addressing,
					:data_source => 'unknown data source',
					:address_attributes => FactoryGirl.attributes_for(:address,
					{ :address_type => 'Residence' } ))])
		assert_equal 2, study_subject.reload.residence_addresses_count
	end

	test "should NOT destroy addressings with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Addressing.count',1) {
			@study_subject = FactoryGirl.create(:addressing).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Addressing.count',0) {
			@study_subject.destroy
		} }
	end

	test "should NOT destroy addresses with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Address.count',1) {
			@study_subject = FactoryGirl.create(:addressing).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Address.count',0) {
			@study_subject.destroy
		} }
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
