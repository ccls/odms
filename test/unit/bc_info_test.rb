require 'test_helper'

class BcInfoTest < ActiveSupport::TestCase

	test "should send blank icf master id notification if icf master id is blank" do
		bc_info = BcInfo.new(:bc_info_file => "somefile.csv")
		bc_info.process
		mail = ActionMailer::Base.deliveries.detect{|m|
			m.subject.match(/Blank ICF Master ID/) }
		assert mail.to.include?('jakewendt@berkeley.edu')
		assert_match 'contained line with blank icf_master_id', mail.body.encoded
	end

	test "should NOT send blank icf master id notification if icf master id is NOT blank" do
		bc_info = BcInfo.new(:icf_master_id => "I'm not blank!")	#	but doesn't exist
		bc_info.process
		mail = ActionMailer::Base.deliveries.detect{|m|
			m.subject.match(/Blank ICF Master ID/) }
		assert_nil mail
	end

	test "should set icf_master_id to given masterid if icf_master_id blank" do
		bc_info = BcInfo.new(:masterid => "0123")
		assert_equal "0123", bc_info.icf_master_id
	end

	test "should NOT set icf_master_id to given masterid if icf_master_id given" do
		bc_info = BcInfo.new(:icf_master_id => "0123", :masterid => "4567")
		assert_equal "0123", bc_info.icf_master_id
	end
	
	test "should send no matching subject notification if icf master id isn't used" do
		bc_info = BcInfo.new(:icf_master_id => "IDONOTEXIST")
		bc_info.process
		mail = ActionMailer::Base.deliveries.detect{|m|
			m.subject.match(/No Subject with ICF Master ID/) }
		assert mail.to.include?('jakewendt@berkeley.edu')
		assert_match 'contained line with icf_master_id but no subject with icf_master_id',
			mail.body.encoded
	end

	test "should set study_subject if given icf_master_id is used" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
		bc_info.process
		assert_not_nil bc_info.study_subject
		assert_equal   bc_info.study_subject, study_subject
	end

#
#	hispanicity computation will pretty much guarantee that the
#		changes hash will never be empty
#

#	test "should set changes to empty hash if no changes" do
#		Factory(:study_subject, :icf_master_id => "IDOEXIST")
#		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
#		bc_info.process
#		assert bc_info.changes.empty?
#	end

	#	string fields are squished and namerized
	{ 
		:new_mother_first_name  => :mother_first_name,
		:new_mother_first       => :mother_first_name,
		:new_mother_last_name   => :mother_last_name,
		:new_mother_last        => :mother_last_name,
		:new_mother_maiden_name => :mother_maiden_name,
		:new_mother_maiden      => :mother_maiden_name,
		:new_father_first_name  => :father_first_name,
		:new_father_first       => :father_first_name,
		:new_father_last_name   => :father_last_name,
		:new_father_last        => :father_last_name,
		:new_first_name         => :first_name,
		:new_child_first        => :first_name,
		:new_last_name          => :last_name,
		:new_child_last         => :last_name,
		:new_middle_name        => :middle_name,
		:new_child_middle       => :middle_name,
		:birth_city             => :birth_city,
		:other_mother_race      => :other_mother_race,
		:mother_race_other      => :other_mother_race,
		:other_father_race      => :other_father_race,
		:father_race_other      => :other_father_race,
	}.each do |k,v|

		test "should update #{v} with corrected #{k}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST",
				v => "OldValue")
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
				k => "  NEWVALUE  ")
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal "Newvalue", study_subject.reload.send(v)
		end

	end

	{
		:birth_state   => :birth_state,
		:birth_country => :birth_country
	}.each do |k,v|

		test "should update #{k} with squished #{v}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST",
				v => "OldValue")
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
				k => "  NEWVALUE  ")
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal "NEWVALUE", study_subject.reload.send(v)
		end

	end

	YNRDK.valid_values.each do |ynrdk|
		{
			:mother_hispanicity     => :mother_hispanicity,
			:mother_hispanicity_mex => :mother_hispanicity_mex,
			:father_hispanicity     => :father_hispanicity,
			:father_hispanicity_mex => :father_hispanicity_mex,
			:father_race_code       => :father_race_code,
			:mother_race_code       => :mother_race_code,
			:father_race            => :father_race_code,
			:mother_race            => :mother_race_code
		}.each do |k,v|

			test "should update #{k} with ynrdk #{ynrdk} #{v}" do
				study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
				assert_nil study_subject.send(v)
				bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", k => ynrdk)
				bc_info.process
