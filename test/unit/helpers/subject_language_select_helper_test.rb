require 'test_helper'

class SubjectLanguageSelectHelperTest < ActionView::TestCase

#	Don't quite understand why I don't need this here, but I do in ccls_engine form helper tests.
#		f.instance_variable_set('@template',ActionView::Base.new)	#	fake the funk
#	Both define the methods the same.  The only difference is that there are form builder and helper methods of the same name.

#	These tests are VERY specific and even minor changes to the method or even
#	in rails' helper methods will require updates or corrections.

	test "subject_languages_select" do
		@study_subject = Factory(:study_subject)
#		form_for(@study_subject,:url => '/'){|f| 
#<form action="/" class="edit_study_subject" id="edit_study_subject_7" method="post">
#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_languages_select() }
		output_buffer = form_for(@study_subject,:url => '/'){|f| f.subject_languages_select() }
#			expected = %{<form action="/" method="post"><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
			expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][0][language_id]" type="hidden" value="" /><input id="english_language_id" name="study_subject[subject_languages_attributes][0][language_id]" type="checkbox" value="1" />
<label for="english_language_id">English (eligible)</label>
</div>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][1][language_id]" type="hidden" value="" /><input id="spanish_language_id" name="study_subject[subject_languages_attributes][1][language_id]" type="checkbox" value="2" />
<label for="spanish_language_id">Spanish (eligible)</label>
</div>
<div class='subject_language creator'><div id='other_language'><input name="study_subject[subject_languages_attributes][2][language_id]" type="hidden" value="" /><input id="other_language_id" name="study_subject[subject_languages_attributes][2][language_id]" type="checkbox" value="3" />
<label for="other_language_id">Other (not eligible)</label>
<div id='specify_other_language'><label for="other_other_language">specify:</label>
<input id="other_other_language" name="study_subject[subject_languages_attributes][2][other_language]" size="12" type="text" />
</div></div></div>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][3][language_id]" type="hidden" value="" /><input id="unknown_language_id" name="study_subject[subject_languages_attributes][3][language_id]" type="checkbox" value="4" />
<label for="unknown_language_id">Unknown (eligible)</label>
</div>
</div>
</div><!-- study_subject_languages -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select English, Spanish" do
		@study_subject = Factory(:study_subject)
#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_languages_select([Language['english'],Language['spanish']]) }
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english'],Language['spanish']]) }
#		expected = %{<form action="/" method="post"><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][0][language_id]" type="hidden" value="" /><input id="english_language_id" name="study_subject[subject_languages_attributes][0][language_id]" type="checkbox" value="1" />
<label for="english_language_id">English (eligible)</label>
</div>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][1][language_id]" type="hidden" value="" /><input id="spanish_language_id" name="study_subject[subject_languages_attributes][1][language_id]" type="checkbox" value="2" />
<label for="spanish_language_id">Spanish (eligible)</label>
</div>
</div>
</div><!-- study_subject_languages -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select English, Spanish, Other" do
		@study_subject = Factory(:study_subject)
#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_languages_select([Language['english'],Language['spanish'],Language['other']]) }
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english'],Language['spanish'],Language['other']]) }
#		expected = %{<form action="/" method="post"><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][0][language_id]" type="hidden" value="" /><input id="english_language_id" name="study_subject[subject_languages_attributes][0][language_id]" type="checkbox" value="1" />
<label for="english_language_id">English (eligible)</label>
</div>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][1][language_id]" type="hidden" value="" /><input id="spanish_language_id" name="study_subject[subject_languages_attributes][1][language_id]" type="checkbox" value="2" />
<label for="spanish_language_id">Spanish (eligible)</label>
</div>
<div class='subject_language creator'><div id='other_language'><input name="study_subject[subject_languages_attributes][2][language_id]" type="hidden" value="" /><input id="other_language_id" name="study_subject[subject_languages_attributes][2][language_id]" type="checkbox" value="3" />
<label for="other_language_id">Other (not eligible)</label>
<div id='specify_other_language'><label for="other_other_language">specify:</label>
<input id="other_other_language" name="study_subject[subject_languages_attributes][2][other_language]" size="12" type="text" />
</div></div></div>
</div>
</div><!-- study_subject_languages -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select English, Spanish, Other with English" do
		@study_subject = Factory(:study_subject, :subject_languages_attributes => {
			'0' => { :language_id => Language['english'].id } } )
		subject_language_id = @study_subject.subject_language_ids.first	#	this can vary so cannot assume that it will be 1
