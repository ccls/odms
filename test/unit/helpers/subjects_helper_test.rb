require 'test_helper'

class SubjectsHelperTest < ActionView::TestCase

#	test "should respond to sort_link" do
#		assert respond_to?(:sort_link)
#	end
#
#	test "should return div with link to sort column name" do
#		#	NEED controller and action as method calls link_to which requires them
#		self.params = { :controller => 'subjects', :action => 'index' }
#		response = HTML::Document.new(sort_link('name')).root
#		#	<div class=""><a href="/subjects?dir=asc&amp;order=name">name</a></div>
#		assert_select response, 'div', 1 do
#			assert_select 'a', 1
#			assert_select 'span', 0
#		end
#	end
#
#	test "should return div with link to sort column name with order set to name" do
#		self.params = { :controller => 'subjects', :action => 'index', 
#			:order => 'name' }
#		response = HTML::Document.new(sort_link('name')).root
#		#	<div class="sorted"><a href="/subjects?dir=asc&amp;order=name">name</a>
#		#		<span class="up arrow">&uarr;</span></div>
#		assert_select response, 'div.sorted', 1 do
#			assert_select 'a', 1
#			assert_select 'span.up.arrow', 1
#		end
#	end
#
#	test "should return div with link to sort column name with order set to name" <<
#			" and dir set to 'asc'" do
#		self.params = { :controller => 'subjects', :action => 'index', 
#			:order => 'name', :dir => 'asc' }
#		response = HTML::Document.new(sort_link('name')).root
#		#	<div class="sorted"><a href="/subjects?dir=asc&amp;order=name">name</a>
#		#		<span class="down arrow">&uarr;</span></div>
#		assert_select response, 'div.sorted', 1 do
#			assert_select 'a', 1
#			assert_select 'span.down.arrow', 1
#		end
#	end
#
#	test "should return div with link to sort column name with order set to name" <<
#			" and dir set to 'desc'" do
#		self.params = { :controller => 'subjects', :action => 'index', 
#			:order => 'name', :dir => 'desc' }
#		response = HTML::Document.new(sort_link('name')).root
#		#	<div class="sorted"><a href="/subjects?dir=asc&amp;order=name">name</a>
#		#		<span class="up arrow">&uarr;</span></div>
#		assert_select response, 'div.sorted', 1 do
#			assert_select 'a', 1
#			assert_select 'span.up.arrow', 1
#		end
#	end

	test "should respond to subject_id_bar" do
		assert respond_to?(:subject_id_bar)
	end

	test "should respond to select_subject_races" do
		assert respond_to?(:select_subject_races)
	end

	test "should show subject race selector" do
		subject = create_subject
		response = select_subject_races(subject)
		assert_not_nil response
	end

	test "subject race selector should contain a fieldset" do
		subject = create_subject
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, 'fieldset#race_selector', 1 do
			assert_select 'legend', 1
		end
	end

	test "subject race selector should contain 6 race labels" do
		subject = create_subject
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "label", 6
	end

	test "subject race selector should contain 6 race_selector checkboxes" do
		subject = create_subject
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input.race_selector", 6 do
			assert_select "#?", /race_\d/
			assert_select "[type=checkbox]"
			assert_select "[value=1]"
			assert_select "[name=?]", /subject\[subject_races_attributes\[\d\]\]\[race_id\]/
		end
	end

	test "subject race selector should contain 6 primary race checkboxes" do
		subject = create_subject
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input.is_primary_selector", 6 do
			assert_select "#?", /race_\d/
			assert_select "[type=checkbox]"
			assert_select "[value=true]"
			assert_select "[name=?]", /subject\[subject_races_attributes\[\d\]\]\[is_primary\]/
		end
	end

	test "subject race selector should contain 6 primary race hidden inputs" do
		subject = create_subject
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input[type=hidden]", 6 do
			assert_select "#?", /subject_subject_races_attributes_\d_is_primary/
			assert_select "[value=false]"
			assert_select "[name=?]", /subject\[subject_races_attributes\[\d\]\]\[is_primary\]/
		end
	end

	test "subject race selector for subject with 1 race should " <<
			"contain 1 do_not_destroy_race checkboxes" do
		race = Race.random
		subject = create_subject(:race_ids => [race.id])
		assert_equal 1, subject.races.length
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input.do_not_destroy_race", 1 do
			assert_select "#race_#{race.id}"
			assert_select ".race_selector"
			assert_select "[name='subject[subject_races_attributes[#{race.id}]][_destroy]']"
			assert_select "[type=checkbox]"
			assert_select "[value=0]"
			assert_select "[checked=checked]"
		end
	end

	test "subject race selector for subject with 1 race should " <<
			"contain 1 destroy_race hidden input" do
		race = Race.random
		subject = create_subject(:race_ids => [race.id])
		assert_equal 1, subject.races.length
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input.destroy_race", 1 do
			assert_select "#subject_subject_races_attributes_#{race.id}__destroy"
			assert_select "[name='subject[subject_races_attributes[#{race.id}]][_destroy]']"
			assert_select "[type=hidden]"
			assert_select "[value=1]"
		end
	end

	test "subject race selector for subject should " <<
			"contain 1 checked race with params set" do
		race = Race.random
		subject = create_subject
		assert_equal 0, subject.races.length
		self.params = HashWithIndifferentAccess.new(
				:subject => { 'subject_races_attributes' => {
					race.id.to_s => { 'race_id' => race.id, 'is_primary' => 'false' }
				} }
			)
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input.race_selector[checked=checked]", 1 do
			assert_select "#race_#{race.id}"
			assert_select "[name='subject[subject_races_attributes[#{race.id}]][race_id]']"
			assert_select "[type=checkbox]"
			assert_select "[value=#{race.id}]"
		end
		#	basically no is_primary checkboxes should be checked
		assert_select response, "input#race_#{race.id}_is_primary.is_primary_selector", 1 do
			assert_select "[name='subject[subject_races_attributes[#{race.id}]][is_primary]']"
			assert_select "[type=checkbox]"
			assert_select ":not([checked=checked])"	#	this is the important check
			assert_select "[value=true]"
		end
	end

	test "subject race selector for subject should " <<
			"contain 1 checked primary race with params set" do
		race = Race.random
		subject = create_subject
		assert_equal 0, subject.races.length
		self.params = HashWithIndifferentAccess.new(
				:subject => { 'subject_races_attributes' => {
					race.id.to_s => { 'race_id' => race.id, 'is_primary' => 'true' }
				} }
			)
		response = HTML::Document.new(select_subject_races(subject)).root
		assert_select response, "input.race_selector[checked=checked]", 1 do
			assert_select "#race_#{race.id}"
			assert_select "[name='subject[subject_races_attributes[#{race.id}]][race_id]']"
			assert_select "[type=checkbox]"
			assert_select "[value=#{race.id}]"
		end
		assert_select response, "input.is_primary_selector[checked=checked]", 1 do
			assert_select "#race_#{race.id}_is_primary"
			assert_select "[name='subject[subject_races_attributes[#{race.id}]][is_primary]']"
			assert_select "[type=checkbox]"
			assert_select "[value=true]"
		end
	end

