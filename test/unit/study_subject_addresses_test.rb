require 'test_helper'

class StudySubjectAddressesTest < ActiveSupport::TestCase

	assert_should_have_many(:addresses, :model => 'StudySubject')

	test "should create study_subject and accept_nested_attributes_for addresses" do
		assert_difference( 'Address.count', 1) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:addresses_attributes => { '0' => FactoryGirl.attributes_for(:address,
					:data_source => 'Unknown Data Source')})
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should create study_subject and ignore blank address" do
		assert_difference( 'Address.count', 0) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:addresses_attributes => { '0' => FactoryGirl.attributes_for(:address,
					:data_source => 'Unknown Data Source',
					:line_1 => nil,
					:city => nil,
					:state => nil,
					:zip => nil )})
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should create study_subject and require address with flag" do
		assert_difference( 'Address.count', 0) {
		assert_difference( "StudySubject.count", 0 ) {
			study_subject = create_study_subject(
				:addresses_attributes => { '0' => FactoryGirl.attributes_for(:address,
					:data_source => 'Unknown Data Source',
					:address_required   => true,
					:line_1 => nil,
					:city => nil,
					:state => nil,
					:zip => nil )})
			assert study_subject.errors.matching?('addresses.line_1',"can't be blank")
			assert study_subject.errors.matching?('addresses.city',"can't be blank")
			assert study_subject.errors.matching?('addresses.state',"can't be blank")
			assert study_subject.errors.matching?('addresses.zip',"can't be blank")
		} }
	end

	test "should update study_subject with address" do
		address = FactoryGirl.create(:address)
		address.study_subject.update_attributes(
			:addresses_attributes => { '0' => { 'id' => address.id } } )
	end

	test "should respond to residence_addresses_count" do
		study_subject = create_study_subject
		assert study_subject.respond_to?(:residence_addresses_count)
		assert_equal 0, study_subject.residence_addresses_count
		study_subject.update_attributes(
				:addresses_attributes => { '0' => FactoryGirl.attributes_for(:residence_address,
					:data_source => 'Unknown Data Source' )})
		assert_equal 1, study_subject.reload.residence_addresses_count
		study_subject.update_attributes(
				:addresses_attributes => { '0' => FactoryGirl.attributes_for(:residence_address,
					:data_source => 'Unknown Data Source' )})
		assert_equal 2, study_subject.reload.residence_addresses_count
	end

	test "should NOT destroy addresses with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Address.count',1) {
			@study_subject = FactoryGirl.create(:address).study_subject
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
