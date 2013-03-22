require 'test_helper'

class BcInfoTest < ActiveSupport::TestCase

#					icf_master_id = line['icf_master_id'] || line['masterid']
#					if icf_master_id.blank?
#						Notification.plain(
#							"#{bc_info_file} contained line with blank icf_master_id",
#							email_options.merge({ 
#								:subject => "ODMS: Blank ICF Master ID in #{bc_info_file}" })
#						).deliver
#						puts "icf_master_id is blank" 
#						next
#					end
#					subjects = StudySubject.where(:icf_master_id => icf_master_id)
		
	test "should send blank icf master id notification if icf master id is blank" do
	end

	
#					#	Shouldn't be possible as icf_master_id is unique in the db
#					#raise "Multiple case subjects? with icf_master_id:" <<
#					#	"#{line['icf_master_id']}:" if subjects.length > 1
#					unless subjects.length == 1
#						Notification.plain(
#							"#{bc_info_file} contained line with icf_master_id" <<
#							"but no subject with icf_master_id:#{icf_master_id}:",
#							email_options.merge({ 
#								:subject => "ODMS: No Subject with ICF Master ID in #{bc_info_file}" })
#						).deliver
#						puts "No subject with icf_master_id:#{icf_master_id}:" 
#						next
#					end
#					study_subject = subjects.first
	test "should send no matching subject notification if icf master id isn't used" do
	end

#					#	using "a" as a synonym for "new_attributes" since is a Hash (pointer)
#					a = new_attributes = {
#						:mother_first_name  => ( line['new_mother_first_name'] || 
#							line['new_mother_first'] ).to_s.squish.namerize,
#						:mother_last_name   => ( line['new_mother_last_name'] ||
#							line['new_mother_last'] ).to_s.squish.namerize,
#						:mother_maiden_name => ( line['new_mother_maiden_name'] ||
#							line['new_mother_maiden'] ).to_s.squish.namerize,
#						:father_first_name  => ( line['new_father_first_name'] ||
#							line['new_father_first'] ).to_s.squish.namerize,
#						:father_last_name   => ( line['new_father_last_name'] ||
#							line['new_father_last'] ).to_s.squish.namerize,
#						:first_name  => ( line['new_first_name'] ||
#							line['new_child_first'] ).to_s.squish.namerize,
#						:middle_name => ( line['new_middle_name'] ||
#							line['new_child_middle'] ).to_s.squish.namerize,
#						:last_name   => ( line['new_last_name'] ||
#							line['new_child_last'] ).to_s.squish.namerize,
#						:birth_city    => line['birth_city'].to_s.squish.namerize,
#						:birth_state   => line['birth_state'],
#						:birth_country => line['birth_country'],
#						:birth_year => line['new_dob_year'] || line['dob_year'] ||
#													line['new_child_doby'] || line['child_doby'],
#						:mother_hispanicity     => line['mother_hispanicity'].to_s.squish,
#						:mother_hispanicity_mex => line['mother_hispanicity_mex'].to_s.squish,
#						:father_hispanicity     => line['father_hispanicity'].to_s.squish,
#						:father_hispanicity_mex => line['father_hispanicity_mex'].to_s.squish,
#						:mom_is_biomom => line['mom_is_biomom'] || line['biomom'],
#						:father_race_code => line['father_race'].to_s.squish,
#						:mother_race_code => line['mother_race'].to_s.squish,
#						:dad_is_biodad => line['dad_is_biodad'] || line['biodad'],
#						:other_mother_race => ( line['other_mother_race'] || 
#							line['mother_race_other'] ).to_s.squish.namerize,
#						:other_father_race => ( line['other_father_race'] || 
#							line['father_race_other'] ).to_s.squish.namerize,
#						:sex => line['new_sex'] || line['new_child_gender'],
#						:dob => line['new_dob'] || line['new_child_dobfull']
#					}.with_indifferent_access
#	
#					if( a[:dob].blank? && 
#						!( line['new_child_doby'].blank? || 
#							line['new_child_dobm'].blank? || 
#							line['new_child_dobd'].blank?) )
#						a[:dob] = sprintf( "%4d-%02d-%02d", 
#							line['new_child_doby'],line['new_child_dobm'],line['new_child_dobd'] ) 
#					end
#	
#					a[:father_hispanicity] = 888 if a[:father_hispanicity] == '0'
#					a[:mother_hispanicity] = 888 if a[:mother_hispanicity] == '0'
#					a[:mother_hispanicity] = 999 if a[:mother_hispanicity] == '9'
#					a[:father_hispanicity] = 999 if a[:father_hispanicity] == '9'
#					a[:mother_hispanicity_mex] = 888 if a[:mother_hispanicity_mex] == '0'
#					a[:father_hispanicity_mex] = 888 if a[:father_hispanicity_mex] == '0'
#					a[:mother_hispanicity_mex] = 999 if a[:mother_hispanicity_mex] == '9'
#					a[:father_hispanicity_mex] = 999 if a[:father_hispanicity_mex] == '9'
#
#					a[:hispanicity] = 999
#					if a[:mother_hispanicity] == a[:father_hispanicity]
#						a[:hispanicity] = a[:father_hispanicity]
#					end
#					a[:hispanicity] = 1 if ( 
#						[a[:mother_hispanicity],a[:father_hispanicity]].include?('1') )
#
#					a[:hispanicity_mex] = 999
#					if a[:mother_hispanicity_mex] == a[:father_hispanicity_mex]
#						a[:hispanicity_mex] = a[:father_hispanicity_mex]
#					end
#					a[:hispanicity_mex] = 1 if ( 
#						[a[:mother_hispanicity_mex],a[:father_hispanicity_mex]].include?('1') )
#
#					a[:father_race_code] = 888 if a[:father_race_code] == '0'
#					a[:mother_race_code] = 888 if a[:mother_race_code] == '0'
#					a[:father_race_code] = 999 if a[:father_race_code] == '9'
#					a[:mother_race_code] = 999 if a[:mother_race_code] == '9'

	test "should update many attributes if different" do
	end







	