#				assert !bc_info.changes.empty?
				assert_equal ynrdk, study_subject.reload.send(v)
			end

		end
	end

	%w( new_dob_year dob_year new_child_doby child_doby ).each do |attr|

		test "should update birth_year with #{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
			assert_nil study_subject.birth_year
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", attr => 2000)
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal '2000', study_subject.reload.birth_year
		end

	end

	{
		:biomom        => :mom_is_biomom,
		:mom_is_biomom => :mom_is_biomom,
		:biodad        => :dad_is_biodad,
		:dad_is_biodad => :dad_is_biodad
	}.each do |k,v|

		test "should update #{k} with #{v}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", k => 1)
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal '1', study_subject.reload.send(v).to_s
		end

	end

	%w( new_sex new_child_gender ).each do |attr|

		test "should update sex with #{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST", :sex => 'DK')
			assert_nil study_subject.birth_year
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", attr => 'M')
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal 'M', study_subject.reload.sex
		end

	end

	%w( new_dob new_child_dobfull ).each do |attr|

		test "should update dob with #{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST",
				:dob => Date.parse('Dec 31, 1999'))
			assert_nil study_subject.birth_year
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", 
				attr => 'Dec 31, 1998')
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal Date.parse('Dec 31, 1998'), study_subject.reload.dob
		end

	end

	test "should set create dob from components if they're not blank" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", 
			:new_child_doby => '2000',
			:new_child_dobm => '12',
			:new_child_dobd => '31')
		bc_info.process
		assert_equal Date.parse('12/31/2000'), study_subject.reload.dob
	end

	%w( father_hispanicity mother_hispanicity
			father_hispanicity_mex mother_hispanicity_mex 
			father_race_code mother_race_code
	).each do |attr|

		test "should convert coded value of 0 to 888 for #{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
			assert_nil study_subject.send(attr)
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", 
				attr => '0')
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal '888', study_subject.reload.send(attr).to_s
		end

		test "should convert coded value of 9 to 999 for #{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
			assert_nil study_subject.send(attr)
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", 
				attr => '9')
			bc_info.process
#			assert !bc_info.changes.empty?
			assert_equal '999', study_subject.reload.send(attr).to_s
		end

	end


	test "should set hispanicity to 999 if parent's not given" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
		bc_info.process
		assert_equal '999', study_subject.reload.hispanicity.to_s
	end

	test "should set hispanicity to 999 if parent's don't match and neither are 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:father_hispanicity => 2,
			:mother_hispanicity => 999)
		bc_info.process
		assert_equal '999', study_subject.reload.hispanicity.to_s
	end

	test "should set hispanicity to parent's if match and neither are 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:father_hispanicity => 2,
			:mother_hispanicity => 2)
		bc_info.process
		assert_equal '2', study_subject.reload.hispanicity.to_s
	end

	test "should set hispanicity to 1 if father's is 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:father_hispanicity => 1)
		bc_info.process
		assert_equal '1', study_subject.reload.hispanicity.to_s
	end

	test "should set hispanicity to 1 if mother's is 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:mother_hispanicity => 1)
		bc_info.process
		assert_equal '1', study_subject.reload.hispanicity.to_s
	end

	test "should set hispanicity_mex to 999 if parent's not given" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity_mex
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
		bc_info.process
		assert_equal '999', study_subject.reload.hispanicity_mex.to_s
	end

	test "should set hispanicity_mex to 999 if parent's don't match and neither are 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity_mex
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:father_hispanicity => 2,
			:mother_hispanicity => 999)
		bc_info.process
		assert_equal '999', study_subject.reload.hispanicity_mex.to_s
	end

	test "should set hispanicity_mex to parent's if match and neither are 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity_mex
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:father_hispanicity_mex => 2,
			:mother_hispanicity_mex => 2)
		bc_info.process
		assert_equal '2', study_subject.reload.hispanicity_mex.to_s
	end

	test "should set hispanicity_mex to 1 if father's is 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity_mex
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:father_hispanicity_mex => 1)
		bc_info.process
		assert_equal '1', study_subject.reload.hispanicity_mex.to_s
	end

	test "should set hispanicity_mex to 1 if mother's is 1" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.hispanicity_mex
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:mother_hispanicity_mex => 1)
		bc_info.process
		assert_equal '1', study_subject.reload.hispanicity_mex.to_s
	end

	
