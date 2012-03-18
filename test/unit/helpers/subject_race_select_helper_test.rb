require 'test_helper'

class SubjectRaceSelectHelperTest < ActionView::TestCase

#	Don't quite understand why I don't need this here, but I do in ccls_engine form helper tests.
#		f.instance_variable_set('@template',ActionView::Base.new)	#	fake the funk
#	Both define the methods the same.  The only difference is that there are form builder and helper methods of the same name.

#	These tests are VERY specific and even minor changes to the method or even
#	in rails' helper methods will require updates or corrections.

	test "subject_races_select" do
		@study_subject = Factory(:study_subject)
#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_races_select() }
		output_buffer = form_for(@study_subject,:url => '/'){|f| f.subject_races_select() }
#		expected = %{<form action="/" method="post"><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
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
<div class='subject_race creator'><div id='other_race'><input name="study_subject[subject_races_attributes][4][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="other_is_primary" name="study_subject[subject_races_attributes][4][is_primary]" title="Set 'Other' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][4][race_id]" type="hidden" value="" /><input class="race_selector" id="other_race_id" name="study_subject[subject_races_attributes][4][race_id]" title="Set 'Other' as one of the subject's race(s)" type="checkbox" value="5" />
<label for="other_race_id">Other</label>
<div id='specify_other_race'><label for="race_other_other_race">specify:</label>
<input id="race_other_other_race" name="study_subject[subject_races_attributes][4][other_race]" size="12" type="text" />
</div></div></div>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][5][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="unknown_is_primary" name="study_subject[subject_races_attributes][5][is_primary]" title="Set 'Don't Know' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][5][race_id]" type="hidden" value="" /><input class="race_selector" id="unknown_race_id" name="study_subject[subject_races_attributes][5][race_id]" title="Set 'Don't Know' as one of the subject's race(s)" type="checkbox" value="6" />
<label for="unknown_race_id">Don't Know</label>
</div>
<div class='subject_race creator'><input name=\"study_subject[subject_races_attributes][6][is_primary]\" type=\"hidden\" value=\"0\" /><input class=\"is_primary_selector\" id=\"refused_is_primary\" name=\"study_subject[subject_races_attributes][6][is_primary]\" title=\"Set 'Refused to state' as the subject's PRIMARY race\" type=\"checkbox\" value=\"1\" />
<input name=\"study_subject[subject_races_attributes][6][race_id]\" type=\"hidden\" value=\"\" /><input class=\"race_selector\" id=\"refused_race_id\" name=\"study_subject[subject_races_attributes][6][race_id]\" title=\"Set 'Refused to state' as one of the subject's race(s)\" type=\"checkbox\" value=\"7\" />
<label for=\"refused_race_id\">Refused to state</label>
</div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end
#<div class='subject_race creator'><input name="study_subject[subject_races_attributes][4][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="other_is_primary" name="study_subject[subject_races_attributes][4][is_primary]" title="Set 'Other' as the subject's PRIMARY race" type="checkbox" value="1" />
#<input name="study_subject[subject_races_attributes][4][race_id]" type="hidden" value="" /><input class="race_selector" id="other_race_id" name="study_subject[subject_races_attributes][4][race_id]" title="Set 'Other' as one of the subject's race(s)" type="checkbox" value="5" />
#<label for="other_race_id">Other</label>
#</div>

	test "subject_races_select Black,White" do
		@study_subject = Factory(:study_subject)
#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_races_select([Race['black'],Race['white']]) }
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select([Race['black'],Race['white']]) }
#		expected = %{<form action="/" method="post"><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
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
		subject_race_id = @study_subject.subject_race_ids.first	#	this can vary so cannot assume that it will be 1
#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_races_select([Race['black'],Race['white']]) }
#
#	TODO where is subject_race_id?
#
pending
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select([Race['black'],Race['white']]) }
#		expected = %{<form action="/" method="post"><input id="study_subject_subject_races_attributes_1_id" name="study_subject[subject_races_attributes][1][id]" type="hidden" value="#{subject_race_id}" /><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_races'><div class='races_label'>Select Race(s): .... ( [primary] [partial] Text )</div>
<div id='races'>
<div class='subject_race creator'><input name="study_subject[subject_races_attributes][0][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="black_is_primary" name="study_subject[subject_races_attributes][0][is_primary]" title="Set 'Black / African American' as the subject's PRIMARY race" type="checkbox" value="1" />
<input name="study_subject[subject_races_attributes][0][race_id]" type="hidden" value="" /><input class="race_selector" id="black_race_id" name="study_subject[subject_races_attributes][0][race_id]" title="Set 'Black / African American' as one of the subject's race(s)" type="checkbox" value="2" />
<label for="black_race_id">Black / African American</label>
</div>
<div class='subject_race destroyer'><input name="study_subject[subject_races_attributes][1][is_primary]" type="hidden" value="0" /><input class="is_primary_selector" id="white_is_primary" name="study_subject[subject_races_attributes][1][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" type="checkbox" value="1" />
<input id="study_subject_subject_races_attributes_1_race_id" name="study_subject[subject_races_attributes][1][race_id]" type="hidden" value="1" /><input name="study_subject[subject_races_attributes][1][_destroy]" type="hidden" value="1" /><input checked="checked" class="race_selector" id="white__destroy" name="study_subject[subject_races_attributes][1][_destroy]" title="Remove 'White, Non-Hispanic' as one of the subject's race(s)" type="checkbox" value="0" />
<label for="white__destroy">White, Non-Hispanic</label>
</div>
</div>
</div><!-- study_subject_races -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_races_select Black,White with Other" do
		@study_subject = Factory(:study_subject,:subject_races_attributes => {
			'0' => { :race_id => Race['other'].id, :other_race => "otherrace" } } )
		subject_race_id = @study_subject.subject_race_ids.first	#	this can vary so cannot assume that it will be 1
pending
	end

end

__END__
