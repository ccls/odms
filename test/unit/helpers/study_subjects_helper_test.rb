require 'test_helper'

class StudySubjectsHelperTest < ActionView::TestCase

#	test "should respond to study_subject_id_bar" do		#	TODO remove as in ccls_engine 3.8.7
#		assert respond_to?(:study_subject_id_bar)
#	end
#
#	test "id_bar_for study_subject should return study_subject_id_bar" do		#	TODO remove as in ccls_engine 3.8.7
#		study_subject = create_study_subject
#		assert study_subject.is_a?(StudySubject)
#		assert_nil study_subject_id_bar(study_subject)	#	sets content_for :main
#		response = HTML::Document.new(@content_for_main).root
#		assert_select response, 'div#id_bar' do
#			assert_select 'div.childid'
#			assert_select 'div.studyid'
#			assert_select 'div.full_name'
#			assert_select 'div.controls'
#		end
#	end

	test "should respond to select_subject_races" do
		assert respond_to?(:select_subject_races)
	end

	test "should show subject race selector" do
		study_subject = create_study_subject
		response = select_subject_races(study_subject)
		assert_not_nil response
	end

	test "subject race selector should contain a fieldset" do
		study_subject = create_study_subject
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, 'fieldset#race_selector', 1 do
			assert_select 'legend', 1
		end
	end

	test "subject race selector should contain 6 race labels" do
		study_subject = create_study_subject
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "label", 6
	end

	test "subject race selector should contain 6 race_selector checkboxes" do
		study_subject = create_study_subject
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input.race_selector", 6 do
			assert_select "#?", /race_\d/
			assert_select "[type=checkbox]"
			assert_select "[value=1]"
			assert_select "[name=?]", /study_subject\[subject_races_attributes\[\d\]\]\[race_id\]/
		end
	end

	test "subject race selector should contain 6 primary race checkboxes" do
		study_subject = create_study_subject
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input.is_primary_selector", 6 do
			assert_select "#?", /race_\d/
			assert_select "[type=checkbox]"
			assert_select "[value=true]"
			assert_select "[name=?]", /study_subject\[subject_races_attributes\[\d\]\]\[is_primary\]/
		end
	end

	test "subject race selector should contain 6 primary race hidden inputs" do
		study_subject = create_study_subject
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input[type=hidden]", 6 do
			assert_select "#?", /study_subject_subject_races_attributes_\d_is_primary/
			assert_select "[value=false]"
			assert_select "[name=?]", /study_subject\[subject_races_attributes\[\d\]\]\[is_primary\]/
		end
	end

	test "subject race selector for subject with 1 race should " <<
			"contain 1 do_not_destroy_race checkboxes" do
		race = Race.random
		study_subject = create_study_subject(:race_ids => [race.id])
		assert_equal 1, study_subject.races.length
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input.do_not_destroy_race", 1 do
			assert_select "#race_#{race.id}"
			assert_select ".race_selector"
			assert_select "[name='study_subject[subject_races_attributes[#{race.id}]][_destroy]']"
			assert_select "[type=checkbox]"
			assert_select "[value=0]"
			assert_select "[checked=checked]"
		end
	end

	test "subject race selector for study_subject with 1 race should " <<
			"contain 1 destroy_race hidden input" do
		race = Race.random
		study_subject = create_study_subject(:race_ids => [race.id])
		assert_equal 1, study_subject.races.length
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input.destroy_race", 1 do
			assert_select "#study_subject_subject_races_attributes_#{race.id}__destroy"
			assert_select "[name='study_subject[subject_races_attributes[#{race.id}]][_destroy]']"
			assert_select "[type=hidden]"
			assert_select "[value=1]"
		end
	end

	test "subject race selector for study_subject should " <<
			"contain 1 checked race with params set" do
		race = Race.random
		study_subject = create_study_subject
		assert_equal 0, study_subject.races.length
		self.params = HashWithIndifferentAccess.new(
				:study_subject => { 'subject_races_attributes' => {
					race.id.to_s => { 'race_id' => race.id, 'is_primary' => 'false' }
				} }
			)
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input.race_selector[checked=checked]", 1 do
			assert_select "#race_#{race.id}"
			assert_select "[name='study_subject[subject_races_attributes[#{race.id}]][race_id]']"
			assert_select "[type=checkbox]"
			assert_select "[value=#{race.id}]"
		end
		#	basically no is_primary checkboxes should be checked
		assert_select response, "input#race_#{race.id}_is_primary.is_primary_selector", 1 do
			assert_select "[name='study_subject[subject_races_attributes[#{race.id}]][is_primary]']"
			assert_select "[type=checkbox]"
			assert_select ":not([checked=checked])"	#	this is the important check
			assert_select "[value=true]"
		end
	end

	test "subject race selector for study_subject should " <<
			"contain 1 checked primary race with params set" do
		race = Race.random
		study_subject = create_study_subject
		assert_equal 0, study_subject.races.length
		self.params = HashWithIndifferentAccess.new(
				:study_subject => { 'subject_races_attributes' => {
					race.id.to_s => { 'race_id' => race.id, 'is_primary' => 'true' }
				} }
			)
		response = HTML::Document.new(select_subject_races(study_subject)).root
		assert_select response, "input.race_selector[checked=checked]", 1 do
			assert_select "#race_#{race.id}"
			assert_select "[name='study_subject[subject_races_attributes[#{race.id}]][race_id]']"
			assert_select "[type=checkbox]"
			assert_select "[value=#{race.id}]"
		end
		assert_select response, "input.is_primary_selector[checked=checked]", 1 do
			assert_select "#race_#{race.id}_is_primary"
			assert_select "[name='study_subject[subject_races_attributes[#{race.id}]][is_primary]']"
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
	def stylesheets(*args)
		#	placeholder so can call study_subject_id_bar and avoid
		#		NoMethodError: undefined method `stylesheets' for #<StudySubjectsHelperTest:0x10608e038>
	end
end
