require 'test_helper'

class AliquotTest < ActiveSupport::TestCase

	assert_should_create_default_object

	attributes = %w( position 
		location mass external_aliquot_id external_aliquot_id_source )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :location, :mass, 
			:maximum => 250 )
	assert_should_have_many(:transfers)
	assert_should_initially_belong_to( :sample, :unit )
	assert_should_initially_belong_to( :owner, :class_name => 'Organization' )

	test "aliquot factory should create aliquot" do
		assert_difference('Aliquot.count',1) {
			aliquot = Factory(:aliquot)
		}
	end

	test "aliquot factory should create organization" do
		assert_difference('Organization.count',1) {
			aliquot = Factory(:aliquot)
			assert_not_nil aliquot.owner
		}
	end

	test "aliquot factory should create unit" do
		assert_difference('Unit.count',1) {
			aliquot = Factory(:aliquot)
			assert_not_nil aliquot.unit
		}
	end

	test "aliquot factory should create sample" do
		assert_difference('Sample.count',1) {
			aliquot = Factory(:aliquot)
			assert_not_nil aliquot.sample
		}
	end

	test "should require owner" do
		aliquot = Aliquot.new( :owner => nil)
		assert !aliquot.valid?
		assert aliquot.errors.include?(:owner)
	end

	test "should require valid owner" do
		aliquot = Aliquot.new( :owner_id => 0)
		assert !aliquot.valid?
		assert aliquot.errors.include?(:owner)
	end

	test "should require unit" do
		aliquot = Aliquot.new( :unit => nil)
		assert !aliquot.valid?
		assert aliquot.errors.include?(:unit)
	end

	test "should require valid unit" do
		aliquot = Aliquot.new( :unit_id => 0)
		assert !aliquot.valid?
		assert aliquot.errors.include?(:unit)
	end

	test "should require sample" do
		aliquot = Aliquot.new( :sample => nil)
		assert !aliquot.valid?
		assert aliquot.errors.include?(:sample)
	end

	test "should require valid sample" do
		aliquot = Aliquot.new( :sample_id => 0)
		assert !aliquot.valid?
		assert aliquot.errors.include?(:sample)
	end


	test "should transfer to another organization" do
		aliquot = create_aliquot
		initial_owner = aliquot.owner
		assert_not_nil initial_owner
		new_owner = Factory(:organization)
		assert_difference('aliquot.reload.owner_id') {
		assert_difference('aliquot.transfers.count', 1) {
#		assert_difference('initial_owner.reload.aliquots_count', -1) {
		assert_difference('initial_owner.aliquots.count', -1) {
#		assert_difference('new_owner.reload.aliquots_count', 1) {
		assert_difference('new_owner.aliquots.count', 1) {
		assert_difference('Transfer.count',1) {
			aliquot.transfer_to(new_owner)
		} } } } } #} }
		assert_not_nil aliquot.reload.owner
	end

	test "should NOT transfer if aliquot owner update fails" do
		aliquot = create_aliquot
		initial_owner = aliquot.owner
		assert_not_nil initial_owner
		new_owner = Factory(:organization)
		Aliquot.any_instance.stubs(:update_column).returns(false)
		assert_no_difference('aliquot.reload.owner_id') {
		assert_no_difference('aliquot.transfers.count') {
		assert_no_difference('initial_owner.aliquots.count') {
#		assert_no_difference('initial_owner.aliquots_count') {
		assert_no_difference('new_owner.aliquots.count') {
#		assert_no_difference('new_owner.aliquots_count') {
		assert_no_difference('Transfer.count') {
		assert_raise(ActiveRecord::RecordNotSaved){
			aliquot.transfer_to(new_owner)
		} } } } } } #} }
		assert_not_nil aliquot.reload.owner
	end

	test "should NOT transfer if transfer creation fails" do
		aliquot = create_aliquot
		initial_owner = aliquot.owner
		assert_not_nil initial_owner
		new_owner = Factory(:organization)
		Transfer.any_instance.stubs(:save!).raises(
			ActiveRecord::RecordInvalid.new(Transfer.new))
		assert_no_difference('aliquot.reload.owner_id') {
		assert_no_difference('aliquot.transfers.count') {
		assert_no_difference('initial_owner.aliquots.count') {
#		assert_no_difference('initial_owner.aliquots_count') {
		assert_no_difference('new_owner.aliquots.count') {
#		assert_no_difference('new_owner.aliquots_count') {
		assert_no_difference('Transfer.count') {
		assert_raise(ActiveRecord::RecordInvalid){
			aliquot.transfer_to(new_owner)
		} } } } } } #} }
		assert_not_nil aliquot.reload.owner
	end

	test "should NOT transfer to invalid organization" do
		aliquot = create_aliquot
		initial_owner = aliquot.owner
		assert_not_nil initial_owner
		assert_no_difference('aliquot.reload.owner_id') {
		assert_no_difference('aliquot.transfers.count') {
#		assert_no_difference('initial_owner.aliquots_count') {
		assert_no_difference('initial_owner.aliquots.count') {
		assert_no_difference('Transfer.count') {
		assert_raise(ActiveRecord::RecordNotFound){
			aliquot.transfer_to(0)
		} } } } } #}
		assert_not_nil aliquot.reload.owner
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_aliquot

end
