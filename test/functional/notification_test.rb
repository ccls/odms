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
#		assert_equal ["magee@berkeley.edu"], mail.to
		assert_equal ["notifyccls@berkeley.edu"], mail.to
		assert_equal ["notifyccls@berkeley.edu"], mail.from
		assert_equal ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"], mail.cc
		assert_match '1234MAIL', mail.body.encoded
		assert_match 'initials: AMH', mail.body.encoded
	end

	test "demo" do
		mail = Notification.demo
		assert_equal mail.to,     ["jakewendt@berkeley.edu"]
		assert_equal mail.subject, "TEST EMAIL"
		assert_match "This is a demo email to test the production server.",
			mail.body.encoded
	end

	test "plain" do
		mail = Notification.plain
		assert_equal mail.to,     ["jakewendt@berkeley.edu"]
		assert_equal mail.subject, "No subject given"
		assert_match "No body given", mail.body.encoded
#	html or text.  Both exist for this one.
#  <"\r\n\r\n----==_mimepart_50cbaca246541_ba908044394828669\r\nDate: Fri, 14 Dec 2012 14:48:02 -0800\r\nMime-Version: 1.0\r\nContent-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\nContent-ID: <50cbaca24b85b_ba90804439482876d@fxdgroup-169-229-196-225.sph.berkeley.edu.mail>\r\n\r\nNo body given\r\n\r\n\r\n----==_mimepart_50cbaca246541_ba908044394828669\r\nDate: Fri, 14 Dec 2012 14:48:02 -0800\r\nMime-Version: 1.0\r\nContent-Type: text/html;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\nContent-ID: <50cbaca24e377_ba908044394828884@fxdgroup-169-229-196-225.sph.berkeley.edu.mail>\r\n\r\n<html>\r\n<head>\r\n</head>\r\n<body>\r\nNo body given\r\n</body>\r\n</html>\r\n\r\n\r\n----==_mimepart_50cbaca246541_ba908044394828669--\r\n">
	end

	test "updates_from_icf_master_tracker" do
		mail = Notification.updates_from_icf_master_tracker([])
		assert_equal mail.to,     ["jakewendt@berkeley.edu"]
		assert_equal mail.subject, "Notification.updates_from_icf_master_tracker"
		assert_match "No changes", mail.body.encoded
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

