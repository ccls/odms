require 'test_helper'

class SubjectRaceSelectHelperTest < ActionView::TestCase

#	These tests are VERY specific and even minor changes to the method or even
#	in rails' helper methods will require updates or corrections.

#	If the races fixtures change, they may need updated to match races, order, ids, etc.
#	TODO try to loosen the ties.

#	Clean this up.  One race per test. With and without

#	20130129 - no longer using 'is_primary'
	test "subject_races_select White" do
		@study_subject = Factory(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['white']) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
#<div id='races'>
#<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set &#x27;White, Non-Hispanic&#x27; as the subject&#x27;s PRIMARY race" type="checkbox" value="1" />
#<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="white_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set &#x27;White, Non-Hispanic&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="1" />
#<label for="white_race_id">White, Non-Hispanic</label>
#</div>
#</div>
#</div><!-- study_subject_races -->
#</form>}
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="" /><input class="race_selector" id="white_race_code" name="study_subject[subject_races_attributes][0][race_code]" title="Set &#x27;White, Non-Hispanic&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="#{Race[:white].code}" />
<label for="white_race_code">White, Non-Hispanic</label>
</div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "subject_races_select White with White" do
		@study_subject = Factory(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['white'].code } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['white']) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
#<div id='races'>
#<div class='subject_race destroyer'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set &#x27;White, Non-Hispanic&#x27; as the subject&#x27;s PRIMARY race" type="checkbox" value="1" />
#<input id="study_subject_subject_races_attributes_0_race_id" name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="1" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="white__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#x27;White, Non-Hispanic&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="0" />
#<label for="white__destroy">White, Non-Hispanic</label>
#<input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
#</div>
#</div><!-- study_subject_races -->
#</form>}
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race destroyer'><input id="study_subject_subject_races_attributes_0_race_code" name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="#{Race[:white].code}" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="white__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#x27;White, Non-Hispanic&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="0" />
<label for="white__destroy">White, Non-Hispanic</label>
<input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Other" do
		@study_subject = Factory(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['other']) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
#<div id='races'>
#<div class='subject_race creator'><div id='other_race'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="other_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set &#x27;Other Race&#x27; as the subject&#x27;s PRIMARY race" type="checkbox" value="1" />
#<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="other_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set &#x27;Other Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="6" />
#<label for="other_race_id">Other Race</label>
#<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
#<input id="race_other_other_race" name="study_subject[subject_races_attributes][0][other_race]" size="30" type="text" />
#</div></div></div>
#</div>
#</div><!-- study_subject_races -->
#</form>}
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race creator'><div id='other_race'><input name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="" /><input class="race_selector" id="other_race_code" name="study_subject[subject_races_attributes][0][race_code]" title="Set &#x27;Other Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="#{Race[:other].code}" />
<label for="other_race_code">Other Race</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][0][other_race]" size="30" type="text" />
</div></div></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "subject_races_select Other with Other" do
		@study_subject = Factory(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['other'].code, :other_race => "otherrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['other']) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
#<div id='races'>
#<div class='subject_race destroyer'><div id='other_race'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="other_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set &#x27;Other Race&#x27; as the subject&#x27;s PRIMARY race" type="checkbox" value="1" />
#<input id="study_subject_subject_races_attributes_0_race_id" name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="6" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="other__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#x27;Other Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="0" />
#<label for="other__destroy">Other Race</label>
#<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
#<input id="race_other_other_race" name="study_subject[subject_races_attributes][0][other_race]" size="30" type="text" value="otherrace" />
#</div></div><input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
#</div>
#</div><!-- study_subject_races -->
#</form>}
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race destroyer'><div id='other_race'><input id="study_subject_subject_races_attributes_0_race_code" name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="#{Race[:other].code}" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="other__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#x27;Other Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="0" />
<label for="other__destroy">Other Race</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][0][other_race]" size="30" type="text" value="otherrace" />
</div></div><input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Mixed" do
		@study_subject = Factory(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['mixed']) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
