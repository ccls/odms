require 'test_helper'

class SampleTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_have_one( :sample_kit )
	assert_should_have_many( :aliquots )
	assert_should_belong_to( :unit, :sample_format, :sample_temperature )
#	because organization is location_id which is now autoset, 
#	this common class test won't work for it.
#	assert_should_belong_to( :unit, :organization, :sample_format, :sample_temperature )
	assert_should_initially_belong_to( :study_subject, :project, :sample_type )

	attributes = %w( aliquot_or_sample_on_receipt 
		aliquotted_at collected_from_subject_at external_id 
		external_id_source location_id order_no parent_sample_id 
		quantity_in_sample receipt_confirmed_by receipt_confirmed_at
		received_by_ccls_at received_by_lab_at sample_collector_id 
		sample_format sample_format_id sample_temperature 
		sample_temperature_id sent_to_lab_at sent_to_subject_at
		shipped_to_ccls_at state unit unit_id )
	protected_attributes = %w( study_subject_id study_subject )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_protect( protected_attributes )
	assert_should_not_protect( attributes - protected_attributes )

	assert_should_require_attribute_length( :state, :maximum => 250 )

	assert_requires_complete_date( :sent_to_subject_at, 
		:shipped_to_ccls_at, 
		:received_by_ccls_at, 
		:sent_to_lab_at,
		:received_by_lab_at, :aliquotted_at,
		:collected_from_subject_at,
		:receipt_confirmed_at )

	assert_requires_past_date( :sent_to_subject_at,
		:shipped_to_ccls_at,
		:received_by_ccls_at,  :sent_to_lab_at,
		:received_by_lab_at,   :aliquotted_at,
		:receipt_confirmed_at, :collected_from_subject_at )

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
		sample = Sample.new( :sample_type => nil)
		assert !sample.valid?
		assert !sample.errors.include?(:sample_type)
		assert  sample.errors.matching?(:sample_type_id,"can't be blank")
	end

	test "should require valid sample_type if given" do
		sample = Sample.new( :sample_type_id => 0)
		assert !sample.valid?
		assert !sample.errors.include?(:sample_type_id)
		assert  sample.errors.matching?(:sample_type,"can't be blank")
	end

	test "should require study_subject" do
		sample = Sample.new{|s| s.study_subject = nil }
		assert !sample.valid?
		assert !sample.errors.include?(:study_subject)
		assert  sample.errors.matching?(:study_subject_id,"can't be blank")
	end
#	study_subject and study_subject_id are protected
	test "should require valid study_subject if given" do
		sample = Sample.new{|s| s.study_subject_id = 0 }
		assert !sample.valid?
		assert !sample.errors.include?(:study_subject_id)
		assert  sample.errors.matching?(:study_subject,"can't be blank")
	end

	test "should require project" do
		sample = Sample.new( :project => nil)
		assert !sample.valid?
		assert !sample.errors.include?(:project)
		assert  sample.errors.matching?(:project_id,"can't be blank")
	end

	test "should require valid project if given" do
		sample = Sample.new( :project_id => 0)
		assert !sample.valid?
		assert !sample.errors.include?(:project_id)
		assert  sample.errors.matching?(:project,"can't be blank")
	end

	test "should require valid sample_format if given" do
		sample = Sample.new( :sample_format_id => 0)
		assert !sample.valid?
		assert !sample.errors.include?(:sample_format_id)
		assert  sample.errors.matching?(:sample_format,"can't be blank")
	end

	test "should require valid sample_temperature if given" do
		sample = Sample.new( :sample_temperature_id => 0)
		assert !sample.valid?
		assert !sample.errors.include?(:sample_temperature_id)
		assert  sample.errors.matching?(:sample_temperature,"can't be blank")
	end

	test "should default location_id to 19" do
		assert_equal 19, Organization['CCLS'].id
		sample = Sample.new
		assert_equal 19, sample.location_id
		sample = Sample.new(:location_id => '')
		assert_equal 19, sample.location_id
		sample = Sample.new(:location_id => 1)
		assert_equal 1, sample.location_id
	end

	test "should default order_no to 1" do
		sample = Sample.new
		assert_equal 1, sample.order_no
		sample = Sample.new(:order_no => '')
		assert_equal 1, sample.order_no
		sample = Sample.new(:order_no => 9)
		assert_equal 9, sample.order_no
	end

	test "should default aliquot_or_sample_on_receipt to 'Sample'" do
		sample = Sample.new
		assert_equal 'Sample', sample.aliquot_or_sample_on_receipt
