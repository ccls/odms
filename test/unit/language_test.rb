require 'test_helper'

class LanguageTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many( :interviews, :instrument_versions )

	attributes = %w( code position )
	required   = %w( code )
	unique     = %w( code )
	protected_attributes = []	#	"protected" is a reserved word
	assert_should_require( required )
	assert_should_require_unique( unique )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes - protected_attributes )

	test "language factory should create language" do
		assert_difference('Language.count',1) {
			language = FactoryGirl.create(:language)
			assert_match     /\d*/, language.code.to_s
			assert_match  /Key\d*/, language.key
			assert_match /Desc\d*/, language.description
		}
	end

	test "should return description as to_s" do
		language = Language.new(:description => 'testing')
		assert_equal language.description, 'testing'
		assert_equal language.description, "#{language}"
	end

	test "should find random" do
		language = Language.random()
		assert language.is_a?(Language)
	end

	test "should return nil on random when no records" do
		Language.stubs(:count).returns(0)
		language = Language.random()
		assert_nil language
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_language

end
