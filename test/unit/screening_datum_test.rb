require 'test_helper'

class ScreeningDatumTest < ActiveSupport::TestCase
#
#	assert_should_create_default_object
#
#	assert_should_belong_to( :study_subject )
#	assert_should_belong_to( :screening_datum_update )
#
#	test "screening_datum factory should create odms exception for blank icf_master_id" do
#		screening_datum = Factory(:screening_datum)
#		assert_equal 1,
#			screening_datum.odms_exceptions.length
#		assert_equal 'screening data append',
#			screening_datum.odms_exceptions.first.name
#		assert_match /icf_master_id blank/,
#			screening_datum.odms_exceptions.first.to_s
#	end
#
#	test "screening_datum factory should create odms exception for unused icf_master_id" do
#		screening_datum = Factory(:screening_datum,:icf_master_id => 'IAMUNUSED')
#		assert_equal 1,
#			screening_datum.odms_exceptions.length
#		assert_equal 'screening data append',
#			screening_datum.odms_exceptions.first.name
#		assert_match /No subject found with icf_master_id :IAMUNUSED:/,
#			screening_datum.odms_exceptions.first.to_s
#	end
#
#	test "screening_datum factory should create screening datum" do
#		screening_datum = Factory(:screening_datum)
#		assert !screening_datum.new_record?
#	end
#
#	test "screening_datum factory should have dob" do
#		screening_datum = Factory(:screening_datum)
#		assert_not_nil screening_datum.dob
#	end
#
#	test "screening_datum factory should have sex" do
#		screening_datum = Factory(:screening_datum)
#		assert_not_nil screening_datum.sex
#	end
#
#	test "screening_datum factory should not have first name" do
#		screening_datum = Factory(:screening_datum)
#		assert_nil screening_datum.first_name
#	end
#
#	test "screening_datum factory should not have last name" do
#		screening_datum = Factory(:screening_datum)
#		assert_nil screening_datum.last_name
#	end
#
#	#	these are just simple strings so all the same
#	%w( first_name middle_name last_name 
#		mother_first_name mother_last_name mother_maiden_name
#		father_first_name father_last_name ).each do |field|
#
#		test "should update subject's #{field} if blank" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{field => ''}, {"new_#{field}" => 'some-name'})
#			study_subject.reload
#			assert_equal 'Some-Name', study_subject.send(field) #	namerized
#		end
#
#		test "should update subject's #{field} if different" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{field => 'Somename'}, {"new_#{field}" => "o'someothername"})
#			study_subject.reload
#			assert_equal "O'Someothername", study_subject.send(field)	#	namerized
#		end
#
#		test "should NOT create operational event if #{field} is the same" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{field => 'Somename'}, {"new_#{field}" => "Somename"})
#			study_subject.reload
#			oes = study_subject.operational_events.where(
#				:project_id                => Project['ccls'].id).where(
#				:operational_event_type_id => OperationalEventType['datachanged'].id 
#				)
#			assert_equal 0, oes.length
#		end
#
#		test "should create operational event if #{field} is different" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{field => 'Somename'}, {"new_#{field}" => "o'someothername"})
#			study_subject.reload
#			oes = study_subject.operational_events.where(
#				:project_id                => Project['ccls'].id).where(
#				:operational_event_type_id => OperationalEventType['datachanged'].id 
#				)
#			assert_equal 1, oes.length
#			assert_match /ICF Screening data change:  The value in #{field} has changed from "Somename" to "O'Someothername"/, oes.first.description
#		end
#
#	end
#
##	test "should update subject's dob if is blank" do
##	dob is required by study subject, so will never be blank
##		study_subject, screening_datum = create_study_subject_and_screening_datum(
##			{field => ''}, {"new_#{field}" => 'some-name'})
##		study_subject.reload
##		assert_equal 'Some-Name', study_subject.send(field) #	namerized
##	end
#
#	test "should update subject's dob if new_dob is different" do
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:dob => (Date.today-1.year)}, {:new_dob => (Date.today-2.years)})
#		study_subject.reload
#		assert_equal (Date.today-2.years), study_subject.dob
#	end
#
#	test "should NOT create operational event if new_dob is the same" do
#		dob = Date.today-1.year
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:dob => dob}, {:new_dob => dob})
#		study_subject.reload
#		oes = study_subject.operational_events.where(
#			:project_id                => Project['ccls'].id).where(
#			:operational_event_type_id => OperationalEventType['datachanged'].id 
#			)
#		assert_equal 0, oes.length
#	end
#
#	test "should create operational event if new_dob is different" do
#		dob = Date.today-1.year
#		new_dob = Date.today-2.year
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:dob => dob }, {:new_dob => new_dob})
#		study_subject.reload
#		oes = study_subject.operational_events.where(
#			:project_id                => Project['ccls'].id).where(
#			:operational_event_type_id => OperationalEventType['datachanged'].id 
#			)
#		assert_equal 1, oes.length
#		assert_match /ICF Screening data change:  The value in dob has changed from "#{dob}" to "#{new_dob}"/, oes.first.description
#	end
#
##	test "should update subject's sex if is blank" do
##	sex is required by study subject, so will never be blank
##		study_subject, screening_datum = create_study_subject_and_screening_datum(
##			{field => ''}, {"new_#{field}" => 'some-name'})
##		study_subject.reload
##		assert_equal 'Some-Name', study_subject.send(field) #	namerized
##	end
#
#	test "should update subject's sex if new_sex is different - DK" do
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:sex => 'M'},{:new_sex => '  dk  '})
#		study_subject.reload
#		assert_equal 'DK', study_subject.sex
#	end
#
#	test "should update subject's sex if new_sex is different - F" do
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:sex => 'M'},{:new_sex => '  f  '})
#		study_subject.reload
#		assert_equal 'F', study_subject.sex
#	end
#
#	test "should NOT create operational event if new_sex is the same" do
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:sex => 'M'},{:new_sex => '  m  '})
#		study_subject.reload
#		oes = study_subject.operational_events.where(
#			:project_id                => Project['ccls'].id).where(
#			:operational_event_type_id => OperationalEventType['datachanged'].id 
#			)
#		assert_equal 0, oes.length
#	end
#
#	test "should create operational event if new_sex is different" do
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{:sex => 'M'},{:new_sex => '  f  '})
#		study_subject.reload
#		oes = study_subject.operational_events.where(
#			:project_id                => Project['ccls'].id).where(
#			:operational_event_type_id => OperationalEventType['datachanged'].id 
#			)
#		assert_equal 1, oes.length
#		assert_match /ICF Screening data change:  The value in sex has changed from "M" to "F"/, oes.first.description
#	end
#
#	test "should create screening complete operational event for subject" do
#		date = Date.today - 10.days	#	arbitrary past date
#		study_subject, screening_datum = create_study_subject_and_screening_datum(
#			{},{:date => date })
#		study_subject.reload
#		oes = study_subject.operational_events.where(
#			:project_id                => Project['ccls'].id).where(
#			:operational_event_type_id => OperationalEventType['screener_complete'].id 
#			)
#		assert_equal 1, oes.length
#		assert_equal "ICF screening complete", oes.first.description
#		assert_equal date.to_time_in_current_zone, oes.first.occurred_at
#	end
#
#	%w( mother_race father_race ).each do |field|
#
#		test "should set subject #{field} if valid" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{},{ field => Race['white'].id })	#	white is arbitrary
#			assert_nil study_subject.send("#{field}_id")
#			study_subject.reload
#			assert_equal Race['white'].id, study_subject.send("#{field}_id")
#		end
#
#		test "should not set subject #{field} if invalid" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{},{ field => 0 })	#	0 is an non-existant race
#			assert_nil study_subject.send("#{field}_id")
#			study_subject.reload
#			assert_nil study_subject.send("#{field}_id")
#		end
#
#		test "should create operational event if #{field} invalid" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{},{ field => 0 })	#	0 is an non-existant race
#			study_subject.reload
#			oes = study_subject.operational_events.where(
#				:project_id                => Project['ccls'].id).where(
#				:operational_event_type_id => OperationalEventType['dataconflict'].id 
#				)
#			assert_equal 1, oes.length
#			assert_match /ICF screening data conflict:.*#{field} does not match CCLS designations.    Value = 0/, oes.first.description
#		end
#
#	end
#
##mother_hispanicity	identify the correct mother_hispanicity from the value provided.  If no value matches, add operational event:  oe_type_id=30 (dataconflict), occurred_at=now, description:  "ICF screening data conflict:  mother's hispanicity does not match CCLS designations.    Value = "[value from file]"
##father_hispanicity	identify the correct father_hispanicity from the value provided.  If no value matches, add operational event:  oe_type_id=30 (dataconflict), occurred_at=now, description:  "ICF screening data conflict:  father's hispanicity does not match CCLS designations.    Value = [value from file]
#	%w( mother_hispanicity father_hispanicity ).each do |field|
#
#		test "should set subject #{field} if valid" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{},{ field => 123 })	#	123 is arbitrary
#			assert_nil study_subject.send("#{field}_id")
#			study_subject.reload
#			assert_equal 123, study_subject.send("#{field}_id")
#		end
#
#		test "should not set subject #{field} if invalid" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{},{ field => 0 })	#	0 is an non-existant hispanicity ???
#			assert_nil study_subject.send("#{field}_id")
#			study_subject.reload
#			assert_nil study_subject.send("#{field}_id")
#		end
##
## mother_hispanicity father_hispanicity	( we currently have no hispanicity designations )
##
#		test "should create operational event if #{field} invalid" do
#			study_subject, screening_datum = create_study_subject_and_screening_datum(
#				{},{ field => 0 })	#	0 is an non-existant hispanicity ???
#			study_subject.reload
#			oes = study_subject.operational_events.where(
#				:project_id                => Project['ccls'].id).where(
#				:operational_event_type_id => OperationalEventType['dataconflict'].id 
#				)
#			assert_equal 1, oes.length
#			assert_match /ICF screening data conflict:.*#{field} does not match CCLS designations.    Value = 0/, oes.first.description
#		end
#
#	end
#
#	test "update_study_subject_attributes should also run if" <<
#			" subject not yet assigned" do
#		screening_datum = Factory(:screening_datum,
#			:icf_master_id    => '12345678A' )
#		assert_nil screening_datum.reload.study_subject
#		study_subject = Factory(:study_subject,
#			:icf_master_id => '12345678A' )
#		screening_datum.update_study_subject_attributes
#		assert_not_nil screening_datum.reload.study_subject
#		assert_equal study_subject, screening_datum.study_subject
#	end
#
#protected
#
#	def create_study_subject_and_screening_datum(
#			subject_options={},screening_datum_options={})
#		study_subject = create_study_subject_with_icf_master_id(subject_options)
#		screening_datum = create_matching_screening_datum(
#			study_subject,screening_datum_options)
#		return study_subject, screening_datum
#	end
#
#	def create_matching_screening_datum(study_subject,options={})
#		screening_datum = Factory(:screening_datum,{
#			:sex => study_subject.sex,
#			:dob => study_subject.dob,
#			:icf_master_id => study_subject.icf_master_id }.merge(options) )
#	end
#
#	def create_study_subject_with_icf_master_id(options={})
#		study_subject = Factory(:study_subject,{
#			:icf_master_id => '12345678A' }.merge(options))
#		check_icf_master_id(study_subject)
#	end
#
#	def check_icf_master_id(study_subject)
#		assert_not_nil study_subject.icf_master_id
#		assert_equal '12345678A', study_subject.icf_master_id
#		study_subject
#	end
#
#	#	create_object is called from within the common class tests
#	alias_method :create_object, :create_screening_datum
#
end
__END__
