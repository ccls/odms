require 'test_helper'

class SubjectRaceSelectHelperTest < ActionView::TestCase

#	If the races fixtures change, they may need updated to match races, order, ids, etc.
#	TODO try to loosen the ties.

#	Clean this up.  One race per test. With and without

#	20130129 - no longer using 'is_primary'
	test "subject_races_select White" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['white']) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", 
				:count => 1 do
			assert_select 'div#study_subject_races', :count => 1 do
				assert_select 'div.races_label', :count => 1,
					:text => "Select Race(s):"
				assert_select 'div#races', :count => 1 do
					assert_select 'div.subject_race.creator' do
						assert_select "input[type='hidden'][value='' ]" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1
						assert_select "input#white_race_code[type='checkbox']" <<
							"[value='#{Race['white'].code}']" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1
#	:title => "Set &#39;White, Non-Hispanic&#39; as one of the subject&#39;s race(s)",
						assert_select 'label', :text => Race['white'].description, :count => 1
					end
				end
			end
		end
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

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_races', :count => 1 do
				assert_select 'div.races_label', :count => 1,
					:text => "Select Race(s):"
				assert_select 'div#races', :count => 1 do
					assert_select 'div.subject_race.destroyer', :count => 1 do
						assert_select "input[type='hidden'][value='#{Race['white'].code}']" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1

						assert_select "input[type='hidden'][value='1']" <<
							"[name='study_subject[subject_races_attributes][0][_destroy]']",
							:count => 1
						assert_select "input[type='checkbox'][value='0'][checked='checked']" <<
							"[name='study_subject[subject_races_attributes][0][_destroy]']",
							:count => 1
#	:title => "Remove &#39;White, Non-Hispanic&#39; as one of the subject&#39;s race(s)",

						assert_select 'label', :text => Race['white'].description, :count => 1
						assert_select "input[type='hidden'][value='#{subject_race_id}']" <<
							"[name='study_subject[subject_races_attributes][0][id]']",
							:count => 1
					end
				end
			end
		end
	end

	test "subject_races_select Other" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['other']) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_races', :count => 1 do
				assert_select 'div.races_label', :count => 1,
					:text => "Select Race(s):"
				assert_select 'div#races', :count => 1 do
					assert_select 'div.subject_race.creator', :count => 1 do
						assert_select "input[type='hidden'][value='']" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1
						assert_select "input#other_race_code[type='checkbox']" <<
							"[value='#{Race['other'].code}']" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1
#	:title => "Set &#39;Other Race&#39; as one of the subject&#39;s race(s)",
						assert_select 'label', :text => 'Other Race', :count => 1
						assert_select 'div#specify_other_race', :count => 1 do
							assert_select 'label', :text => 'specify:'
							assert_select "input#race_other_other_race[type='text']" <<
								"[name='study_subject[subject_races_attributes][0][other_race]']",
								:count => 1
						end
					end
				end
			end
		end
	end

	test "subject_races_select Other with Other" do
		@study_subject = FactoryGirl.create(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['other'].code, :other_race => "otherrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['other']) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_races', :count => 1 do
				assert_select 'div.races_label', :count => 1,
					:text => "Select Race(s):"
				assert_select 'div#races', :count => 1 do
					assert_select 'div.subject_race.destroyer', :count => 1 do
						assert_select 'div#other_race', :count => 1 do
							assert_select "input[type='hidden'][value='#{Race['other'].code}']" <<
								"[name='study_subject[subject_races_attributes][0][race_code]']",
								:count => 1

							assert_select "input[type='hidden'][value='1']" <<
								"[name='study_subject[subject_races_attributes][0][_destroy]']",
								:count => 1
							assert_select "input[type='checkbox'][value='0']" <<
								"[name='study_subject[subject_races_attributes][0][_destroy]']",
								:count => 1
#	:title => "Remove &#39;Other Race&#39; as one of the subject&#39;s race(s)",

							assert_select 'label', :text => 'Other Race', :count => 1
	
							assert_select 'div#specify_other_race', :count => 1 do
								assert_select 'label', :text => 'specify:'
								assert_select "input#race_other_other_race[type='text']" <<
									"[value='otherrace']" <<
									"[name='study_subject[subject_races_attributes][0][other_race]']",
									:count => 1
							end
						end
						assert_select "input[type='hidden'][value='#{subject_race_id}']" <<
							"[name='study_subject[subject_races_attributes][0][id]']",
							:count => 1
					end
				end
			end
		end
	end

	test "subject_races_select Mixed" do
		@study_subject = FactoryGirl.create(:study_subject)
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['mixed']) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", :count => 1 do
			assert_select 'div#study_subject_races', :count => 1 do
				assert_select 'div.races_label', :count => 1,
					:text => "Select Race(s):"
				assert_select 'div#races', :count => 1 do
					assert_select 'div.subject_race.creator', :count => 1 do
						assert_select "input[type=hidden][value='']" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1
						assert_select "input#mixed_race_code[type='checkbox']" <<
							"[value='#{Race['mixed'].code}']" <<
							"[name='study_subject[subject_races_attributes][0][race_code]']",
							:count => 1
