require 'integration_test_helper'

class AddressingIntegrationTest < ActionController::WebRatIntegrationTest

	site_administrators.each do |cu|

		test "should edit addressing javascript test with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)

			visit new_study_subject_addressing_path(study_subject)

#			assert_have_no_selector 'form input#name'

#			fill_in 'addressing_address_attributes_zip', :with => '17857'
			fill_in 'addressing[address_attributes][zip]', :with => '17857'

#	puts response.body	#	doesn't show the currently filled in value
#			just wondering whether or not I can test the ajax call here, but I doubt

#	I'd like to confirm the the data was filled in, but how?
#	Can I check if the ajax call was triggered?
#	Can I check its response?
#	Can I check if it modified anything?
#	I don't think so.
#	There are a few javascript testers like selenium or jasmine

		end

	end

end
