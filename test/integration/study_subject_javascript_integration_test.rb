require 'integration_test_helper'

class StudySubjectJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#<div class="race_wrapper">
#<span class="label">Race:</span><fieldset id="race_selector"><legend>Select Race(s)</legend>
#<p>TEMP NOTE: primary is first, normal is second</p>
#<input type="hidden" value="false" name="study_subject[subject_races_attributes[1]][is_primary]" id="study_subject_subject_races_attributes_1_is_primary" />
#<input type="checkbox" value="true" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" name="study_subject[subject_races_attributes[1]][is_primary]" id="race_1_is_primary" class="is_primary_selector" />
#<input type="checkbox" value="1" title="Set 'White, Non-Hispanic' as one of the subject's race(s)" name="study_subject[subject_races_attributes[1]][race_id]" id="race_1" class="race_selector" />
#<label for="race_1">White, Non-Hispanic</label>
#<br />
#<input type="hidden" value="false" name="study_subject[subject_races_attributes[2]][is_primary]" id="study_subject_subject_races_attributes_2_is_primary" />
#<input type="checkbox" value="true" title="Set 'Black / African American' as the subject's PRIMARY race" name="study_subject[subject_races_attributes[2]][is_primary]" id="race_2_is_primary" class="is_primary_selector" />
#<input type="checkbox" value="2" title="Set 'Black / African American' as one of the subject's race(s)" name="study_subject[subject_races_attributes[2]][race_id]" id="race_2" class="race_selector" />
#<label for="race_2">Black / African American</label>
#<br />
#<input type="hidden" value="false" name="study_subject[subject_races_attributes[3]][is_primary]" id="study_subject_subject_races_attributes_3_is_primary" />
#<input type="checkbox" value="true" title="Set 'Native American' as the subject's PRIMARY race" name="study_subject[subject_races_attributes[3]][is_primary]" id="race_3_is_primary" class="is_primary_selector" />
#<input type="checkbox" value="3" title="Set 'Native American' as one of the subject's race(s)" name="study_subject[subject_races_attributes[3]][race_id]" id="race_3" class="race_selector" />
#<label for="race_3">Native American</label>
#<br />
#<input type="hidden" value="false" name="study_subject[subject_races_attributes[4]][is_primary]" id="study_subject_subject_races_attributes_4_is_primary" />
#<input type="checkbox" value="true" title="Set 'Asian / Pacific Islander' as the subject's PRIMARY race" name="study_subject[subject_races_attributes[4]][is_primary]" id="race_4_is_primary" class="is_primary_selector" />
#<input type="checkbox" value="4" title="Set 'Asian / Pacific Islander' as one of the subject's race(s)" name="study_subject[subject_races_attributes[4]][race_id]" id="race_4" class="race_selector" />
#<label for="race_4">Asian / Pacific Islander</label>
#<br />
#<input type="hidden" value="false" name="study_subject[subject_races_attributes[5]][is_primary]" id="study_subject_subject_races_attributes_5_is_primary" />
#<input type="checkbox" value="true" title="Set 'Other' as the subject's PRIMARY race" name="study_subject[subject_races_attributes[5]][is_primary]" id="race_5_is_primary" class="is_primary_selector" />
#<input type="checkbox" value="5" title="Set 'Other' as one of the subject's race(s)" name="study_subject[subject_races_attributes[5]][race_id]" id="race_5" class="race_selector" />
#<label for="race_5">Other</label>
#<br />
#<input type="hidden" value="false" name="study_subject[subject_races_attributes[6]][is_primary]" id="study_subject_subject_races_attributes_6_is_primary" />
#<input type="checkbox" value="true" title="Set 'Don't Know' as the subject's PRIMARY race" name="study_subject[subject_races_attributes[6]][is_primary]" id="race_6_is_primary" class="is_primary_selector" />
#<input type="checkbox" value="6" title="Set 'Don't Know' as one of the subject's race(s)" name="study_subject[subject_races_attributes[6]][race_id]" id="race_6" class="race_selector" />
#<label for="race_6">Don't Know</label>
#<br />
#</fieldset><!-- id='race_selector' -->
#</div>

#	OLD AND BUSTED ABOVE
#	NEW HOTNESS BELOW

#<input id="study_subject_subject_races_attributes_1_is_primary" name="study_subject[subject_races_attributes[1]][is_primary]" type="hidden" value="false">
#<input class="is_primary_selector" id="race_1_is_primary" name="study_subject[subject_races_attributes[1]][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" type="checkbox" value="true">
#<input class="race_selector" id="race_1" name="study_subject[subject_races_attributes[1]][race_id]" title="Set 'White, Non-Hispanic' as one of the subject's race(s)" type="checkbox" value="1">
#<label for="race_1">White, Non-Hispanic</label>


		test "should preserve creation of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 0 ){
				@study_subject = Factory(:study_subject)
			}
			login_as send(cu)
			page.visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
#	TODO
#			assert page.has_unchecked_field?("study_subject[subject_races_attributes][0][race_id]")	#	white
#			#	trigger a kickback from StudySubject update failure
#			StudySubject.any_instance.stubs(:valid?).returns(false)
#			click_button 'Save'
#			assert page.has_css?("p.flash#error")	#>There was a problem updating the study_subject</p>
#			assert_equal current_path, study_subject_path(@study_subject.id) #	still a kickback
#			assert page.has_unchecked_field?("study_subject[subject_races_attributes][0][race_id]")	#	white
		end

		test "should preserve destruction of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 1 ){
				@study_subject = Factory(:study_subject, :subject_races_attributes => { 
					'0' => { :race_id => Race['white'].id }})
			}
			login_as send(cu)
			page.visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
#	TODO
#			assert page.has_checked_field?("study_subject[subject_races_attributes][0][_destroy]")	#	white
#			#	trigger a kickback from StudySubject update failure
#			StudySubject.any_instance.stubs(:valid?).returns(false)
#			click_button 'Save'
#			assert page.has_css?("p.flash#error")	#>There was a problem updating the study_subject</p>
#			assert page.has_checked_field?("study_subject[subject_races_attributes][0][_destroy]")	#	white
		end

#	The below tests will need updated as well as those below.

		test "should check race when primary race is checked with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes[1]][race_id]")
			page.check "study_subject[subject_races_attributes[1]][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes[1]][race_id]")
		end

		test "should uncheck other primary race when primary race is check" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			page.check "study_subject[subject_races_attributes[1]][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes[1]][is_primary]")
			page.check "study_subject[subject_races_attributes[2]][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes[2]][is_primary]")
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes[1]][is_primary]")
		end

		test "should uncheck primary race when race is unchecked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			page.check "study_subject[subject_races_attributes[1]][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes[1]][race_id]")
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes[1]][is_primary]")
			page.uncheck "study_subject[subject_races_attributes[1]][race_id]"
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes[1]][race_id]")
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes[1]][is_primary]")
		end

	end

end