#		sample = Sample.new(:aliquot_or_sample_on_receipt => '')
#		assert_equal 'Sample', sample.aliquot_or_sample_on_receipt
		sample = Sample.new(:aliquot_or_sample_on_receipt => 'something')
		assert_equal 'something', sample.aliquot_or_sample_on_receipt
	end

	test "should belong to organization through location_id" do
		sample = Sample.new
		assert_not_nil sample.organization
		assert_equal   sample.organization, Organization['ccls']
		assert_equal   sample.location_id,  Organization['ccls'].id
	end


#	I get this in the functional tests, but I can't seem
#	to reproduce it here.
#	ArgumentError: comparison of Date with ActiveSupport::TimeWithZone failed

#ArgumentError (comparison of Date with ActiveSupport::TimeWithZone failed):
#  /Library/Ruby/Gems/1.8/gems/ccls-ccls_engine-3.10.0/app/models/sample.rb:77:in `>'
#  /Library/Ruby/Gems/1.8/gems/ccls-ccls_engine-3.10.0/app/models/sample.rb:77:in `collected_at_is_before_sent_to_subject_on?'
#  /Library/Ruby/Gems/1.8/gems/ccls-ccls_engine-3.10.0/app/models/sample.rb:64:in `date_chronology'

#	Even if the *_at field is given a Date value, it will be typecast to ActiveSupport::TimeWithZone so there is no terrible need to update all of the tests to send one.


#	test "should require sent_to_subject_on if collected_at" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:sent_to_subject_on => nil,
#				:collected_at       => Date.yesterday
#			)
#			assert sample.errors.matching?(:sent_to_subject_on,"can't be blank")
#		end
#	end
#
#	test "should require collected_at be after sent_to_subject_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:sent_to_subject_on => Date.tomorrow,
#				:collected_at       => Date.yesterday
#			)
#			assert sample.errors.matching?(:collected_at,"after sent_to_subject_on")
#		end
#	end
#
#	test "should require collected_at if received_by_ccls_at" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:collected_at        => nil,
#				:received_by_ccls_at => Date.yesterday
#			)
#			assert sample.errors.matching?(:collected_at,"can't be blank")
#		end
#	end
#
#	test "should require received_by_ccls_at be after collected_at" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:collected_at        => Date.tomorrow,
#				:received_by_ccls_at => Date.yesterday
#			)
#			assert sample.errors.matching?(:received_by_ccls_at,"after collected_at")
#		end
#	end
#
#	test "should require received_by_ccls_at if sent_to_lab_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:received_by_ccls_at => nil,
#				:sent_to_lab_on      => Date.yesterday
#			)
#			assert sample.errors.matching?(:received_by_ccls_at,"can't be blank")
#		end
#	end
#
#	test "should require sent_to_lab_on be after received_by_ccls_at" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:received_by_ccls_at => Date.tomorrow,
#				:received_by_ccls_at => ( DateTime.now + 1.day ),
#				:sent_to_lab_on      => Date.yesterday
#			)
#			assert sample.errors.matching?(:sent_to_lab_on,"after received_by_ccls_at")
#		end
#	end
#
#	test "should require sent_to_lab_on if received_by_lab_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:sent_to_lab_on     => nil,
#				:received_by_lab_on => Date.yesterday
#			)
#			assert sample.errors.matching?(:sent_to_lab_on,"can't be blank")
#		end
#	end
#
#	test "should require received_by_lab_on be after sent_to_lab_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:sent_to_lab_on     => Date.tomorrow,
#				:received_by_lab_on => Date.yesterday
#			)
#			assert sample.errors.matching?(:received_by_lab_on,"after sent_to_lab_on")
#		end
#	end
#
#	test "should require location_id be after sent_to_lab_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:sent_to_lab_on => Date.yesterday
#			)
#			assert sample.errors.matching?(:location_id,"can't be blank")
#		end
#	end
#
#	test "should require received_by_lab_on if aliquotted_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:received_by_lab_on => nil,
#				:aliquotted_on      => Date.yesterday
#			)
#			assert sample.errors.matching?(:received_by_lab_on,"can't be blank")
#		end
#	end
#
#	test "should require aliquotted_on be after received_by_lab_on" do
#		assert_difference( 'Sample.count', 0 ) do
#			sample = create_sample(
#				:received_by_lab_on => Date.tomorrow,
#				:aliquotted_on      => Date.yesterday
#			)
#			assert sample.errors.matching?(:aliquotted_on,"after received_by_lab_on")
#		end
#	end