#	:title => "Set &#39;Mixed Race&#39; as one of the subject&#39;s race(s)",
						assert_select 'label', :text => 'Mixed Race', :count => 1
						assert_select 'div#specify_mixed_race', :count => 1 do
							assert_select 'label', :text => 'specify:'
							assert_select "input#race_mixed_mixed_race[type='text']" <<
								"[name='study_subject[subject_races_attributes][0][mixed_race]']",
								:count => 1
						end
					end
				end
			end
		end
	end

	test "subject_races_select Mixed with Mixed" do
		@study_subject = FactoryGirl.create(:study_subject,:subject_races_attributes => {
			'0' => { :race_code => Race['mixed'].code, :mixed_race => "mixedrace" } } )
		#	this can vary so cannot assume that it will be 1
		subject_race_id = @study_subject.subject_race_ids.first	
		output_buffer = form_for(@study_subject,:url => '/'){|f| 
			f.subject_races_select(Race['mixed']) }

		response = output_buffer.to_html_document
		assert_select response, "form#edit_study_subject_#{@study_subject.id}", 
				:count => 1 do
			assert_select 'div#study_subject_races', :count => 1 do
				assert_select 'div.races_label', :count => 1,
					:text => "Select Race(s):"
				assert_select 'div#races', :count => 1 do
					assert_select 'div.subject_race.destroyer', :count => 1 do
						assert_select 'div#mixed_race', :count => 1 do
							assert_select "input[type=hidden][value='#{Race['mixed'].code}']" << 
								"[name='study_subject[subject_races_attributes][0][race_code]']",
								:count => 1


							assert_select "input[type=hidden][value='1']" << 
								"[name='study_subject[subject_races_attributes][0][_destroy]']",
								:count => 1
							assert_select "input[type=checkbox][value='0']" << 
								"[name='study_subject[subject_races_attributes][0][_destroy]']",
								:count => 1
#	not sure how to match the quoted quotes
#	"[title='Remove &#39;Mixed Race&#39; as one of the subject&#39;s race(s)']",

							assert_select 'label', :text => 'Mixed Race', :count => 1
	
							assert_select 'div#specify_mixed_race', :count => 1 do
								assert_select 'label', :text => 'specify:'
								assert_select "input#race_mixed_mixed_race[type='text']" <<
									"[value='mixedrace']" <<
									"[name='study_subject[subject_races_attributes][0][mixed_race]']",
									:count => 1
							end
						end
						assert_select "input[type=hidden][value='#{subject_race_id}']" <<
							"[name='study_subject[subject_races_attributes][0][id]']",
							:count => 1
					end
				end
			end
		end
	end

end

__END__
