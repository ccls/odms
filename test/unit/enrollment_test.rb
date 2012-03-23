require 'test_helper'

class EnrollmentTest < ActiveSupport::TestCase

	assert_should_accept_only_good_values( :use_smp_future_rsrch,
		:use_smp_future_cancer_rsrch, :use_smp_future_other_rsrch,
		:share_smp_with_others, :contact_for_related_study,
		:provide_saliva_smp, :receive_study_findings ,
		{ :good_values => ( ADNA.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_accept_only_good_values( :consented, :is_eligible,
		:is_chosen, :is_complete, :terminated_participation,
		:is_candidate,
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_create_default_object
	assert_should_protect(:study_subject_id, :study_subject)

	attributes = %w( completed_on contact_for_related_study document_version_id 
		ineligible_reason_id other_ineligible_reason is_candidate is_chosen 
		is_closed is_complete is_eligible notes other_refusal_reason position 
		provide_saliva_smp reason_closed reason_not_chosen receive_study_findings 
		recruitment_priority refusal_reason_id refused_by_family refused_by_physician 
		share_smp_with_others terminated_participation terminated_reason 
		use_smp_future_cancer_rsrch use_smp_future_other_rsrch use_smp_future_rsrch )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( 
		:recruitment_priority,
		:other_ineligible_reason,
		:other_refusal_reason,
		:reason_not_chosen,
		:terminated_reason,
		:reason_closed, 
			:maximum => 250 )

	assert_should_have_many(:follow_ups)
	assert_should_belong_to( 
		:tracing_status,
		:project_outcome,
		:ineligible_reason,
		:refusal_reason,
		:document_version )
	assert_should_require_attribute_length( :notes, :maximum => 65000 )

#	using subjectless_enrollment so, this isn't true
	assert_should_belong_to(:study_subject)
	assert_should_initially_belong_to(:project)

	assert_requires_complete_date(:completed_on, :consented_on)
	assert_requires_past_date(    :completed_on, :consented_on)

	test "explicit Factory enrollment test" do
		assert_difference('Project.count',1) {
		assert_difference('StudySubject.count',1) {
		#	NOTE this enrollment AND the subject's ccls enrollment
		assert_difference('Enrollment.count',2) {	
			enrollment = Factory(:enrollment)
			assert !enrollment.consented
			assert_not_nil enrollment.project
			assert_not_nil enrollment.study_subject
		} } }
	end

	test "explicit Factory subjectless_enrollment test" do
		assert_difference('Project.count',1) {
		assert_difference('StudySubject.count',0) {
		assert_difference('Enrollment.count',1) {
			enrollment = Factory(:subjectless_enrollment)
			assert !enrollment.consented
			assert_not_nil enrollment.project
			assert_nil     enrollment.study_subject
		} } }
	end

	test "explicit Factory consented_enrollment test" do
		assert_difference('Project.count',1) {
		assert_difference('StudySubject.count',1) {
		#	NOTE this enrollment AND the subject's ccls enrollment
		assert_difference('Enrollment.count',2) {	
			enrollment = Factory(:consented_enrollment)
			assert enrollment.consented
			assert_equal enrollment.consented, YNDK[:yes]
			assert_not_nil enrollment.project
			assert_not_nil enrollment.study_subject
		} } }
	end

	test "explicit Factory declined_enrollment test" do
		assert_difference('Project.count',1) {
		assert_difference('StudySubject.count',1) {
		#	NOTE this enrollment AND the subject's ccls enrollment
		assert_difference('Enrollment.count',2) {	
			enrollment = Factory(:declined_enrollment)
			assert enrollment.consented
			assert_equal enrollment.consented, YNDK[:no]
			assert_not_nil enrollment.project
			assert_not_nil enrollment.study_subject
		} } }
	end

	test "should require project" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment( :project => nil)
			assert !enrollment.errors.include?(:project)
			assert  enrollment.errors.matching?(:project_id,"can't be blank")
		end
	end

	test "should require valid project" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment( :project_id => 0)
			assert !enrollment.errors.include?(:project_id)
			assert  enrollment.errors.matching?(:project,"can't be blank")
		end
	end

	test "should require unique project_id scope study_subject_id" do
		o = create_enrollment
		assert_no_difference "Enrollment.count" do
			enrollment = create_enrollment(:project => o.project,
				:study_subject => o.study_subject)
			assert enrollment.errors.matching?(:project_id,'has already been taken')
		end
	end

	test "should require ineligible_reason if is_eligible == :no" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:is_eligible => YNDK[:no])
			assert !enrollment.errors.include?(:ineligible_reason)
			#	NOTE custom message
			assert  enrollment.errors.matching?(:ineligible_reason_id,
				"required if is_eligible is No")
		end
	end
	test "should require valid ineligible_reason if is_eligible == :no" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:is_eligible => YNDK[:no],
				:ineligible_reason_id => 0)
			assert !enrollment.errors.include?(:ineligible_reason_id)
			assert  enrollment.errors.matching?(:ineligible_reason,"can't be blank")
		end
	end
	[:yes,:dk,:nil].each do |yndk|
		test "should NOT ALLOW ineligible_reason if is_eligible == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:is_eligible => YNDK[yndk],
					:ineligible_reason => Factory(:ineligible_reason) )
				assert !enrollment.errors.include?(:ineligible_reason)
				#	NOTE custom message
				assert  enrollment.errors.matching?(:ineligible_reason_id,
					"not allowed unless is_eligible is No")
			end
		end
	end


	test "should require other_ineligible_reason if " <<
			"ineligible_reason == other" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(
				:is_eligible => YNDK[:no],
				:ineligible_reason => IneligibleReason['other'] )
			assert enrollment.errors.include?(:other_ineligible_reason)
			#	NOTE custom error message
			assert enrollment.errors.matching?(:other_ineligible_reason,
				"required if ineligible reason is Other")
		end
	end
	test "should ALLOW other_ineligible_reason if " <<
			"ineligible_reason != other" do
		assert_difference( "Enrollment.count", 1 ) do
			enrollment = create_subjectless_enrollment(
				:is_eligible => YNDK[:no],
				:ineligible_reason => Factory(:ineligible_reason),
				:other_ineligible_reason => 'blah blah blah' )
			assert !enrollment.errors.include?(:other_ineligible_reason)
		end
	end
	[:yes,:dk,:nil].each do |yndk|
		test "should NOT ALLOW other_ineligible_reason if " <<
				"is_eligible == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(
					:is_eligible => YNDK[yndk],
					:ineligible_reason => Factory(:ineligible_reason),
					:other_ineligible_reason => 'blah blah blah' )
				assert enrollment.errors.include?(:other_ineligible_reason)
				#	NOTE custom error message
				assert enrollment.errors.matching?(:other_ineligible_reason,
					'not allowed unless is_eligible is No')
			end
		end
	end

	test "should require reason_not_chosen if is_chosen == :no" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:is_chosen => YNDK[:no])
			assert enrollment.errors.include?(:reason_not_chosen)
			#	NOTE custom error message
			assert enrollment.errors.matching?(:reason_not_chosen,"requires if is_chosen is No")
		end
	end
	[:yes,:dk,:nil].each do |yndk|
		test "should NOT ALLOW reason_not_chosen if is_chosen == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:is_chosen => YNDK[yndk],
					:reason_not_chosen => "blah blah blah")
				assert enrollment.errors.include?(:reason_not_chosen)
				#	NOTE custom error message
				assert enrollment.errors.matching?(:reason_not_chosen,
					'not allowed unless is_chosen is No')
			end
		end
	end

	test "should require refusal_reason if consented == :no" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:no])
			assert !enrollment.errors.include?(:refusal_reason)
			#	NOTE custom error message
			assert  enrollment.errors.matching?(:refusal_reason_id,
				"required if consented is No")
		end
	end
	test "should require valid refusal_reason if consented == :no" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:no],
				:refusal_reason_id => 0)
			assert !enrollment.errors.include?(:refusal_reason_id)
			assert  enrollment.errors.matching?(:refusal_reason,"can't be blank")
		end
	end
	[:yes,:dk,:nil].each do |yndk|
		test "should NOT ALLOW refusal_reason if consented == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:consented => YNDK[yndk],
					:refusal_reason_id => Factory(:refusal_reason).id)	#	added id
				assert !enrollment.errors.include?(:refusal_reason)
				#	NOTE custom error message
				assert  enrollment.errors.matching?(:refusal_reason_id,
					"not allowed unless consented is No")
			end
		end
	end


	test "should require other_refusal_reason if " <<
			"refusal_reason == other" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:no],
				:refusal_reason => RefusalReason['other'] )
			assert enrollment.errors.include?(:other_refusal_reason)
			#	NOTE custom error message
			assert enrollment.errors.matching?(:other_refusal_reason,
				"required if refusal reason is Other")
		end
	end
	test "should ALLOW other_refusal_reason if " <<
			"refusal_reason != other" do
		assert_difference( "Enrollment.count", 1 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:no],
				:consented_on => Date.today,
				:refusal_reason => Factory(:refusal_reason),
				:other_refusal_reason => 'asdfasdf' )
			assert !enrollment.errors.include?(:other_refusal_reason)
		end
	end
	[:yes,:dk,:nil].each do |yndk|
		test "should NOT ALLOW other_refusal_reason if "<<
				"consented == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:consented => YNDK[yndk],
					:refusal_reason => Factory(:refusal_reason),
					:other_refusal_reason => 'asdfasdf' )
				assert enrollment.errors.include?(:other_refusal_reason)
				#	NOTE custom error message
				assert enrollment.errors.matching?(:other_refusal_reason,
					"not allowed unless consented is No")
			end
		end
	end

	[:yes,:no].each do |yndk|
		test "should require consented_on if consented == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:consented => YNDK[yndk],
					:consented_on => nil)
				#	NOTE Custom error message
				assert enrollment.errors.matching?(:consented_on,
					"date is required when adding consent information")
			end
		end
	end
	[:dk,:nil].each do |yndk|
		test "should NOT ALLOW consented_on if consented == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:consented => YNDK[yndk],
					:consented_on => Date.today)
				assert enrollment.errors.include?(:consented_on)
				#	NOTE Custom error message
				assert enrollment.errors.matching?(:consented_on,
					"not allowed if consented is blank or Don't Know")
			end
		end
	end


	test "should require terminated_reason if " <<
			"terminated_participation == :yes" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:terminated_participation => YNDK[:yes])
			assert enrollment.errors.include?(:terminated_reason)
			#	NOTE custom message
			assert enrollment.errors.matching?(:terminated_reason,
				"required if terminated participation is Yes")
		end
	end
	[:no,:dk,:nil].each do |yndk|
		test "should NOT ALLOW terminated_reason if " <<
				"terminated_participation == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(
					:terminated_participation => YNDK[yndk],
					:terminated_reason => 'some bogus reason')
				assert enrollment.errors.include?(:terminated_reason)
				#	NOTE custom message
				assert enrollment.errors.matching?(:terminated_reason,
					"not allowed unless terminated participation is Yes")
			end
		end
	end

	test "should require completed_on if is_complete == :yes" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:is_complete => YNDK[:yes])
			assert enrollment.errors.include?(:completed_on)
			#	NOTE custom error message
			assert enrollment.errors.matching?(:completed_on,"required if is_complete is Yes")
		end
	end
	[:no,:dk,:nil].each do |yndk|
		test "should NOT ALLOW completed_on if is_complete == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:is_complete => YNDK[yndk],
					:completed_on => Date.today)
				assert enrollment.errors.include?(:completed_on)
				#	NOTE custom error message
				assert enrollment.errors.matching?(:completed_on,
					"not allowed unless is_complete is Yes")
			end
		end
	end


	[:dk,:nil].each do |yndk|
		test "should NOT ALLOW document_version_id if consented == #{yndk}" do
			assert_difference( "Enrollment.count", 0 ) do
				enrollment = create_subjectless_enrollment(:consented => YNDK[yndk],
					:document_version => Factory(:document_version) )
				assert !enrollment.errors.include?(:document_version)
				#	NOTE custom error message
				assert  enrollment.errors.matching?(:document_version_id,
					"not allowed if consented is blank or Don't Know")
			end
		end
	end
	test "should allow document_version_id if consented == :yes" do
		assert_difference( "Enrollment.count", 1 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:yes],
				:consented_on     => Date.today,
				:document_version => Factory(:document_version) )
		end
	end
	test "should allow document_version_id if consented == :no" do
		assert_difference( "Enrollment.count", 1 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:no],
				:consented_on     => Date.today,
				:refusal_reason   => Factory(:refusal_reason),
				:document_version => Factory(:document_version) )
		end
	end
	test "should require valid document_version if given" do
		assert_difference( "Enrollment.count", 0 ) do
			enrollment = create_subjectless_enrollment(:consented => YNDK[:yes],
				:consented_on     => Date.today,
				:document_version_id => 0 )
			assert !enrollment.errors.include?(:document_version_id)
			assert  enrollment.errors.matching?(:document_version,"can't be blank")
		end
	end

