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
#	attributes = %w( enrollment_id occurred_at description notes )
#	required   = %w( enrollment_id )
#	attributes = %w( study_subject_id project_id occurred_at description notes )
	attributes = %w( occurred_at description notes )
#	required   = %w( study_subject_id project_id )	#	TODO try to figure this out
#	assert_should_require( required )
	assert_should_not_require( attributes )	#- required )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )


	assert_should_protect(:study_subject_id, :study_subject)

	assert_requires_complete_date(:occurred_at)
	assert_should_require_attribute_length( :description, :maximum => 250 )
	assert_should_require_attribute_length( :notes, :maximum => 65000 )

	test "operational_event factory should create operational event" do
		assert_difference('OperationalEvent.count',1) {
			operational_event = FactoryGirl.create(:operational_event)
		}
	end

	test "operational_event factory should not create study subject" do
		assert_difference('StudySubject.count',0) {
			operational_event = FactoryGirl.create(:operational_event)
			assert_nil operational_event.study_subject
		}
	end

	test "operational_event factory should not create project" do
		assert_difference('Project.count',0) {
			operational_event = FactoryGirl.create(:operational_event)
			assert_nil operational_event.project
		}
	end

	test "operational_event factory should not create operational event type" do
		assert_difference('OperationalEventType.count',0) {
			operational_event = FactoryGirl.create(:operational_event)
			assert_nil operational_event.operational_event_type
		}
	end

#	test "should require project" do
#		assert_difference( "OperationalEvent.count", 0 ) do
#			operational_event = create_operational_event( :project => nil)
#			assert !operational_event.errors.include?(:project)
#			assert  operational_event.errors.matching?(:project_id,"can't be blank")
#		end
#	end

	test "should require valid project if given" do
		operational_event = FactoryGirl.build(:operational_event, :project_id => 0)
		assert !operational_event.valid?
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
		operational_event = FactoryGirl.build(:operational_event,:study_subject_id => 0)
		assert !operational_event.valid?
		assert !operational_event.errors.include?(:study_subject_id)
		assert  operational_event.errors.matching?(:study_subject,"can't be blank")
	end

#	test "should require operational_event_type" do
#pending	#	does this test correctly?
##		assert_difference( "OperationalEvent.count", 0 ) do
##			operational_event = create_operational_event( :operational_event_type => nil)
#			operational_event = FactoryGirl.build(:operational_event, :operational_event_type => nil)
#			operational_event.valid?
#			assert !operational_event.errors.include?(:operational_event_type)
#			assert  operational_event.errors.matching?(:operational_event_type_id,"can't be blank")
##		end
#	end

	test "should require valid operational_event_type if given" do
		operational_event = FactoryGirl.build(:operational_event, :operational_event_type_id => 0)
		assert !operational_event.valid?
		assert !operational_event.errors.include?(:operational_event_type_id)
		assert  operational_event.errors.matching?(:operational_event_type,"can't be blank")
	end

	#	description is not required so ...
	test "should return description as to_s if not nil" do
		operational_event = OperationalEvent.new(:description => 'testing')
		assert_equal operational_event.description, 'testing'
		assert_equal operational_event.description, "#{operational_event}"
	end

#	test "should return NOT description as to_s if nil" do
#		operational_event = create_operational_event
#		assert_not_equal operational_event.description, "#{operational_event}"
#	end



#  default_scope :order => 'occurred_at DESC'
#
#	default_scope now mucks this up
#
#	unscoping makes the tests pass, but kinda make the settings idea
#
#	with ActiveRecord::Relation, my 'search' seems pointless

#	type was intended to be a shortcut to operational_event_type.description
#	later perhaps
#	These tests don't really test my code now.
#	Except the valid_order method now.

