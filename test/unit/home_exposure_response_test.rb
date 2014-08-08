require 'test_helper'

class HomeExposureResponseTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to(:study_subject)
	assert_should_protect( :study_subject_id, :study_subject )
	assert_should_require_attribute_length( :additional_comments, :maximum => 65000 )

#	not working
#	assert_should_require_unique_attribute(:study_subject_id)

	test "home_exposure_response factory should create home exposure response" do
		assert_difference('HomeExposureResponse.count',1) {
			home_exposure_response = FactoryGirl.create(:home_exposure_response)
		}
	end

	test "home_exposure_response factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			home_exposure_response = FactoryGirl.create(:home_exposure_response)
			assert_not_nil home_exposure_response.study_subject
		}
	end

	test "should require unique study_subject_id" do
		o = create_home_exposure_response
		assert_no_difference "HomeExposureResponse.count" do
			home_exposure_response = create_home_exposure_response(
				:study_subject => o.study_subject)
#			assert home_exposure_response.errors.on_attr_and_type?(:study_subject_id, :taken)
			assert home_exposure_response.errors.matching?(:study_subject_id, 
				'has already been taken')
		end
	end

	test "should return array of fields" do
		fields = HomeExposureResponse.fields
		assert fields.is_a?(Array)
		assert fields.length > 100
		assert fields.first.is_a?(Hash)
	end

	test "should return array of db_field_names" do
		db_field_names = HomeExposureResponse.db_field_names
		assert db_field_names.is_a?(Array)
		assert db_field_names.length > 100
		assert db_field_names.first.is_a?(String)
	end

#	assert_should_not_require_attributes( *HomeExposureResponse.db_field_names )
	assert_should_not_require( HomeExposureResponse.db_field_names )
	assert_should_not_require_unique( HomeExposureResponse.db_field_names )

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_home_exposure_response

end