#	Operational Event ARE NOT directly associated with enrollments,
#	but I left the tests here.

	test "should create operational event when enrollment complete" do
		enrollment = Factory(:enrollment,
			:completed_on => nil,
			:is_complete  => YNDK[:no])
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference("enrollment.study_subject.operational_events.count",1){
			enrollment.update_attributes(
				:completed_on => past_date,
				:is_complete => YNDK[:yes])
		}
		oe = enrollment.study_subject.operational_events.where(
			:project_id => enrollment.project_id).order('id ASC').last
		assert_equal 'complete', oe.operational_event_type.key
		assert_equal past_date,  oe.occurred_on
	end

	test "should create operational event when enrollment complete UNSET" do
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		enrollment = nil
		study_subject = Factory(:study_subject)
		assert_difference('OperationalEvent.count',1) do
			enrollment = Factory(:enrollment,
				:study_subject => study_subject,
				:completed_on  => past_date,
				:is_complete   => YNDK[:yes])
		end
		oe = study_subject.operational_events.where(
			:project_id => enrollment.project_id).order('id ASC').last
		assert_equal 'complete', oe.operational_event_type.key
		assert_difference('OperationalEvent.count',1) do
			enrollment.update_attributes(
				:is_complete => YNDK[:no],
				:completed_on => nil)
		end
		#	default_scope is mucking this up.  Unscope it!
		#	 ORDER BY occurred_on ASC, id DESC LIMIT 1
		oe = study_subject.operational_events.where(
			:project_id => enrollment.project_id).order('id ASC').last
		assert_equal 'reopened', oe.operational_event_type.key
		assert_equal Date.today, oe.occurred_on
	end

	test "should create subjectConsents operational event if consent changes to yes" do
		enrollment = Factory(:enrollment)
		assert_nil enrollment.consented
		assert_difference("enrollment.study_subject.operational_events.count",1){
			enrollment.update_attributes(:consented => YNDK[:yes],
				:consented_on => Date.today )
		}
		enrollment.reload
		assert_equal enrollment.consented, YNDK[:yes]
		assert_equal enrollment.consented_on, Date.today
		consented_event = enrollment.study_subject.operational_events.where(
			:project_id => enrollment.project_id).where(
			:operational_event_type_id => OperationalEventType['subjectConsents'].id ).first
		assert_not_nil consented_event
	end

	test "should not create subjectConsents operational event if consent doesn't change" do
		enrollment = Factory(:consented_enrollment)
		assert_not_nil enrollment.consented
		assert_difference("enrollment.study_subject.operational_events.count",0){
			enrollment.update_attributes(:consented => YNDK[:yes],
				:consented_on => Date.today )
		}
		enrollment.reload
		assert_equal enrollment.consented, YNDK[:yes]
		assert_equal enrollment.consented_on, Date.today
		consented_event = enrollment.study_subject.operational_events.where(
			:project_id => enrollment.project_id).where(
			:operational_event_type_id => OperationalEventType['subjectConsents'].id ).first
		assert_not_nil consented_event
	end

	test "should create subjectDeclines operational event if consent changes to no" do
		enrollment = Factory(:enrollment)
		assert_nil enrollment.consented
		assert_difference("enrollment.study_subject.operational_events.count",1){
			enrollment.update_attributes(:consented => YNDK[:no],
				:refusal_reason => Factory(:refusal_reason),
				:consented_on   => Date.today )
		}
		enrollment.reload
		assert_equal enrollment.consented, YNDK[:no]
		assert_equal enrollment.consented_on, Date.today
		declined_event = enrollment.study_subject.operational_events.where(
			:project_id => enrollment.project_id).where(
			:operational_event_type_id => OperationalEventType['subjectDeclines'].id ).first
		assert_not_nil declined_event
	end

	test "should not create subjectDeclines operational event if consent doesn't change" do
		enrollment = Factory(:declined_enrollment)
		assert_not_nil enrollment.consented
		assert_difference("enrollment.study_subject.operational_events.count",0){
			enrollment.update_attributes(:consented => YNDK[:no],
				:consented_on => Date.today )
		}
		enrollment.reload
		assert_equal enrollment.consented, YNDK[:no]
		assert_equal enrollment.consented_on, Date.today
		declined_event = enrollment.study_subject.operational_events.where(
			:project_id => enrollment.project_id).where(
			:operational_event_type_id => OperationalEventType['subjectDeclines'].id ).first
		assert_not_nil declined_event
	end

	test "should have consented named_scope" do
		assert_equal [], Enrollment.consented
		Factory(:enrollment)
		assert_equal [], Enrollment.consented
		enrollment = Factory(:consented_enrollment)
		assert_equal [enrollment], Enrollment.consented
		Factory(:enrollment)
		assert_equal [enrollment], Enrollment.consented
	end

protected

	#	MUST define this method so can use the alias_method below.
	#	Or could just define create_object.  Either way.
	def create_subjectless_enrollment(options={})
		enrollment = Factory.build(:subjectless_enrollment,options)
		enrollment.save
		enrollment
	end

#	create_object is used in the basic assertions,
#	but it creates a subject which creates an enrollment and operational_event
#	so if I create a subjectless enrollment, they work
	alias_method :create_object, :create_subjectless_enrollment

#	def create_enrollment(options={})
#		enrollment = Factory.build(:enrollment,options)
#		enrollment.save
#		enrollment
#	end

end