#
#	TODO where is subject_language_id?  Does this still work?
#
pending
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english'],Language['spanish'],Language['other']]) }
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language destroyer'><input id="study_subject_subject_languages_attributes_0_language_id" name="study_subject[subject_languages_attributes][0][language_id]" type="hidden" value="1" /><input name="study_subject[subject_languages_attributes][0][_destroy]" type="hidden" value="1" /><input checked="checked" id="english__destroy" name="study_subject[subject_languages_attributes][0][_destroy]" type="checkbox" value="0" />
<label for="english__destroy">English (eligible)</label>
</div>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][1][language_id]" type="hidden" value="" /><input id="spanish_language_id" name="study_subject[subject_languages_attributes][1][language_id]" type="checkbox" value="2" />
<label for="spanish_language_id">Spanish (eligible)</label>
</div>
<div class='subject_language creator'><div id='other_language'><input name="study_subject[subject_languages_attributes][2][language_id]" type="hidden" value="" /><input id="other_language_id" name="study_subject[subject_languages_attributes][2][language_id]" type="checkbox" value="3" />
<label for="other_language_id">Other (not eligible)</label>
<div id='specify_other_language'><label for="other_other_language">specify:</label>
<input id="other_other_language" name="study_subject[subject_languages_attributes][2][other_language]" size="12" type="text" />
</div></div></div>
</div>
</div><!-- study_subject_languages -->
</form>}
		assert_equal expected, output_buffer
	end

	test "subject_languages_select English, Spanish, Other with Other" do
		@study_subject = Factory(:study_subject, :subject_languages_attributes => {
			'0' => { :language_id => Language['other'].id, :other_language => 'redneck' } } )
		subject_language_id = @study_subject.subject_language_ids.first	#	this can vary so cannot assume that it will be 1

#		form_for(:study_subject,@study_subject,:url => '/'){|f| 
#			concat f.subject_languages_select([Language['english'],Language['spanish'],Language['other']]) }
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english'],Language['spanish'],Language['other']]) }
#		expected = %{<form action="/" method="post"><input id="study_subject_subject_languages_attributes_2_id" name="study_subject[subject_languages_attributes][2][id]" type="hidden" value="#{subject_language_id}" /><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
#
#	TODO where'd the subject_language_id go??
#	TODO where is subject_language_id?  Does this still work?
#
pending
		expected = %{<form accept-charset="UTF-8" action="/" class="edit_study_subject" id="edit_study_subject_#{@study_subject.id}" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div><div id='study_subject_languages'><div class='languages_label'>Language of parent or caretaker:</div>
<div id='languages'>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][0][language_id]" type="hidden" value="" /><input id="english_language_id" name="study_subject[subject_languages_attributes][0][language_id]" type="checkbox" value="1" />
<label for="english_language_id">English (eligible)</label>
</div>
<div class='subject_language creator'><input name="study_subject[subject_languages_attributes][1][language_id]" type="hidden" value="" /><input id="spanish_language_id" name="study_subject[subject_languages_attributes][1][language_id]" type="checkbox" value="2" />
<label for="spanish_language_id">Spanish (eligible)</label>
</div>
<div class='subject_language destroyer'><div id='other_language'><input id="study_subject_subject_languages_attributes_2_language_id" name="study_subject[subject_languages_attributes][2][language_id]" type="hidden" value="3" /><input name="study_subject[subject_languages_attributes][2][_destroy]" type="hidden" value="1" /><input checked="checked" id="other__destroy" name="study_subject[subject_languages_attributes][2][_destroy]" type="checkbox" value="0" />
<label for="other__destroy">Other (not eligible)</label>
<div id='specify_other_language'><label for="other_other_language">specify:</label>
<input id="other_other_language" name="study_subject[subject_languages_attributes][2][other_language]" size="12" type="text" value="redneck" />
</div></div></div>
</div>
</div><!-- study_subject_languages -->
</form>}
		assert_equal expected, output_buffer
	end

end

__END__
