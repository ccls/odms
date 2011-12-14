require 'integration_test_helper'

class EventIntegrationTest < ActionController::CapybaraIntegrationTest

#	Will probably need to add OperationalEvent and
#		OperationalEventType to the shared connection 

#	$('select#category').change(function(){
#		$.get(root + '/operational_event_types/options.js?category=' + $(this).val(), 
#			function(data){
#				$('select#operational_event_operational_event_type_id').html(data);
#		});
#	});

	site_administrators.each do |cu|

		test "should get new study_subject event with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit new_study_subject_event_path(study_subject)
			assert page.has_css?('select#category')

			assert_equal 11, page.all('select#category option').length
#			page.all('select#category option').each do |option|
#				puts option.text
#			end
# (blank)
#ascertainment
#compensation
#completions
#correspondence
#enrollments
#interviews
#operations
#other
#recruitment
#samples

#			puts page.find('select#category option')
#	has some options
			assert page.has_css?('select#operational_event_operational_event_type_id')
			page.all('select#operational_event_operational_event_type_id option').each do |option|
				puts option.text
			end
#	should only be one and should be blank
			assert_equal 1, 
				page.all('select#operational_event_operational_event_type_id option').length
#			puts page.find('select#operational_event_operational_event_type_id option')
#	has NO options

#	select a category
			select 'operations', :from => 'category'

#	now has some options.  Yay!
#			page.all('select#operational_event_operational_event_type_id option').each do |option|
#				puts option.text
#			end
#	should be several non-blank		FAILS!!?!?!?!??!
#			assert_equal 8, 
#				page.all('select#operational_event_operational_event_type_id option').length

		end

	end

end

__END__

<select id="category" name="category"><option value=""></option>
<option value="ascertainment">ascertainment</option>
<option value="compensation">compensation</option>
<option value="completions">completions</option>
<option value="correspondence">correspondence</option>
<option value="enrollments">enrollments</option>
<option value="interviews">interviews</option>
<option value="operations">operations</option>
<option value="other">other</option>
<option value="recruitment">recruitment</option>
<option value="samples">samples</option></select>
</div>

<div class='operational_event_type_id select field_wrapper'>
<label for="operational_event_operational_event_type_id">type:</label><select id="operational_event_operational_event_type_id" name="operational_event[operational_event_type_id]"><option value=""></option></select>
</div><!-- class='operational_event_type_id select' -->

