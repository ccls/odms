require 'test_helper'

class SampleTransferTest < ActiveSupport::TestCase

	assert_should_initially_belong_to :sample
	assert_should_belong_to( :source_org, :destination_org, 
		:class_name => 'Organization' )

	assert_should_require_attribute_length( :status, :maximum => 250 )
	assert_should_require_attribute_length( :notes, :maximum => 65000 )

	test "should return sample_transfers with status blank" do
		sample_transfer = Factory(:sample_transfer)
		assert sample_transfer.status.blank?
		assert SampleTransfer.with_status().include?(sample_transfer)
	end

	test "should return sample_transfers with status bogus" do
		blank_sample_transfer = Factory(:sample_transfer)
		assert blank_sample_transfer.status.blank?
		sample_transfer = Factory(:sample_transfer)
		assert  sample_transfer.status.blank?
		sample_transfers = SampleTransfer.with_status('bogus')
		assert !sample_transfers.include?(sample_transfer)
		assert !sample_transfers.include?(blank_sample_transfer)
	end

	SampleTransfer.statuses.each do |status|
		test "should return sample_transfers with status #{status}" do
			blank_sample_transfer = Factory(:sample_transfer)
			assert blank_sample_transfer.status.blank?
			sample_transfer = Factory(:sample_transfer, :status => status)
			assert !sample_transfer.status.blank?
			assert_equal status, sample_transfer.status
			sample_transfers = SampleTransfer.with_status(status)
			assert  sample_transfers.include?(sample_transfer)
			assert !sample_transfers.include?(blank_sample_transfer)
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_sample_transfer

end
