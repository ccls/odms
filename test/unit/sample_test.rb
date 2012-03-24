require 'test_helper'

class SampleTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_have_one( :sample_kit )
	assert_should_have_many( :aliquots )
	assert_should_belong_to( :unit, 
		:organization, :sample_format, :sample_temperature )
	assert_should_initially_belong_to( :study_subject, :project, :sample_type )

	attributes = %w( aliquot_or_sample_on_receipt 
		aliquotted_on collected_at external_id 
		external_id_source location_id order_no parent_sample_id position 
		quantity_in_sample receipt_confirmed_by receipt_confirmed_on 
		received_by_ccls_at received_by_lab_on sample_collector_id 
		sample_format sample_format_id sample_temperature 
		sample_temperature_id sent_to_lab_on sent_to_subject_on state unit unit_id )
	protected_attributes = %w( study_subject_id study_subject )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_protect( protected_attributes )
	assert_should_not_protect( attributes - protected_attributes )

	assert_should_require_attribute_length( :state, :maximum => 250 )

#	TODO These seem to fail for DateTimes.  Need to check it out.
	assert_requires_complete_date( :sent_to_subject_on, 
#		:received_by_ccls_at, 
		:sent_to_lab_on,
		:received_by_lab_on, :aliquotted_on,
#		:collected_at,
		:receipt_confirmed_on )

	assert_requires_past_date( :sent_to_subject_on,
		:received_by_ccls_at,  :sent_to_lab_on,
		:received_by_lab_on,   :aliquotted_on,
		:receipt_confirmed_on, :collected_at )

	test "explicit Factory sample test" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Enrollment.count',1) {
		assert_difference('SampleType.count',2) {	#	creates sample_type and a parent sample_type
		assert_difference('Sample.count',1) {
		assert_difference('Project.count',1) {
			sample = Factory(:sample)
			assert_not_nil sample.sample_type
			assert_not_nil sample.sample_type.parent
			assert_not_nil sample.study_subject
			assert_not_nil sample.project
		} } } } }
	end

	test "should require sample_type" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :sample_type => nil)
			assert !sample.errors.include?(:sample_type)
			assert  sample.errors.matching?(:sample_type_id,"can't be blank")
		end
	end

	test "should require valid sample_type if given" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :sample_type_id => 0)
			assert !sample.errors.include?(:sample_type_id)
			assert  sample.errors.matching?(:sample_type,"can't be blank")
		end
	end

	test "should require study_subject" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :study_subject => nil)
			assert !sample.errors.include?(:study_subject)
			assert  sample.errors.matching?(:study_subject_id,"can't be blank")
		end
	end

	test "should require valid study_subject if given" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :study_subject_id => 0)
			assert !sample.errors.include?(:study_subject_id)
			assert  sample.errors.matching?(:study_subject,"can't be blank")
		end
	end

	test "should require project" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :project => nil)
			assert !sample.errors.include?(:project)
			assert  sample.errors.matching?(:project_id,"can't be blank")
		end
	end

	test "should require valid project if given" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :project_id => 0)
			assert !sample.errors.include?(:project_id)
			assert  sample.errors.matching?(:project,"can't be blank")
		end
	end

	test "should require valid sample_format if given" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :sample_format_id => 0)
			assert !sample.errors.include?(:sample_format_id)
			assert  sample.errors.matching?(:sample_format,"can't be blank")
		end
	end

	test "should require valid sample_temperature if given" do
		assert_difference( "Sample.count", 0 ) do
			sample = create_sample( :sample_temperature_id => 0)
			assert !sample.errors.include?(:sample_temperature_id)
			assert  sample.errors.matching?(:sample_temperature,"can't be blank")
		end
	end

	test "should default order_no to 1" do
		sample = create_sample
		assert_equal 1, sample.order_no
	end

	test "should default aliquot_or_sample_on_receipt to 'Sample'" do
		sample = create_sample
		assert_equal 'Sample', sample.aliquot_or_sample_on_receipt
	end

#	somehow, through location_id I think

#	TODO haven't really implemented organization samples yet
#	test "should belong to organization" do
#		sample = create_sample
#		assert_nil sample.organization
#		sample.organization = Factory(:organization)
#		assert_not_nil sample.organization
#		#	this is not clear in my UML diagram
#		pending
#	end


#	I get this in the functional tests, but I can't seem
#	to reproduce it here.
#	ArgumentError: comparison of Date with ActiveSupport::TimeWithZone failed

#ArgumentError (comparison of Date with ActiveSupport::TimeWithZone failed):
#  /Library/Ruby/Gems/1.8/gems/ccls-ccls_engine-3.10.0/app/models/sample.rb:77:in `>'
#  /Library/Ruby/Gems/1.8/gems/ccls-ccls_engine-3.10.0/app/models/sample.rb:77:in `collected_at_is_before_sent_to_subject_on?'
#  /Library/Ruby/Gems/1.8/gems/ccls-ccls_engine-3.10.0/app/models/sample.rb:64:in `date_chronology'

