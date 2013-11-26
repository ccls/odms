#
#	I'm here to allow for the adding to test helper
#	without autotest restarting all of your tests.
#


#require 'screening_datum_update_test_helper'


class ActiveSupport::TestCase

	def illegal_csv_quote_line
		"test\""
	end

	def unclosed_csv_quote_line
		",\","
	end

	def stray_csv_quote_line
		"\"asdf\"a,"
	end

	#	I don't think that the actual name really matters.
	#	It just needs to be consistent
	def csv_test_file_name
		"tmp/#{self.class.name.underscore}.csv"
	end

	def create_stray_quote_csv_file
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts stray_csv_quote_line }
	end

	def create_unclosed_quote_csv_file
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts unclosed_csv_quote_line }
	end

	def create_illegal_quote_csv_file
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts illegal_csv_quote_line }
	end


#
#	would this work for backward compatibility
#
#	Factory = FactoryGirl
	def Factory(*args)
		FactoryGirl.create(*args)
	end

#	This would probably work, but would require I change everything!
#	def with_login_as( user=nil, &block )
#		login_as user
#		yield
#		CASClient::Frameworks::Rails::Filter.unstub(:filter)
#	end

##	teardown :unstub_stuff
#	def unstub_stuff
##Mocha.reset_mocha
##		#	wonder if I can 
##		#	Mocha.each_stub { |stub| stub.unstub } 
##		#	or something rather than having to put them all here
##
##		#	I'm not supposed to need to unstub, but I've found with the upgrade 
##		#	of mocha from 0.13.3 to 0.14.0, the stubs don't go away.
##		#	At least the stubbing of filter doesn't and then I'm always
##		#	logged in so my 'not logged in' tests fail.
#		CASClient::Frameworks::Rails::Filter.unstub(:filter)
#		UCB::LDAP::Person.unstub(:find_by_uid)
#		UCB::LDAP::Schema.unstub(:load_attributes_from_url)
##		#	same with Abstract.any_instance.stubs(:valid?)
##		#	and Abstract.any_instance.stubs(:create_or_update)
##		#	once stubbed, all abstract creation fails.
#
#
##	this is gonna be problematic because of the @@ tests
##	may have to loop through every AR model
##	this is just stupid. really f'n stupid.
#
##	may just go back to mocha 0.13.3
#
#
#		IcfMasterId.any_instance.unstub(:save!)
#		Abstract.any_instance.unstub(:valid?)
#		Abstract.any_instance.unstub(:create_or_update)
#		Address.any_instance.unstub(:valid?)
#		Address.any_instance.unstub(:create_or_update)
#		BcRequest.any_instance.unstub(:valid?)
#		BcRequest.any_instance.unstub(:create_or_update)
#		CandidateControl.any_instance.unstub(:valid?)
#		CandidateControl.any_instance.unstub(:create_or_update)
#		Enrollment.any_instance.unstub(:valid?)
#		Enrollment.any_instance.unstub(:create_or_update)
#		OperationalEvent.any_instance.unstub(:valid?)
#		OperationalEvent.any_instance.unstub(:create_or_update)
#		Patient.any_instance.unstub(:valid?)
#		Patient.any_instance.unstub(:create_or_update)
#		PhoneNumber.any_instance.unstub(:valid?)
#		PhoneNumber.any_instance.unstub(:create_or_update)
#		Sample.unstub(:search)
#		Sample.unstub(:methods)
#		Sample.any_instance.unstub(:valid?)
#		Sample.any_instance.unstub(:create_or_update)
#		SampleTransfer.any_instance.unstub(:valid?)
#		SampleTransfer.any_instance.unstub(:create_or_update)
#		StudySubject.unstub(:search)
#		StudySubject.unstub(:methods)
#		StudySubject.any_instance.unstub(:valid?)
#		StudySubject.any_instance.unstub(:create_or_update)
#		StudySubject.any_instance.unstub(:get_next_patid)
#		StudySubject.any_instance.unstub(:get_next_childid)
#		StudySubject.any_instance.unstub(:generate_subjectid)
#		StudySubject.any_instance.unstub(:create_mother)
#		StudySubject.any_instance.unstub(:assign_icf_master_id)
#		IneligibleReason.unstub(:count)
#		InstrumentVersion.unstub(:count)
#		InterviewMethod.unstub(:count)
#		Language.unstub(:count)
#		Person.unstub(:count)
#		SubjectRelationship.unstub(:count)
#		RefusalReason.unstub(:count)
#
##	this one needs to be local
##		ApplicationHelperTest.any_instance.unstub(:sort_up_image)
##		ApplicationHelperTest.any_instance.unstub(:sort_down_image)
#	end

end
