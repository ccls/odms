require 'test_helper'

class GiftCardTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to(:study_subject, :project)
#	assert_should_protect( :study_subject_id, :study_subject )

	attributes = %w( number study_subject_id
		project_id issued_on expiration vendor )
	required = %w( number )
	unique   = %w( number )
	protected_attributes = %w( study_subject_id study_subject )
	assert_should_require( required )
	assert_should_require_unique( unique )
	assert_should_protect( protected_attributes )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes - protected_attributes )

	assert_should_require_attribute_length( :expiration,
		:vendor, :number, 
			:maximum => 250 )

	test "gift_card factory should create gift card" do
		assert_difference('GiftCard.count',1) {
			gift_card = FactoryGirl.create(:gift_card)
			assert_match /\d*/, gift_card.number
		}
	end

	test "should return number as to_s" do
		gift_card = GiftCard.new(:number => '123456789')
		assert_equal gift_card.number, '123456789'
		assert_equal gift_card.number, "#{gift_card}"
	end

protected

#	def create_gift_card(options={})
#		gift_card = FactoryGirl.build(:gift_card,options)
#		gift_card.save
#		gift_card
#	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_gift_card

end
