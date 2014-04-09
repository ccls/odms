require 'test_helper'

class SubjectLanguageSelectHelperTest < ActionView::TestCase

#	These tests are VERY specific and even minor changes to the method or even
#	in rails' helper methods will require updates or corrections.

#	If the languages fixtures change, they may need updated to match languages, order, ids, etc.
#	TODO try to loosen the ties.

#	Simplify.  Test just one language.  With or without selection.

	#	added extract_options to allow for passing of :class for marking field_errors
	test "subject_languages_select English with class option" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english']], :class => 'field_error') }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div class="field_error" id="study_subject_languages"><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][0][language_code]" type="hidden" value="" /><input id="english_language_code" name="study_subject[subject_languages_attributes][0][language_code]" type="checkbox" value="1" />
<label for="english_language_code">English (eligible)</label>
</div>
</div>
</div></form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select English" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id="study_subject_languages"><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][0][language_code]" type="hidden" value="" /><input id="english_language_code" name="study_subject[subject_languages_attributes][0][language_code]" type="checkbox" value="1" />
<label for="english_language_code">English (eligible)</label>
</div>
</div>
</div></form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select English with English" do
		@study_subject = FactoryGirl.create(:study_subject, :subject_languages_attributes => {
			'0' => { :language_code => Language['english'].code } } )
		#	this can vary so cannot assume that it will be 1
		subject_language_id = @study_subject.subject_language_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id="study_subject_languages"><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language destroyer'><input id="study_subject_subject_languages_attributes_0_language_code" name="study_subject[subject_languages_attributes][0][language_code]" type="hidden" value="1" /><input name="study_subject[subject_languages_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" id="english__destroy" name="study_subject[subject_languages_attributes][0][_destroy]" type="checkbox" value="0" />
<label for="english__destroy">English (eligible)</label>
<input id="study_subject_subject_languages_attributes_0_id" name="study_subject[subject_languages_attributes][0][id]" type="hidden" value="#{subject_language_id}" /></div>
</div>
</div></form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select Other" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['other']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id="study_subject_languages"><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><div id='other_language'><input name="study_subject[subject_languages_attributes][0][language_code]" type="hidden" value="" /><input id="other_language_code" name="study_subject[subject_languages_attributes][0][language_code]" type="checkbox" value="3" />
<label for="other_language_code">Other (not eligible)</label>
<div id='specify_other_language'><label for="other_other_language">specify:</label>
<input id="other_other_language" name="study_subject[subject_languages_attributes][0][other_language]" size="12" type="text" />
</div></div></div>
</div>
</div></form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select Other with Other" do
		@study_subject = FactoryGirl.create(:study_subject, :subject_languages_attributes => {
			'0' => { :language_code => Language['other'].code, :other_language => 'redneck' } } )
		#	this can vary so cannot assume that it will be 1
		subject_language_id = @study_subject.subject_language_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['other']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="patch" /></div><div id="study_subject_languages"><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language destroyer'><div id='other_language'><input id="study_subject_subject_languages_attributes_0_language_code" name="study_subject[subject_languages_attributes][0][language_code]" type="hidden" value="3" /><input name="study_subject[subject_languages_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" id="other__destroy" name="study_subject[subject_languages_attributes][0][_destroy]" type="checkbox" value="0" />
<label for="other__destroy">Other (not eligible)</label>
<div id='specify_other_language'><label for="other_other_language">specify:</label>
<input id="other_other_language" name="study_subject[subject_languages_attributes][0][other_language]" size="12" type="text" value="redneck" />
</div></div><input id="study_subject_subject_languages_attributes_0_id" name="study_subject[subject_languages_attributes][0][id]" type="hidden" value="#{subject_language_id}" /></div>
</div>
</div></form>}
		assert_equal expected, output_buffer
	end

end

__END__