#	valid_order doesn't work for joins

	test "should order by type ASC" do
		oes = create_oet_operational_events
		events = OperationalEvent.joins(:operational_event_type
			).order('operational_event_types.description asc')
		assert_equal events, [oes[1],oes[0],oes[2]]
	end

	test "should order by type DESC" do
		oes = create_oet_operational_events
		events = OperationalEvent.joins(:operational_event_type
			).order('operational_event_types.description desc')
		assert_equal events, [oes[2],oes[0],oes[1]]
	end

	test "should order by type and ASC as default dir" do
		oes = create_oet_operational_events
		events = OperationalEvent.joins(:operational_event_type
			).order('operational_event_types.description')
		assert_equal events, [oes[1],oes[0],oes[2]]
	end

	test "should order by description ASC" do
		oes = create_description_operational_events
		events = OperationalEvent.valid_order('description asc')
		assert_equal events, [oes[1],oes[0],oes[2]]
	end

	test "should order by description DESC" do
		oes = create_description_operational_events
		events = OperationalEvent.valid_order('description desc')
		assert_equal events, [oes[2],oes[0],oes[1]]
	end

	test "should order by description and ASC as default dir" do
		oes = create_description_operational_events
		events = OperationalEvent.valid_order('description')
		assert_equal events, [oes[1],oes[0],oes[2]]
	end

	test "should order by occurred_at ASC" do
		oes = create_occurred_at_operational_events
		events = OperationalEvent.valid_order('occurred_at asc')
		assert_equal events, [oes[1],oes[0],oes[2]]
	end

	test "should order by occurred_at DESC" do
		oes = create_occurred_at_operational_events
		events = OperationalEvent.valid_order('occurred_at desc')
		assert_equal events, [oes[2],oes[0],oes[1]]
	end

	test "should order by occurred_at and ASC as default dir" do
		oes = create_occurred_at_operational_events
		events = OperationalEvent.valid_order('occurred_at')
		assert_equal events, [oes[1],oes[0],oes[2]]
	end

	test "should ignore invalid order" do
		oes = create_occurred_at_operational_events
		events = OperationalEvent.valid_order('iambogus')
		assert_equal events, [oes[0],oes[1],oes[2]]
	end

	test "should ignore invalid dir" do
		oes = create_occurred_at_operational_events
		events = OperationalEvent.valid_order('occurred_at iambogus')
		assert_equal events, [oes[0],oes[1],oes[2]]
	end

	test "should ignore valid dir without order" do
		oes = create_occurred_at_operational_events
		events = OperationalEvent.valid_order('ASC')
		assert_equal events, [oes[0],oes[1],oes[2]]
	end

#	test "should copy operational event type description on create" do
#		operational_event = create_operational_event
#		assert_equal operational_event.reload.description, 
#			operational_event.operational_event_type.description
#	end
#
#	test "should only include operational events for study_subject" do
#		enrollment = FactoryGirl.create(:enrollment)
#		operational_event_1 = create_operational_event
#		operational_event_2 = create_operational_event(
#			:enrollment => enrollment )
#		events = OperationalEvent.unscoped.search(:study_subject_id => enrollment.study_subject.id)
#		#	enrollment creates subject with auto-created ccls enrollment
#		assert_equal 2, events.length
#		assert events.include? operational_event_2
#	end


	test "should flag study subject for reindexed on create" do
		study_subject = FactoryGirl.create(:study_subject)
		operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject)
		assert_not_nil operational_event.study_subject
		assert  operational_event.study_subject.needs_reindexed
	end

	test "should flag study subject for reindexed on update" do
		study_subject = FactoryGirl.create(:study_subject)
		operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject)
		assert_not_nil operational_event.study_subject
		assert  study_subject.needs_reindexed
		study_subject.update_column(:needs_reindexed, false)
		assert !study_subject.reload.needs_reindexed
		operational_event.update_attributes(:notes => "something to make it dirty")
		assert  study_subject.reload.needs_reindexed
	end

protected

	def create_operational_events(*args)
		args.collect{|options| create_operational_event(options) }
	end

	def create_occurred_at_operational_events
#		today = Date.current
		today = DateTime.current
		create_operational_events(
			{ :occurred_at => ( today - 1.month ) },
			{ :occurred_at => ( today - 1.year ) },
			{ :occurred_at => ( today - 1.week ) }
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
			{ :operational_event_type => FactoryGirl.create(
				:operational_event_type,:description => 'MMMM') },
			{ :operational_event_type => FactoryGirl.create(
				:operational_event_type,:description => 'AAAA') },
			{ :operational_event_type => FactoryGirl.create(
				:operational_event_type,:description => 'ZZZZ') }
		)
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_operational_event

end
