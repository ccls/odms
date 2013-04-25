require 'test_helper'

class IcfMasterIdTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to(:study_subject)
	assert_should_protect( :study_subject_id, :study_subject )

	test "icf_master_id factory should create icf master id" do
		assert_difference('IcfMasterId.count',1) {
			icf_master_id = FactoryGirl.create(:icf_master_id)
			assert_nil icf_master_id.icf_master_id
		}
	end

	test "should return icf_master_id as to_s" do
		icf_master_id = IcfMasterId.new(:icf_master_id => '123456789')
		assert_equal "#{icf_master_id.icf_master_id}", "#{icf_master_id}"
		assert_equal "123456789", "#{icf_master_id}"
	end


	test "unused should return those without a study subject" do
		icf_master_id_1 = FactoryGirl.create(:icf_master_id)
		icf_master_id_2 = FactoryGirl.create(:icf_master_id)
		assert_equal IcfMasterId.unused, [icf_master_id_1,icf_master_id_2]
		icf_master_id_2.study_subject_id = 0
		icf_master_id_2.save
		assert_equal IcfMasterId.unused, [icf_master_id_1]
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_icf_master_id

end