#<div id='races'>
#<div class='subject_race creator'><div id='mixed_race'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="mixed_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set &#x27;Mixed Race&#x27; as the subject&#x27;s PRIMARY race" type="checkbox" value="1" />
#<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="mixed_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set &#x27;Mixed Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="6" />
#<label for="mixed_race_id">Mixed Race</label>
#<div id='specify_mixed_race'><label for="race_mixed_mixed_race">specify:</label>
#<input id="race_mixed_mixed_race" name="study_subject[subject_races_attributes][0][mixed_race]" size="30" type="text" />
#</div></div></div>
#</div>
#</div><!-- study_subject_races -->
#</form>}
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race creator'><div id='mixed_race'><input name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="" /><input class="race_selector" id="mixed_race_code" name="study_subject[subject_races_attributes][0][race_code]" title="Set &#x27;Mixed Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="#{Race[:mixed].code}" />
<label for="mixed_race_code">Mixed Race</label>
<div id='specify_mixed_race'><label for="race_mixed_mixed_race">specify:</label>
<input id="race_mixed_mixed_race" name="study_subject[subject_races_attributes][0][mixed_race]" size="30" type="text" />
</div></div></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "subject_races_select Mixed with Mixed" do
		@study_subject = Factory(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['mixed'].code, :mixed_race => "mixedrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['mixed']) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
#<div id='races'>
#<div class='subject_race destroyer'><div id='mixed_race'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="mixed_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set &#x27;Mixed Race&#x27; as the subject&#x27;s PRIMARY race" type="checkbox" value="1" />
#<input id="study_subject_subject_races_attributes_0_race_id" name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="6" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="mixed__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#x27;Mixed Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="0" />
#<label for="mixed__destroy">Mixed Race</label>
#<div id='specify_mixed_race'><label for="race_mixed_mixed_race">specify:</label>
#<input id="race_mixed_mixed_race" name="study_subject[subject_races_attributes][0][mixed_race]" size="30" type="text" value="mixedrace" />
#</div></div><input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
#</div>
#</div><!-- study_subject_races -->
#</form>}
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): </div>
<div id='races'>
<div class='subject_race destroyer'><div id='mixed_race'><input id="study_subject_subject_races_attributes_0_race_code" name="study_subject[subject_races_attributes][0][race_code]" type="hidden" value="#{Race[:mixed].code}" /><input name="study_subject[subject_races_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="mixed__destroy" name="study_subject[subject_races_attributes][0][_destroy]" title="Remove &#x27;Mixed Race&#x27; as one of the subject&#x27;s race(s)" type="checkbox" value="0" />
<label for="mixed__destroy">Mixed Race</label>
<div id='specify_mixed_race'><label for="race_mixed_mixed_race">specify:</label>
<input id="race_mixed_mixed_race" name="study_subject[subject_races_attributes][0][mixed_race]" size="30" type="text" value="mixedrace" />
</div></div><input id="study_subject_subject_races_attributes_0_id" name="study_subject[subject_races_attributes][0][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

end

__END__


	test "subject_races_select" do
		@study_subject = Factory(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| f.subject_races_select() }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="white_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set 'White, Non-Hispanic' as one of the subject's race(s)" type="checkbox" value="1" />
