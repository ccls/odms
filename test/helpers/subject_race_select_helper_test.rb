require 'test_helper'

class SubjectRaceSelectHelperTest < ActionView::TestCase

#	These tests are VERY specific and even minor changes to the method or even
#	in rails' helper methods will require updates or corrections.

#	If the races fixtures change, they may need updated to match races, order, ids, etc.
#	TODO try to loosen the ties.

#	Clean this up.  One race per test. With and without

#	20130129 - no longer using 'is_primary'
	test "subject_races_select White" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['white']) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="" /><input class="race_selector" id="white_race_code" name="study_subject[subject_races_attributes][0][race_code]" title="Set &#39;White, Non-Hispanic&#39; as one of the subject&#39;s race(s)" type="checkbox" value="#{Race[:white].code}" />
<label for="white_race_code">White, Non-Hispanic</label>
</div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#	rails 4 now html_escapes ' to &#39; in these input selectors

	test "subject_races_select White with White" do
		@study_subject = FactoryGirl.create(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['white'].code } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['white']) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race destroyer'><input id="study_subject_subject_races_attributes_0_race_code" name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="#{Race[:white].code}" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="white__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#39;White, Non-Hispanic&#39; as one of the subject&#39;s race(s)" type="checkbox" value="0" />
<label for="white__destroy">White, Non-Hispanic</label>
<input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Other" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['other']) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race creator'><div id='other_race'><input name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="" /><input class="race_selector" id="other_race_code" name="study_subject[subject_races_attributes][0][race_code]" title="Set &#39;Other Race&#39; as one of the subject&#39;s race(s)" type="checkbox" value="#{Race[:other].code}" />
<label for="other_race_code">Other Race</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][0][other_race]" type="text" />
</div></div></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Other with Other" do
		@study_subject = FactoryGirl.create(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['other'].code, :other_race => "otherrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['other']) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race destroyer'><div id='other_race'><input id="study_subject_subject_races_attributes_0_race_code" name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="#{Race[:other].code}" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="other__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#39;Other Race&#39; as one of the subject&#39;s race(s)" type="checkbox" value="0" />
<label for="other__destroy">Other Race</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][0][other_race]" type="text" value="otherrace" />
</div></div><input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Mixed" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['mixed']) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race creator'><div id='mixed_race'><input name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="" /><input class="race_selector" id="mixed_race_code" name="study_subject[subject_races_attributes][0][race_code]" title="Set &#39;Mixed Race&#39; as one of the subject&#39;s race(s)" type="checkbox" value="#{Race[:mixed].code}" />
<label for="mixed_race_code">Mixed Race</label>
<div id='specify_mixed_race'><label for="race_mixed_mixed_race">specify:</label>
<input id="race_mixed_mixed_race" name="study_subject[subject_races_attributes][0][mixed_race]" type="text" />
</div></div></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Mixed with Mixed" do
		@study_subject = FactoryGirl.create(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['mixed'].code, :mixed_race => "mixedrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['mixed']) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race destroyer'><div id='mixed_race'><input id="study_subject_subject_races_attributes_0_race_code" name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="#{Race[:mixed].code}" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="mixed__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#39;Mixed Race&#39; as one of the subject&#39;s race(s)" type="checkbox" value="0" />
<label for="mixed__destroy">Mixed Race</label>
<div id='specify_mixed_race'><label for="race_mixed_mixed_race">specify:</label>
<input id="race_mixed_mixed_race" name="study_subject[subject_races_attributes][0][mixed_race]" type="text" value="mixedrace" />
</div></div><input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

end

__END__