#					new_attributes.each do |k,v|
#						#	NOTE always check if attribute is blank as don't want to delete data
#						study_subject.send("#{k}=",v) unless v.blank?
#					end

	test "should not update attribute if new data is blank" do
	end




#							study_subject.operational_events.create(
#								:occurred_at => DateTime.now,
#								:project_id => Project['ccls'].id,
#								:operational_event_type_id => OperationalEventType['datachanged'].id,
#								:description => "ICF Screening data changes from #{bc_info_file}",
#								:event_notes => "Changes:  #{changes}")
	test "should create datachanged operational event if data changed" do
	end

	test "should NOT create datachanged operational event if data NOT changed" do
	end

#							study_subject.operational_events.create(
#								:occurred_at => line['date'] || DateTime.now,
#								:project_id  => Project['ccls'].id,
#								:operational_event_type_id => OperationalEventType['screener_complete'].id,
#								:description => "ICF screening complete from #{bc_info_file}" ) if (
#									study_subject.operational_events.where(:operational_event_type_id => OperationalEventType['screener_complete'].id).where(:project_id => Project[:ccls].id).empty? )

	test "should create screener_complete operational event if data changed" do
	end

	test "should NOT create screener_complete operational event if data NOT changed" do
#	really?
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
	end



#					mother.hispanicity = study_subject.mother_hispanicity unless study_subject.mother_hispanicity.blank?
#					mother.hispanicity_mex = study_subject.mother_hispanicity_mex unless study_subject.mother_hispanicity_mex.blank?
#					mother.first_name  = study_subject.mother_first_name unless study_subject.mother_first_name.blank?
#					mother.last_name   = study_subject.mother_last_name unless study_subject.mother_last_name.blank?
#					mother.maiden_name = study_subject.mother_maiden_name unless study_subject.mother_maiden_name.blank?
	test "should update mother attributes" do
	end

#					mother.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['datachanged'].id,
#						:description => "ICF Screening data changes from #{bc_info_file}",
#						:event_notes => "Changes:  #{changes}")
	test "should create datachanged operational event for mother" do
#	regardless of whether changed??  really?
	end





#					if study_subject.mother_race_code
#						mr = Race.where(:code => study_subject.mother_race_code).first
#						if mr.nil?
#							Notification.plain("No race found with code :#{study_subject.mother_race_code}:",
#								email_options.merge({ 
#									:subject => "ODMS: Invalid mother_race_code" })
#							).deliver
	test "should send no race code notification if mother race code invalid" do
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
	end

	test "should create mother other race if is mixed and doesn't exist" do
	end

	test "should append mother other race if is other and exists" do
	end

	test "should append mother other race if is mixed and exists" do
	end

	test "should NOT append mother other race if is other and exists and includes" do
	end

	test "should NOT append mother other race if is mixed and exists and includes" do
	end

#						else
#							mother.races << mr unless mother.races.include?( mr )
#						end	#	if mr.nil? (mr is not nil or other or mixed)
#					end	#	if study_subject.mother_race_code


	test "should create mother race" do
	end


#					study_subject.bc_requests.create(:status => 'waitlist')

	test "should create waitlist bc_request" do
	end

end
__END__


	