<label for="white_race_id">White, Non-Hispanic</label>
</div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][1][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="black_is_primary" name="study_subject[subject_races_attributes][1][is_primary]" title="Set 'Black / African American' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][1][race_id]" type="hidden" value="" /><input class="race_selector" id="black_race_id" name="study_subject[subject_races_attributes][1][race_id]" title="Set 'Black / African American' as one of the subject's race(s)" type="checkbox" value="2" />
<label for="black_race_id">Black / African American</label>
</div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][2][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="nativeamerican_is_primary" name="study_subject[subject_races_attributes][2][is_primary]" title="Set 'Native American' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][2][race_id]" type="hidden" value="" /><input class="race_selector" id="nativeamerican_race_id" name="study_subject[subject_races_attributes][2][race_id]" title="Set 'Native American' as one of the subject's race(s)" type="checkbox" value="3" />
<label for="nativeamerican_race_id">Native American</label>
</div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][3][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="asian_is_primary" name="study_subject[subject_races_attributes][3][is_primary]" title="Set 'Asian / Pacific Islander' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][3][race_id]" type="hidden" value="" /><input class="race_selector" id="asian_race_id" name="study_subject[subject_races_attributes][3][race_id]" title="Set 'Asian / Pacific Islander' as one of the subject's race(s)" type="checkbox" value="4" />
<label for="asian_race_id">Asian / Pacific Islander</label>
</div>
<div class='subject_race creator'><div id='other_race'><input name="study_subject[subject_races_attributes][4][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="other_is_primary" name="study_subject[subject_races_attributes][4][is_primary]" title="Set 'Other race' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][4][race_id]" type="hidden" value="" /><input class="race_selector" id="other_race_id" name="study_subject[subject_races_attributes][4][race_id]" title="Set 'Other race' as one of the subject's race(s)" type="checkbox" value="7" />
<label for="other_race_id">Other race</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][4][other_race]" size="12" type="text" />
</div></div></div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][5][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="unknown_is_primary" name="study_subject[subject_races_attributes][5][is_primary]" title="Set 'Don't Know' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][5][race_id]" type="hidden" value="" /><input class="race_selector" id="unknown_race_id" name="study_subject[subject_races_attributes][5][race_id]" title="Set 'Don't Know' as one of the subject's race(s)" type="checkbox" value="999" />
<label for="unknown_race_id">Don't Know</label>
</div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][6][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="refused_is_primary" name="study_subject[subject_races_attributes][6][is_primary]" title="Set 'Refused to state' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][6][race_id]" type="hidden" value="" /><input class="race_selector" id="refused_race_id" name="study_subject[subject_races_attributes][6][race_id]" title="Set 'Refused to state' as one of the subject's race(s)" type="checkbox" value="888" />
<label for="refused_race_id">Refused to state</label>
</div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Black,White" do
		@study_subject = Factory(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select([Race['black'],Race['white']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="black_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set 'Black / African American' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="black_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set 'Black / African American' as one of the subject's race(s)" type="checkbox" value="2" />
<label for="black_race_id">Black / African American</label>
</div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][1][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][1][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][1][race_id]" type="hidden" value="" /><input class="race_selector" id="white_race_id" name="study_subject[subject_races_attributes][1][race_id]" title="Set 'White, Non-Hispanic' as one of the subject's race(s)" type="checkbox" value="1" />
<label for="white_race_id">White, Non-Hispanic</label>
</div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Black,White with White" do
		@study_subject = Factory(:study_subject,:subject_races_attributes => {
			'0' => { :race_id => Race['white'].id } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select([Race['black'],Race['white']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="black_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set 'Black / African American' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="black_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set 'Black / African American' as one of the subject's race(s)" type="checkbox" value="2" />
<label for="black_race_id">Black / African American</label>
</div>
<div class='subject_race destroyer'><input name="study_subject[subject_races_attributes][1][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][1][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" type="checkbox" value="1" />
<input id="study_subject_subject_races_attributes_1_race_id" name="study_subject[subject_races_attributes][1][race_id]" type="hidden" value="1" /><input name="study_subject[subject_races_attributes][1][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="white__destroy" name="study_subject[subject_races_attributes][1][_destroy]" title="Remove 'White, Non-Hispanic' as one of the subject's race(s)" type="checkbox" value="0" />
<label for="white__destroy">White, Non-Hispanic</label>
<input id="study_subject_subject_races_attributes_1_id" name="study_subject[subject_races_attributes][1][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Black,White,Other with Other" do
		@study_subject = Factory(:study_subject,:subject_races_attributes => {
			'0' => { :race_id => Race['other'].id, :other_race => "otherrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select([Race['black'],Race['white'],Race['other']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="black_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set 'Black / African American' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="black_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set 'Black / African American' as one of the subject's race(s)" type="checkbox" value="2" />
<label for="black_race_id">Black / African American</label>
</div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][1][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][1][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][1][race_id]" type="hidden" value="" /><input class="race_selector" id="white_race_id" name="study_subject[subject_races_attributes][1][race_id]" title="Set 'White, Non-Hispanic' as one of the subject's race(s)" type="checkbox" value="1" />
<label for="white_race_id">White, Non-Hispanic</label>
</div>
<div class='subject_race destroyer'><div id='other_race'><input name="study_subject[subject_races_attributes][2][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="other_is_primary" name="study_subject[subject_races_attributes][2][is_primary]" title="Set 'Other race' as the subject's PRIMARY race" type="checkbox" value="1" />
<input id="study_subject_subject_races_attributes_2_race_id" name="study_subject[subject_races_attributes][2][race_id]" type="hidden" value="7" /><input name="study_subject[subject_races_attributes][2][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="other__destroy" name="study_subject[subject_races_attributes][2][_destroy]" title="Remove 'Other race' as one of the subject's race(s)" type="checkbox" value="0" />
<label for="other__destroy">Other race</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][2][other_race]" size="12" type="text" value="otherrace" />
</div></div><input id="study_subject_subject_races_attributes_2_id" name="study_subject[subject_races_attributes][2][id]" type="hidden" value="#{subject_race_id}" /></div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

