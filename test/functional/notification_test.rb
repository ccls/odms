require 'test_helper'

class NotificationTest < ActionMailer::TestCase

	test "raf_submitted for subject" do
		study_subject = Factory(:complete_case_study_subject, 
			:first_name    => 'Anthony',
			:middle_name   => 'Michael',
			:last_name     => 'Hall',
			:icf_master_id => '1234MAIL')
		mail = Notification.raf_submitted(study_subject)
		assert_equal mail.subject,
			"TEST [CCLS Patient Notification Received] Identifier: 1234MAIL"
		assert_equal ["magee@berkeley.edu"], mail.to
		assert_equal ["notifyccls@berkeley.edu"], mail.from
		assert_equal ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"], mail.cc
		assert_match '1234MAIL', mail.body.encoded
		assert_match 'initials: AMH', mail.body.encoded
	end

end
__END__
Hello~ 


As the factory uses a bit of randomness, this may occassionally be empty
BEGIN TEMP FYI:
Org ID:2:
Org:Children's Hospital Central California:
Hospital:Children's Hospital Central California:
Contact ID:45:
Contact:Katy Robinson:
Email:krobinson@childrenscentralcal.org:
END TEMP FYI:




Thank you for enrolling your patient in the California Childhood Leukemia Study at UC Berkeley.  We have assigned your patient (initials: AMH) the following CCLS Patient Identifier:  

1234MAIL

Please use this ID number for labeling all biological samples and paperwork (i.e. RAF, consent, CBC report) to be returned to the CCLS office and for all future correspondence regarding this patient.

Thank you, 
The CCLS Research Team 