private 
	def params
		@params || {}
	end
	def params=(new_params)
		@params = new_params
	end
end

__END__


<fieldset id="race_selector"><legend>Select Race(s)</legend>
<p>TEMP NOTE: primary is first, normal is second</p>
<input name="subject[subject_races_attributes[1]][is_primary]" id="subject_subject_races_attributes_1_is_primary" value="false" type="hidden" />
<input name="subject[subject_races_attributes[1]][is_primary]" title="Set 'White, Non-Hispanic' as the subject's PRIMARY race" class="is_primary_selector" id="race_1_is_primary" value="true" type="checkbox" />
<input name="subject[subject_races_attributes[1]][race_id]" title="Set 'White, Non-Hispanic' as one of the subject's race(s)" class="race_selector" id="race_1" value="1" type="checkbox" />
<label for="race_1">White, Non-Hispanic</label>
<br />
<input name="subject[subject_races_attributes[2]][id]" id="subject_subject_races_attributes_2_id" value="1" type="hidden" />
<input name="subject[subject_races_attributes[2]][is_primary]" id="subject_subject_races_attributes_2_is_primary" value="false" type="hidden" />
<input name="subject[subject_races_attributes[2]][is_primary]" title="Set 'Black / African American' as the subject's PRIMARY race" class="is_primary_selector" id="race_2_is_primary" value="true" type="checkbox" />
<input name="subject[subject_races_attributes[2]][_destroy]" class="destroy_race" id="subject_subject_races_attributes_2__destroy" value="1" type="hidden" />
<input name="subject[subject_races_attributes[2]][_destroy]" checked="checked" title="Set 'Black / African American' as one of the subject's race(s)" class="race_selector do_not_destroy_race" id="race_2" value="0" type="checkbox" />
<label for="race_2">Black / African American</label>
<br />
<input name="subject[subject_races_attributes[3]][is_primary]" id="subject_subject_races_attributes_3_is_primary" value="false" type="hidden" />
<input name="subject[subject_races_attributes[3]][is_primary]" title="Set 'Native American' as the subject's PRIMARY race" class="is_primary_selector" id="race_3_is_primary" value="true" type="checkbox" />
<input name="subject[subject_races_attributes[3]][race_id]" title="Set 'Native American' as one of the subject's race(s)" class="race_selector" id="race_3" value="3" type="checkbox" />
<label for="race_3">Native American</label>
<br />
<input name="subject[subject_races_attributes[4]][is_primary]" id="subject_subject_races_attributes_4_is_primary" value="false" type="hidden" />
<input name="subject[subject_races_attributes[4]][is_primary]" title="Set 'Asian / Pacific Islander' as the subject's PRIMARY race" class="is_primary_selector" id="race_4_is_primary" value="true" type="checkbox" />
<input name="subject[subject_races_attributes[4]][race_id]" title="Set 'Asian / Pacific Islander' as one of the subject's race(s)" class="race_selector" id="race_4" value="4" type="checkbox" />
<label for="race_4">Asian / Pacific Islander</label>
<br />
<input name="subject[subject_races_attributes[5]][is_primary]" id="subject_subject_races_attributes_5_is_primary" value="false" type="hidden" />
<input name="subject[subject_races_attributes[5]][is_primary]" title="Set 'Other' as the subject's PRIMARY race" class="is_primary_selector" id="race_5_is_primary" value="true" type="checkbox" />
<input name="subject[subject_races_attributes[5]][race_id]" title="Set 'Other' as one of the subject's race(s)" class="race_selector" id="race_5" value="5" type="checkbox" />
<label for="race_5">Other</label>
<br />
<input name="subject[subject_races_attributes[6]][is_primary]" id="subject_subject_races_attributes_6_is_primary" value="false" type="hidden" />
<input name="subject[subject_races_attributes[6]][is_primary]" title="Set 'Don't Know' as the subject's PRIMARY race" class="is_primary_selector" id="race_6_is_primary" value="true" type="checkbox" />
<input name="subject[subject_races_attributes[6]][race_id]" title="Set 'Don't Know' as one of the subject's race(s)" class="race_selector" id="race_6" value="6" type="checkbox" />
<label for="race_6">Don't Know</label>
<br />
</fieldset><!-- id='race_selector' -->