#	Even if the *_at field is given a Date value, it will be typecast to ActiveSupport::TimeWithZone so there is no terrible need to update all of the tests to send one.


	test "should require sent_to_subject_on if collected_at" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:sent_to_subject_on => nil,
				:collected_at       => Date.yesterday
			)
			assert sample.errors.matching?(:sent_to_subject_on,"can't be blank")
		end
	end

	test "should require collected_at be after sent_to_subject_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:sent_to_subject_on => Date.tomorrow,
				:collected_at       => Date.yesterday
			)
			assert sample.errors.matching?(:collected_at,"after sent_to_subject_on")
		end
	end

	test "should require collected_at if received_by_ccls_at" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:collected_at        => nil,
				:received_by_ccls_at => Date.yesterday
			)
			assert sample.errors.matching?(:collected_at,"can't be blank")
		end
	end

	test "should require received_by_ccls_at be after collected_at" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:collected_at        => Date.tomorrow,
				:received_by_ccls_at => Date.yesterday
			)
			assert sample.errors.matching?(:received_by_ccls_at,"after collected_at")
		end
	end

	test "should require received_by_ccls_at if sent_to_lab_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:received_by_ccls_at => nil,
				:sent_to_lab_on      => Date.yesterday
			)
			assert sample.errors.matching?(:received_by_ccls_at,"can't be blank")
		end
	end

	test "should require sent_to_lab_on be after received_by_ccls_at" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:received_by_ccls_at => Date.tomorrow,
				:received_by_ccls_at => ( DateTime.now + 1.day ),
				:sent_to_lab_on      => Date.yesterday
			)
			assert sample.errors.matching?(:sent_to_lab_on,"after received_by_ccls_at")
		end
	end

	test "should require sent_to_lab_on if received_by_lab_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:sent_to_lab_on     => nil,
				:received_by_lab_on => Date.yesterday
			)
			assert sample.errors.matching?(:sent_to_lab_on,"can't be blank")
		end
	end

	test "should require received_by_lab_on be after sent_to_lab_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:sent_to_lab_on     => Date.tomorrow,
				:received_by_lab_on => Date.yesterday
			)
			assert sample.errors.matching?(:received_by_lab_on,"after sent_to_lab_on")
		end
	end

	test "should require location_id be after sent_to_lab_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:sent_to_lab_on => Date.yesterday
			)
			assert sample.errors.matching?(:location_id,"can't be blank")
		end
	end

	test "should require received_by_lab_on if aliquotted_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:received_by_lab_on => nil,
				:aliquotted_on      => Date.yesterday
			)
			assert sample.errors.matching?(:received_by_lab_on,"can't be blank")
		end
	end

	test "should require aliquotted_on be after received_by_lab_on" do
		assert_difference( 'Sample.count', 0 ) do
			sample = create_sample(
				:received_by_lab_on => Date.tomorrow,
				:aliquotted_on      => Date.yesterday
			)
			assert sample.errors.matching?(:aliquotted_on,"after received_by_lab_on")
		end
	end

	test "should create homex outcome with sample" do
		study_subject = create_hx_study_subject
		assert_difference( 'Sample.count', 1 ) {
		assert_difference( 'HomexOutcome.count', 1 ) {
			sample = create_sample( 
				:study_subject => study_subject,
				:project       => Project['HomeExposures'] )
		} }
	end

	test "should update homex outcome sample_outcome to sent" do
		study_subject = create_hx_study_subject
		assert_difference( 'OperationalEvent.count', 1 ) {
		assert_difference( 'Sample.count', 1 ) {
		assert_difference( 'HomexOutcome.count', 1 ) {
			sample = create_sample(
				:study_subject      => study_subject,
				:project            => Project['HomeExposures'],
				:sent_to_subject_on => Date.yesterday )
			assert_equal SampleOutcome['sent'],
				sample.study_subject.homex_outcome.sample_outcome
			assert_equal sample.sent_to_subject_on,
				sample.study_subject.homex_outcome.sample_outcome_on
		} } }
	end

	test "should update homex outcome sample_outcome to received" do
		study_subject = create_hx_study_subject
		assert_difference( 'OperationalEvent.count', 1 ) {
		assert_difference( 'Sample.count', 1 ) {
		assert_difference( 'HomexOutcome.count', 1 ) {
			today = Date.today
			sample = create_sample(
				:study_subject          => study_subject,
				:project          => Project['HomeExposures'],
				:sent_to_subject_on  => ( today - 3.days ),
				:collected_at        => ( today - 2.days ),
				:received_by_ccls_at => ( today - 1.day ) )
			assert_equal SampleOutcome['received'],
				sample.study_subject.homex_outcome.sample_outcome
			assert_equal sample.received_by_ccls_at,
				sample.study_subject.homex_outcome.sample_outcome_on
		} } }
	end

	test "should update homex outcome sample_outcome to lab" do
		study_subject = create_hx_study_subject
#	This update does not create an operational event
#		assert_difference( 'OperationalEvent.count', 1 ) {
		assert_difference( 'Sample.count', 1 ) {
		assert_difference( 'HomexOutcome.count', 1 ) {
			today = Date.today
			sample = create_sample(
				:study_subject          => study_subject,
				:project          => Project['HomeExposures'],
				:organization        => Factory(:organization),
				:sent_to_subject_on  => ( today - 4.days ),
				:collected_at        => ( today - 3.days ),
				:received_by_ccls_at => ( today - 2.days ),
				:sent_to_lab_on      => ( today - 1.day ) )
			assert !sample.new_record?, "Object was not created"
			assert_equal SampleOutcome['lab'],
				sample.study_subject.homex_outcome.sample_outcome
			assert_equal sample.sent_to_lab_on,
				sample.study_subject.homex_outcome.sample_outcome_on
		} } #}
	end

	test "should respond to sample_type_parent" do
		sample = create_sample
		assert sample.respond_to? :sample_type_parent
		sample_type_parent = sample.sample_type_parent
		assert_not_nil sample_type_parent
		assert sample_type_parent.is_a?(SampleType)
	end

#protected
#
#	def create_sample(options={})
#		sample = Factory.build(:sample,options)
#		sample.save
#		sample
#	end

end