#					new_attributes.each do |k,v|
#						#	NOTE always check if attribute is blank as don't want to delete data
#						study_subject.send("#{k}=",v) unless v.blank?
#					end

	test "should not update attribute if new data is blank" do
	end

	test "should create datachanged operational event if data changed" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert study_subject.operational_events.where(
			:operational_event_type_id => OperationalEventType['datachanged'].id).empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:new_middle_name => "TRIGGERCHANGE")
		bc_info.process
#		assert !bc_info.changes.empty?
		dcoes = study_subject.operational_events.where(
			:operational_event_type_id => OperationalEventType['datachanged'].id)
		assert !dcoes.empty?
	end
#
#	hispanicity computation will ensure that almost all records
#	will have changed so this will happen for almost all
#
#	TODO unless set hispanicity initially!
#
	test "should NOT create datachanged operational event if data NOT changed" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST",
			:hispanicity => '999', :hispanicity_mex => '999')
		assert study_subject.operational_events.where(
			:operational_event_type_id => OperationalEventType['datachanged'].id).empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
		bc_info.process
		assert bc_info.changes.empty?	#	no changes
		dcoes = study_subject.reload.operational_events.where(
			:operational_event_type_id => OperationalEventType['datachanged'].id)
		assert dcoes.empty?
	end

	test "should create screener_complete operational event if data changed" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert study_subject.operational_events.where(
			:operational_event_type_id => OperationalEventType['screener_complete'].id).empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			:new_middle_name => "TRIGGERCHANGE")
		bc_info.process
#		assert !bc_info.changes.empty?
		assert !study_subject.operational_events.where(
			:operational_event_type_id => OperationalEventType['screener_complete'].id).empty?
	end
#
#	hispanicity computation will ensure that almost all records
#	will have changed so this will happen for almost all
#
#	TODO unless set hispanicity initially!
#
	test "should NOT create screener_complete operational event if data NOT changed" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST",
			:hispanicity => '999', :hispanicity_mex => '999')
		assert study_subject.operational_events.where(
			:operational_event_type_id => OperationalEventType['screener_complete'].id).empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
		bc_info.process
		assert bc_info.changes.empty?	#	no changes
		dcoes = study_subject.reload.operational_events.where(
			:operational_event_type_id => OperationalEventType['screener_complete'].id)

#	TODO really? why? seems like it SHOULD
		assert dcoes.empty?

	end



#							Notification.plain(
#								"#{bc_info_file} subject save failed?  " <<
#								"I'm confused?  Help me.  " <<
#								"Subject #{study_subject.icf_master_id}. " <<
#								"Error messages ...:#{study_subject.errors.full_messages.to_sentence}:",
#								email_options.merge({ 
#									:subject => "ODMS: ERROR!  Subject save failed?  in #{bc_info_file}" })
#							).deliver
	test "should send save failed notification if subject changed and save failed" do
#	TODO stub create or update returns false
	end


	%w( hispanicity hispanicity_mex ).each do |attr|

		#	NO "NEW_" PREFIX HERE!!!!
		test "should update mother's #{attr} with subjects's mother_#{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
			study_subject.create_mother
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
				"mother_#{attr}" => "1")
			bc_info.process
			assert_equal "1", study_subject.mother.send(attr).to_s
		end

	end

	%w( first_name last_name maiden_name ).each do |attr|

		test "should update mother's #{attr} with subjects's new_mother_#{attr}" do
			study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
			study_subject.create_mother
			bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
				"new_mother_#{attr}" => "MOMSNAME")
			bc_info.process
			assert_equal "Momsname", study_subject.mother.send(attr)
		end

	end

	test "should create datachanged operational event for mother" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		assert mother.operational_events.where(
			:operational_event_type_id => OperationalEventType['datachanged'].id).empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"new_mother_first_name" => "MOMSNAME")
		bc_info.process
		assert !bc_info.mother_changes.empty?
		assert !mother.operational_events.where(
			:operational_event_type_id => OperationalEventType['datachanged'].id).empty?
