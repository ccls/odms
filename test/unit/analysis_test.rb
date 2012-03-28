require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object

	attributes = %w( analyst_id project_id analytic_file_creator_id
		analytic_file_created_date analytic_file_last_pulled_date
		analytic_file_location analytic_file_filename )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_belong_to( 
		:analytic_file_creator, 
		:analyst,
			:class_name => 'Person' )
	assert_should_belong_to( :project )
	assert_should_habtm( :study_subjects )

	test "explicit Factory analysis test" do
		assert_difference('Analysis.count',1) {
			analysis = Factory(:analysis)
			assert_match /Key\d*/, analysis.key
			assert_match /Desc\d*/, analysis.description
		}
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_analysis

#	#	create_object is called from within the common class tests
#	def create_object(options={})
#		object = Factory.build(:analysis,options)
#		object.save
#		object
#	end

end
