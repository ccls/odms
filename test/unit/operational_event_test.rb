require 'test_helper'

class OperationalEventTest < ActiveSupport::TestCase

#
#	NOTE An Operational Event currently has minimal requirments.
#		If Study Subject or Project are added requirements,
#		there will be many callbacks that need incorporated
#		all throughout the apps tests.
#

	assert_should_create_default_object
#	assert_should_initially_belong_to(:study_subject,:project)
#	assert_should_initially_belong_to(:operational_event_type)
	assert_should_belong_to(:study_subject,:project,:operational_event_type)

#	TODO counts incorrect in tests due to callbacks
#	attributes = %w( enrollment_id occurred_on description event_notes )
#	required   = %w( enrollment_id )
#	attributes = %w( study_subject_id project_id occurred_on description event_notes )
	attributes = %w( occurred_on description event_notes )
#	required   = %w( study_subject_id project_id )	#	TODO try to figure this out
#	assert_should_require( required )
	assert_should_not_require( attributes )	#- required )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )


	assert_should_protect(:study_subject_id, :study_subject)

	assert_requires_complete_date(:occurred_on)
	assert_should_require_attribute_length( :description, :maximum => 250 )
	assert_should_require_attribute_length( :event_notes, :maximum => 65000 )

	test "explicit Factory operational_event test" do
		assert_difference('OperationalEventType.count',0) {
		assert_difference('Project.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_difference('OperationalEvent.count',1) {
			operational_event = Factory(:operational_event)
			assert_nil operational_event.study_subject
			assert_nil operational_event.project
			assert_nil operational_event.operational_event_type
		} } } }
	end

#	test "should require project" do
#		assert_difference( "OperationalEvent.count", 0 ) do
#			operational_event = create_operational_event( :project => nil)
#			assert !operational_event.errors.include?(:project)
#			assert  operational_event.errors.matching?(:project_id,"can't be blank")
#		end
#	end

	test "should require valid project if given" do
		operational_event = Factory.build(:operational_event, :project_id => 0)
		operational_event.valid?
		assert !operational_event.errors.include?(:project_id)
		assert  operational_event.errors.matching?(:project,"can't be blank")
	end

#	test "should require study_subject" do
#		assert_difference( "OperationalEvent.count", 0 ) do
#			operational_event = create_operational_event( :study_subject => nil)
#			assert !operational_event.errors.include?(:study_subject)
#			assert  operational_event.errors.matching?(:study_subject_id,"can't be blank")
#		end
#	end

	test "should require valid study_subject if given" do
		operational_event = Factory.build(:operational_event,:study_subject_id => 0)
		operational_event.valid?
		assert !operational_event.errors.include?(:study_subject_id)
		assert  operational_event.errors.matching?(:study_subject,"can't be blank")
	end

#	test "should require operational_event_type" do
#pending	#	does this test correctly?
##		assert_difference( "OperationalEvent.count", 0 ) do
##			operational_event = create_operational_event( :operational_event_type => nil)
#			operational_event = Factory.build(:operational_event, :operational_event_type => nil)
#			operational_event.valid?
#			assert !operational_event.errors.include?(:operational_event_type)
#			assert  operational_event.errors.matching?(:operational_event_type_id,"can't be blank")
##		end
#	end

	test "should require valid operational_event_type if given" do
		operational_event = Factory.build(:operational_event, :operational_event_type_id => 0)
		operational_event.valid?
		assert !operational_event.errors.include?(:operational_event_type_id)
		assert  operational_event.errors.matching?(:operational_event_type,"can't be blank")
	end

	#	description is not required so ...
	test "should return description as to_s if not nil" do
		operational_event = create_operational_event(:description => 'testing')
		assert_equal operational_event.description, "#{operational_event}"
	end

#	test "should return NOT description as to_s if nil" do
#		operational_event = create_operational_event
#		assert_not_equal operational_event.description, "#{operational_event}"
#	end



#  default_scope :order => 'occurred_on DESC'
#
#	default_scope now mucks this up
#
#	unscoping makes the tests pass, but kinda make the settings idea
#
#
#	test "should order by type ASC" do
#		oes = create_oet_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'type',:dir => 'asc')
#		assert_equal events, [oes[1],oes[0],oes[2]]
#	end
#
#	test "should order by type DESC" do
#		oes = create_oet_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'type',:dir => 'desc')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should order by type and DESC as default dir" do
#		oes = create_oet_operational_events
#		events = OperationalEvent.search(:order => 'type')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should order by description ASC" do
#		oes = create_description_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'description',:dir => 'asc')
#		assert_equal events, [oes[1],oes[0],oes[2]]
#	end
#
#	test "should order by description DESC" do
#		oes = create_description_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'description',:dir => 'desc')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should order by description and DESC as default dir" do
#		oes = create_description_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'description')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should order by occurred_on ASC" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'occurred_on',:dir => 'asc')
#		assert_equal events, [oes[1],oes[0],oes[2]]
#	end
#
#	test "should order by occurred_on DESC" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'occurred_on',:dir => 'desc')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should order by occurred_on and DESC as default dir" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'occurred_on')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should order by occurred_on DESC as defaults" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.search()
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should ignore invalid order" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.search(:order => 'iambogus')	#	don't unscope
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should ignore invalid dir" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.unscoped.search(:order => 'occurred_on',
#			:dir => 'iambogus')
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should ignore valid dir without order" do
#		oes = create_occurred_on_operational_events
#		events = OperationalEvent.search(:dir => 'ASC')	#	don't unscope
#		assert_equal events, [oes[2],oes[0],oes[1]]
#	end
#
#	test "should copy operational event type description on create" do
#		operational_event = create_operational_event
#		assert_equal operational_event.reload.description, 
#			operational_event.operational_event_type.description
#	end
#
#	test "should only include operational events for study_subject" do
#		enrollment = Factory(:enrollment)
#		operational_event_1 = create_operational_event
#		operational_event_2 = create_operational_event(
#			:enrollment => enrollment )
#		events = OperationalEvent.unscoped.search(:study_subject_id => enrollment.study_subject.id)
#		#	enrollment creates subject with auto-created ccls enrollment
#		assert_equal 2, events.length
#		assert events.include? operational_event_2
#	end

protected

#	def create_operational_event(options={})
#		operational_event = Factory.build(:operational_event,options)
#		operational_event.save
#		operational_event
#	end

	def create_operational_events(*args)
		args.collect{|options| create_operational_event(options) }
	end

	def create_occurred_on_operational_events
		today = Date.today
		create_operational_events(
			{ :occurred_on => ( today - 1.month ) },
			{ :occurred_on => ( today - 1.year ) },
			{ :occurred_on => ( today - 1.week ) }
		)
	end

	def create_description_operational_events
		create_operational_events(
			{ :description => 'M' },
			{ :description => 'A' },
			{ :description => 'Z' }
		)
	end

	def create_oet_operational_events
		create_operational_events(
			{ :operational_event_type => Factory(
				:operational_event_type,:description => 'MMMM') },
			{ :operational_event_type => Factory(
				:operational_event_type,:description => 'AAAA') },
			{ :operational_event_type => Factory(
				:operational_event_type,:description => 'ZZZZ') }
		)
	end

end