#	TODO regardless of whether changed??  really?
	end

	test "should send no race code notification if mother race code invalid" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => "123456789")
		bc_info.process
		mail = ActionMailer::Base.deliveries.detect{|m|
			m.subject.match(/Invalid mother_race_code/) }
		assert mail.to.include?('jakewendt@berkeley.edu')
		assert_match 'No race found with code', mail.body.encoded
	end


#						elsif mr.is_other? or mr.is_mixed?
#							msr = if mother.races.include?( mr )
#								mother.subject_races.where(:race_code => mr.code).first
#							else
#								mother.subject_races.new(:race_code => mr.code)
#							end
#							new_other_race = study_subject.other_mother_race || "UNSPECIFIED IN BC_INFO"
#							msr.other_race = if msr.other_race.blank?
#								new_other_race
#							elsif msr.other_race.include?(new_other_race)
#								msr.other_race
#							else
#								"#{msr.other_race}, #{new_other_race}"
#							end
#							msr.save

	test "should create mother other race if is other and doesn't exist" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		assert mother.races.empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:other].code,
			'other_mother_race' => 'martian' )
		bc_info.process
		assert_equal [Race[:other]],mother.reload.races


	end

	test "should create mother other race if is mixed and doesn't exist" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:mixed].code,
			'other_mother_race' => 'martian' )
		bc_info.process
		assert_equal [Race[:mixed]],mother.reload.races


	end

	test "should create mother other race if is other and doesn't exist and is unspecfied" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:other].code )
		bc_info.process
		assert_equal [Race[:other]],mother.reload.races


	end

	test "should create mother other race if is mixed and doesn't exist and is unspecfied" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:mixed].code )
		bc_info.process
		assert_equal [Race[:mixed]],mother.reload.races


	end

	test "should append mother other race if is other and exists" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		mother.subject_races.create(:race_code => Race[:other].code,
			:other_race => "martian")
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:other].code,
			'other_mother_race' => 'venusian' )
		bc_info.process


	end

	test "should append mother other race if is mixed and exists" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		mother.subject_races.create(:race_code => Race[:mixed].code,
			:other_race => "martian")
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:mixed].code,
			'other_mother_race' => 'venusian' )
		bc_info.process


	end

	test "should NOT append mother other race if is other and exists and includes" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		mother.subject_races.create(:race_code => Race[:other].code,
			:other_race => "martian")
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:other].code,
			'other_mother_race' => 'martian' )
		bc_info.process


	end

	test "should NOT append mother other race if is mixed and exists and includes" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		mother.subject_races.create(:race_code => Race[:mixed].code,
			:other_race => "martian")
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST",
			"mother_race_code" => Race[:mixed].code,
			'other_mother_race' => 'martian' )
		bc_info.process


	end





	test "should create mother race if don't have it" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		assert mother.races.empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", "mother_race" => 1 )
		bc_info.process
		assert !mother.reload.races.empty?
	end

	test "should NOT create mother race if already have it" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		mother = study_subject.create_mother
		assert mother.races.empty?
		mother.races << Race.where(:code => 1).first
		assert_equal 1, mother.reload.races.length
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST", "mother_race" => 1 )
		bc_info.process
		assert_equal 1, mother.reload.races.length
	end

	test "should create waitlist bc_request" do
		study_subject = Factory(:study_subject, :icf_master_id => "IDOEXIST")
		assert study_subject.bc_requests.empty?
		bc_info = BcInfo.new(:icf_master_id => "IDOEXIST")
		bc_info.process
		assert !study_subject.bc_requests.where(:status => 'waitlist').empty?
	end

end
__END__
