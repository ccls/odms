require 'test_helper'

class SampleTypeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list( :scope => :parent_id )
	assert_should_have_many( :samples )
	assert_should_belong_to( :parent, 
		:class_name => 'SampleType' )
	assert_should_have_many( :children,
		:class_name => 'SampleType',
		:foreign_key => 'parent_id' )
	assert_should_not_require_attributes( :position, :parent_id, 
		:t2k_sample_type_id, :gegl_sample_type_id )
	assert_should_require_attribute_length(:gegl_sample_type_id,
		:maximum => 10)

	test "should return description as to_s" do
		sample_type = SampleType.new(:description => "testing")
		assert_equal sample_type.description, 'testing'
		assert_equal sample_type.description,
			"#{sample_type}"
	end

	test "sample_type factory should create 2 sample types" do
		#	creates sample_type and a parent sample_type
		assert_difference('SampleType.count',2) {	
			sample_type = FactoryGirl.create(:sample_type)
			assert_not_nil sample_type.parent
			assert_match /Key\d*/, sample_type.key
			assert_match /Desc\d*/, sample_type.description
			assert sample_type.is_child?
		}
	end

	test "sample_type parent factory should create sample type" do
		assert_difference('SampleType.count',1) {
			sample_type = FactoryGirl.create(:sample_type_parent)
			assert_nil sample_type.parent
			assert_match /Key\d*/, sample_type.key
			assert_match /Desc\d*/, sample_type.description
			assert sample_type.is_root?
		}
	end

	test "roots should include sample type parent" do
		sample_type = FactoryGirl.create(:sample_type)
		assert sample_type.is_child?
		assert sample_type.parent.is_root?
		assert SampleType.roots.include?(sample_type.parent)
	end

	test "not_roots should include sample type child" do
		sample_type = FactoryGirl.create(:sample_type)
		assert sample_type.is_child?
		assert sample_type.parent.is_root?
		assert SampleType.not_roots.include?(sample_type)
	end

	test "should default to being for_new_sample" do
		sample_type = FactoryGirl.create(:sample_type)
		assert sample_type.for_new_sample?
	end

	test "should be flaggable for not being for_new_sample" do
		sample_type = FactoryGirl.create(:sample_type, :for_new_sample => false)
		assert !sample_type.for_new_sample?
	end

	test "should have children_for_new_samples if child for_new_sample" do
		sample_type = FactoryGirl.create(:sample_type)
		assert !sample_type.parent.children_for_new_samples.empty?
	end

	test "should have no children_for_new_samples if child not for_new_sample" do
		sample_type = FactoryGirl.create(:sample_type, :for_new_sample => false)
		assert sample_type.parent.children_for_new_samples.empty?
	end

#	test "should have no children_for_new_sample if parent not for_new_sample" do
#		sample_type = FactoryGirl.create(:sample_type)
#		assert  sample_type.parent.for_new_sample?
#		sample_type.parent.update_column(:for_new_sample, false)
#		assert !sample_type.parent.for_new_sample?
#		assert  sample_type.for_new_sample?	
#		#	child is, but parent is not, so empty
#		assert sample_type.parent.children_for_new_sample.empty?
#	end

	test "roots.for_new_sample should only include for_new_sample true" do
		assert !SampleType.roots.for_new_samples.empty?
		#	update_all( updates_hash, conditions_hash )
		SampleType.update_all(
			{ :for_new_sample => false },
			{ :parent_id      => nil })
		assert SampleType.roots.for_new_samples.empty?
	end

protected

#	The common assertions use create_object, so leave this alone.

#	def create_object(options = {})
##		record = FactoryGirl.build(:sample_type,options)
##	The normal sample_type factory creates a parent 
##	which seems to cause some testing issues unless
##	this was expected so ....
#		record = FactoryGirl.build(:sample_type_parent,options)
#		record.save
#		record
#	end

#	MAYBE, but need to define create_sample_type_parent
	alias_method :create_object, :create_sample_type_parent

end