#	test "should create homex outcome with sample" do
#		study_subject = create_hx_study_subject
#		assert_difference( 'Sample.count', 1 ) {
#		assert_difference( 'HomexOutcome.count', 1 ) {
#			sample = create_sample( 
#				:study_subject => study_subject,
#				:project       => Project['HomeExposures'] )
#		} }
#	end
#
#	test "should update homex outcome sample_outcome to sent" do
#		study_subject = create_hx_study_subject
#		assert_difference( 'OperationalEvent.count', 1 ) {
#		assert_difference( 'Sample.count', 1 ) {
#		assert_difference( 'HomexOutcome.count', 1 ) {
#			sample = create_sample(
#				:study_subject      => study_subject,
#				:project            => Project['HomeExposures'],
#				:sent_to_subject_at => Date.yesterday )
#			assert_equal SampleOutcome['sent'],
#				sample.study_subject.homex_outcome.sample_outcome
#			assert_equal sample.sent_to_subject_at,
#				sample.study_subject.homex_outcome.sample_outcome_on
#		} } }
#	end
#
#	test "should update homex outcome sample_outcome to received" do
#		study_subject = create_hx_study_subject
#		assert_difference( 'OperationalEvent.count', 1 ) {
#		assert_difference( 'Sample.count', 1 ) {
#		assert_difference( 'HomexOutcome.count', 1 ) {
#			today = Date.today
#			sample = create_sample(
#				:study_subject          => study_subject,
#				:project          => Project['HomeExposures'],
#				:sent_to_subject_at  => ( today - 3.days ),
#				:collected_from_subject_at => ( today - 2.days ),
#				:received_by_ccls_at => ( today - 1.day ) )
#			assert_equal SampleOutcome['received'],
#				sample.study_subject.homex_outcome.sample_outcome
#			assert_equal sample.received_by_ccls_at,
#				sample.study_subject.homex_outcome.sample_outcome_on
#		} } }
#	end
#
#	test "should update homex outcome sample_outcome to lab" do
#		study_subject = create_hx_study_subject
##	This update does not create an operational event
##		assert_difference( 'OperationalEvent.count', 1 ) {
#		assert_difference( 'Sample.count', 1 ) {
#		assert_difference( 'HomexOutcome.count', 1 ) {
#			today = Date.today
#			sample = create_sample(
#				:study_subject          => study_subject,
#				:project          => Project['HomeExposures'],
#				:organization        => Factory(:organization),
#				:sent_to_subject_at  => ( today - 4.days ),
#				:collected_from_subject_at => ( today - 3.days ),
#				:received_by_ccls_at => ( today - 2.days ),
#				:sent_to_lab_at      => ( today - 1.day ) )
#			assert !sample.new_record?, "Object was not created"
#			assert_equal SampleOutcome['lab'],
#				sample.study_subject.homex_outcome.sample_outcome
#			assert_equal sample.sent_to_lab_at,
#				sample.study_subject.homex_outcome.sample_outcome_on
#		} } #}
#	end

	test "should respond to sample_type_parent" do
		sample = create_sample
		assert sample.respond_to? :sample_type_parent
		sample_type_parent = sample.sample_type_parent
		assert_not_nil sample_type_parent
		assert sample_type_parent.is_a?(SampleType)
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_sample

end
