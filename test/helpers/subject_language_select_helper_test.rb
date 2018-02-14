require 'test_helper'

class SubjectLanguageSelectHelperTest < ActionView::TestCase

#	These tests are VERY specific and even minor changes to the method or even
#	in rails' helper methods will require updates or corrections.

#	If the languages fixtures change, they may need updated to match languages, order, ids, etc.
#	TODO try to loosen the ties.

#	Simplify.  Test just one language.  With or without selection.

	#	added extract_options to allow for passing of :class for marking field_errors
	test "subject_languages_select English with class option" do
		@study_subject = FactoryBot.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english']], :class => 'field_error') }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div.field_error#study_subject_languages', :count => 1 do
				assert_select 'div.languages_label', :count => 1,
					:text => "Language of parent or caretaker:"
				assert_select 'div#languages', :count => 1 do
					assert_select 'div.subject_language.creator' do
						assert_select "input[type='hidden'][value='']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']",
							:count => 1
						assert_select "input#english_language_code[type='checkbox']" <<
							"[value='#{Language['english'].code}']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']",
							:count => 1
						assert_select 'label', :text => 'English (eligible)', :count => 1
					end
				end
			end
		end
	end

	test "subject_languages_select English" do
		@study_subject = FactoryBot.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english']]) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_languages', :count => 1 do
				assert_select 'div.languages_label', :count => 1,
					:text => "Language of parent or caretaker:"
				assert_select 'div#languages', :count => 1 do
					assert_select 'div.subject_language.creator', :count => 1 do
						assert_select "input[type='hidden'][value='']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']", 
							:count => 1
						assert_select "input#english_language_code[type='checkbox']" <<
							"[value='#{Language['english'].code}']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']",
							:count => 1
						assert_select 'label', :text => 'English (eligible)', :count => 1
					end
				end
			end
		end
	end

	test "subject_languages_select English with English" do
		@study_subject = FactoryBot.create(:study_subject, :subject_languages_attributes => {
			'0' => { :language_code => Language['english'].code } } )
		#	this can vary so cannot assume that it will be 1
		subject_language_id = @study_subject.subject_language_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['english']]) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_languages', :count => 1 do
				assert_select 'div.languages_label', :count => 1,
					:text => "Language of parent or caretaker:"
				assert_select 'div#languages', :count => 1 do
					assert_select 'div.subject_language.destroyer', :count => 1 do
						assert_select "input[type='hidden'][value='#{Language['english'].code}']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']",
							:count => 1

						assert_select "input[type='hidden'][value='1']" <<
							"[name='study_subject[subject_languages_attributes][0][_destroy]']",
							:count => 1
						assert_select "input[type='checkbox'][value='0'][checked='checked']" <<
							"[name='study_subject[subject_languages_attributes][0][_destroy]']",
							:count => 1

						assert_select 'label', :text => 'English (eligible)', :count => 1
						assert_select "input[type='hidden'][value='#{subject_language_id}']" <<
							"[name='study_subject[subject_languages_attributes][0][id]']",
							:count => 1
					end
				end
			end
		end
	end

	test "subject_languages_select Other" do
		@study_subject = FactoryBot.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['other']]) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_languages', :count => 1 do
				assert_select 'div.languages_label', :count => 1,
					:text => "Language of parent or caretaker:"
				assert_select 'div#languages', :count => 1 do
					assert_select 'div.subject_language.creator', :count => 1 do
						assert_select "input[type='hidden'][value='']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']",
							:count => 1
						assert_select "input#other_language_code[type='checkbox']" <<
							"[value='#{Language['other'].code}']" <<
							"[name='study_subject[subject_languages_attributes][0][language_code]']",
							:count => 1
						assert_select 'label', :text => 'Other (not eligible)', :count => 1
						assert_select 'div#specify_other_language', :count => 1 do
							assert_select 'label', :text => 'specify:'
							assert_select "input#other_other_language[type='text']" <<
								"[name='study_subject[subject_languages_attributes][0][other_language]']",
								:count => 1
						end
					end
				end
			end
		end
	end

	test "subject_languages_select Other with Other" do
		@study_subject = FactoryBot.create(:study_subject, :subject_languages_attributes => {
			'0' => { :language_code => Language['other'].code, :other_language => 'redneck' } } )
		#	this can vary so cannot assume that it will be 1
		subject_language_id = @study_subject.subject_language_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_languages_select([Language['other']]) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_languages', :count => 1 do
				assert_select 'div.languages_label', :count => 1,
					:text => "Language of parent or caretaker:"
				assert_select 'div#languages', :count => 1 do
					assert_select 'div.subject_language.destroyer', :count => 1 do
						assert_select 'div#other_language', :count => 1 do
							assert_select "input[type='hidden'][value='#{Language['other'].code}']" <<
								"[name='study_subject[subject_languages_attributes][0][language_code]']",
								:count => 1

							assert_select "input[type='checkbox'][value='0']" <<
								"[name='study_subject[subject_languages_attributes][0][_destroy]']",
								:count => 1
							assert_select "input[type='hidden'][value='1']" <<
								"[name='study_subject[subject_languages_attributes][0][_destroy]']",
								:count => 1

							assert_select 'label', :text => 'Other (not eligible)', :count => 1
	
							assert_select 'div#specify_other_language', :count => 1 do
								assert_select 'label', :text => 'specify:'
								assert_select "input#other_other_language[type='text']" <<
									"[value='redneck']" <<
									"[name='study_subject[subject_languages_attributes][0][other_language]']",
									:count => 1
							end
						end
						assert_select "input[type='hidden'][value='#{subject_language_id}']" <<
							"[name='study_subject[subject_languages_attributes][0][id]']",
							:count => 1
					end
				end
			end
		end
	end

end

__END__
