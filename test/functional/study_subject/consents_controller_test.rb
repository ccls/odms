require 'test_helper'

class StudySubject::ConsentsControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::ConsentsController

	#	no study_subject_id
	assert_no_route(:get, :show)
#	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
	assert_no_route(:get,:new,:study_subject_id => 0)
	assert_no_route(:post,:create,:study_subject_id => 0)

	def patient_attributes_on_consent(options={})
		{:was_previously_treated => 2, :was_ca_resident_at_diagnosis => 1}.merge(options)
	end

#	ONLY SHOW, EDIT and UPDATE

	site_editors.each do |cu|


#
#	TODO need to add tests for updating non-case and case without patient
#	TODO add test for editing non-case to test that no patient fields on it
#


#	as the language selector is a form builder, unlike the race selector, explicit helper tests will be challenging



#Study Subject/Consents Controller should NOT have checked subject_languages on edit if don't exist with administrator login: Warning: schema loading from file
#<div class="subject_language creator">
#<input name="study_subject[subject_languages_attributes][0][language_code]" type="hidden" value=""><input id="english_language_code" type="checkbox" value="1" name="study_subject[subject_languages_attributes][0][language_code]">
#<label for="english_language_code">English (eligible)</label>
#</div>
#<div class="subject_language creator">
#<input name="study_subject[subject_languages_attributes][1][language_code]" type="hidden" value=""><input id="spanish_language_code" type="checkbox" value="2" name="study_subject[subject_languages_attributes][1][language_code]">
#<label for="spanish_language_code">Spanish (eligible)</label>
#</div>
#<div class="subject_language creator"><div id="other_language">
#<input name="study_subject[subject_languages_attributes][2][language_code]" type="hidden" value=""><input id="other_language_code" type="checkbox" value="3" name="study_subject[subject_languages_attributes][2][language_code]">
#<label for="other_language_code">Other (not eligible)</label>
#<div id="specify_other_language">
#<label for="other_other_language">specify:</label>
#<input size="12" id="other_other_language" type="text" name="study_subject[subject_languages_attributes][2][other_language]">
#</div>
#</div></div>



		test "should NOT have checked subject_languages on edit if don't exist with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 0 ){
				@study_subject = FactoryGirl.create(:case_study_subject)	#	NOTE CASE subject only (for now?)
			}
			login_as send(cu)
			get :edit, :study_subject_id => @study_subject.id
			assert_select( "div#study_subject_languages" ){
				assert_select( "div.languages_label" )
				assert_select( "div#languages" ){
					assert_select( "div.subject_language.creator", :count => 3 ).each do |sl|
						#	checkbox and hidden share the same name

						#	Rails < 4.2
						#assert_select( sl, "input" ) {
						#	assert_select( "[name=?]",
						#	/study_subject\[subject_languages_attributes\]\[\d+\]\[language_code\]/,
						#	:count => 2 ) }
						#	Rails >= 4.2
						assert_select( sl, "input[name^='study_subject[subject_languages_attributes][']" <<
							"[name$='][language_code]']",
								:count => 2 )

						assert_select( sl, "input[type='hidden'][value='']", :count => 1 )

						#	Rails < 4.2
						#assert_select( sl, "input[type='checkbox']" ){
						#	assert_select( "[value=?]", /\d+/, :count => 1 ) }
						#	Rails >= 4.2
						assert_select( sl, "input[type='checkbox']", :count => 1 )

							#	value is the language_id (could test each but iffy)
						#	should not be checked
						assert_select( sl, "input[type='checkbox'][checked='checked']", 
							:count => 0 )
						#	this is the important check
						assert_select( sl, ":not([checked=checked])" )	
					end
					assert_select("div#specify_other_language", :count => 1 ){

						#	Rails < 4.2
						#assert_select("input[type='text']"){ 
						#	assert_select( "[name=?]",
						#	/study_subject\[subject_languages_attributes\]\[\d+\]\[other_language\]/,
						#	:count => 1 ) }
						#	Rails >= 4.2
						assert_select("input[type='text'][name^='study_subject[subject_languages_attributes][']" <<
							"[name$='][other_language]']",
								:count => 1 )
					}
			} }
		end

		test "should have checked subject_language on edit if exists with #{cu} login" do
			language = Language['english']
			assert_not_nil language
			assert_difference( 'SubjectLanguage.count', 1 ){
				#	NOTE CASE subject only (for now?)
				@study_subject = FactoryGirl.create(:case_study_subject, 
					:subject_languages_attributes => {			
						'0' => { :language_code => language.code }
			} ) }
			login_as send(cu)
			get :edit, :study_subject_id => @study_subject.id
			assert_select( "div#study_subject_languages" ){
				assert_select( "div.languages_label" )
				assert_select( "div#languages" ){
					assert_select( "div.subject_language.creator", :count => 2 ).each do |sl|
						#	checkbox and hidden share the same name

						#	Rails < 4.2
						#assert_select( sl, "input" ){
						#	assert_select( "[name=?]",
						#	/study_subject\[subject_languages_attributes\]\[\d+\]\[language_code\]/,
						#	:count => 2 ) }
						#	Rails >= 4.2
						assert_select( sl, "input[name^='study_subject[subject_languages_attributes][']" <<
							"[name$='][language_code]']",
								:count => 2 )

						assert_select( sl, "input[type='hidden'][value='']", :count => 1 )

						#	Rails < 4.2
						#assert_select( sl, "input[type='checkbox']" ){
						#	assert_select( "[value=?]", /\d+/, :count => 1 )	}
						#	Rails >= 4.2
						assert_select( sl, "input[type='checkbox']", :count => 1 )

							#	value is the language_code (could test it, but would be complicated)
						#	should not be checked
						assert_select( sl, "input[type='checkbox'][checked='checked']", :count => 0 )
						assert_select( sl, ":not([checked=checked])" )	#	this is the important check
					end
					assert_select( "div.subject_language.destroyer", :count => 1 ).each do |sl|

						#	Rails < 4.2
						#assert_select( sl, "input[type='hidden'][value='#{language.code}']" ){
						#	assert_select( "[name=?]",
						#	/study_subject\[subject_languages_attributes\]\[\d+\]\[language_code\]/,
						#	:count => 1 ) }
						#	Rails >= 4.2
						assert_select( sl, "input[type='hidden'][value='#{language.code}']" <<
							"[name^='study_subject[subject_languages_attributes][']" << 
							"[name$='][language_code]']",
								:count => 1 )

						#	destroy checkbox and hidden share the same name
						#	Rails < 4.2
						#assert_select( sl, "input" ){
						#	assert_select( "[name=?]",
						#	/study_subject\[subject_languages_attributes\]\[\d+\]\[_destroy\]/,
						#	:count => 2 ){
						#	Rails >= 4.2
						assert_select( sl, "input[name^='study_subject[subject_languages_attributes][']" <<
							"[name$='][_destroy]']",
								:count => 2 ){

							assert_select( "input[type='hidden'][value='1']", :count => 1 )
							assert_select( "input[type='checkbox'][value='0']", :count => 1 )
							assert_select( "input[type='checkbox'][checked='checked']", :count => 1 )
						}

					end
					assert_select("div#specify_other_language",1 ){
						#	Rails < 4.2
						#assert_select("input[type='text']" ){
						#	assert_select( "[name=?]", 
						#	/study_subject\[subject_languages_attributes\]\[\d+\]\[other_language\]/,
						#	:count => 1 ) }
						#	Rails >= 4.2
						assert_select("input[type='text'][name^='study_subject[subject_languages_attributes][']" <<
							"[name$='][other_language]']",
								:count => 1 )
					}
			} }
		end

		test "should have other subject_languages on edit if exists with #{cu} login" do
			language = Language['other']
			assert_not_nil language
			assert_difference( 'SubjectLanguage.count', 1 ){
				#	NOTE CASE subject only (for now?)
				@study_subject = FactoryGirl.create(:case_study_subject, 
					:subject_languages_attributes => {			
						'0' => { :other_language => 'redneck', :language_code => language.code }
			} ) }
			login_as send(cu)
			get :edit, :study_subject_id => @study_subject.id
			assert_select("div#specify_other_language", :count => 1 ){

				#	Rails < 4.2
				#assert_select("input[type='text'][value='redneck']" ){
				#	assert_select( "[name=?]",
				#	/study_subject\[subject_languages_attributes\]\[.+\]\[other_language\]/,
				#	:count => 1 ) }
				#	Rails >= 4.2
				assert_select("input[type='text'][value='redneck']" <<
					"[name^='study_subject[subject_languages_attributes][']" <<
					"[name$='][other_language]']", 
						:count => 1 )

			}
		end

		test "should update and create subject_languages if given with #{cu} login" do
			language = Language['english']
			assert_not_nil language
			assert_difference( 'SubjectLanguage.count', 0 ){
				@study_subject = FactoryGirl.create(:complete_case_study_subject)
			}
			login_as send(cu)
#	NOTE CASE subject only (for now) ... ONLY CASE WILL HAVE PATIENT (AND MUST) SO CASE ONLY
#	NOTE controller won't care if not case, it's just the edit view that won't have the fields
#				:patient => FactoryGirl.attributes_for(:patient),
			assert_difference('SubjectLanguage.count',1){
				put :update, :study_subject_id => @study_subject.id, 
				:patient => patient_attributes_on_consent,
					:enrollment => FactoryGirl.attributes_for(:consented_enrollment),
					:study_subject => { :subject_languages_attributes => {
					'0' => { :language_code => language.code }
			} } }
			assert !@study_subject.reload.subject_languages.empty?
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should update and destroy subject_languages if given with #{cu} login" do
			language = Language['english']
			assert_not_nil language
			assert_difference( 'SubjectLanguage.count', 1 ){
				@study_subject = FactoryGirl.create(:complete_case_study_subject, 
					:subject_languages_attributes => {
						'0' => { :language_code => language.code }
			} ) }
			subject_language = @study_subject.subject_languages.first
			assert_equal language, subject_language.language
			login_as send(cu)
#	NOTE CASE subject only (for now) ... ONLY CASE WILL HAVE PATIENT (AND MUST) SO CASE ONLY
#	NOTE controller won't care if not case, it's just the edit view that won't have the fields
#				:patient => FactoryGirl.attributes_for(:patient),
			assert_difference( 'SubjectLanguage.count', -1 ){
				put :update, :study_subject_id => @study_subject.id, 
				:patient => patient_attributes_on_consent,
					:enrollment => FactoryGirl.attributes_for(:consented_enrollment),
					:study_subject => { :subject_languages_attributes => {
						'0' => { :id => subject_language.id, :_destroy => 1 } } }
			}
			assert @study_subject.reload.subject_languages.empty?
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should NOT update consent if study_subject update fails with #{cu} login" do
			language = Language['english']
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			#	Don't need to provide something new to save to trigger this failure.
			#	:patient => FactoryGirl.attributes_for(:patient),
			put :update, :study_subject_id => study_subject.id,
				:patient => patient_attributes_on_consent,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:notice]
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update consent if patient update fails with #{cu} login" do
#	TODO as soon as 3 field data types are settled.
#		don't remember which 3 I was talking about!
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
			Patient.any_instance.stubs(:create_or_update).returns(false)
#				:patient => FactoryGirl.attributes_for(:patient),
			put :update, :study_subject_id => study_subject.id,
				:patient => patient_attributes_on_consent,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:notice]
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should create ccls enrollment on edit if none exists with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil ccls_enrollment	#	auto-created
			ccls_enrollment.destroy
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_nil ccls_enrollment
			study_subject.reload	#	gotta reload
			assert_equal 0, study_subject.enrollments.length
			login_as send(cu)
			assert_difference('Enrollment.count',1) {
				get :edit, :study_subject_id => study_subject.id
			}
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil ccls_enrollment	#	auto-created
		end

		test "should NOT create ccls enrollment on edit if one exists with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil ccls_enrollment	#	auto-created
			login_as send(cu)
			assert_difference('Enrollment.count',0) {
				get :edit, :study_subject_id => study_subject.id
			}
		end

#
#	Gotta handle cases and non-cases.
#	Gotta deal with patient fields.
#	Gotta deal with subject languages.
#	These multiple models will need to be wrapped in a transaction.
#

		test "should update consent for case without patient with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			assert_nil study_subject.patient
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should update consent for control with #{cu} login" do
			study_subject = FactoryGirl.create(:complete_control_study_subject)
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end


		test "should edit consent with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'edit'
		end

		test "should have eligibility criteria on case edit consent with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'edit'
			assert_select "div#eligibility_criteria", :count => 1
		end

		test "should NOT have eligibility criteria on control edit consent with #{cu} login" do
			study_subject = FactoryGirl.create(:control_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'edit'
			assert_select "div#eligibility_criteria", :count => 0
		end

		test "should NOT have eligibility criteria on mother edit consent with #{cu} login" do
			study_subject = FactoryGirl.create(:mother_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'edit'
			assert_select "div#eligibility_criteria", :count => 0
		end

		test "should NOT edit consent with invalid study_subject_id #{cu} login" do
			login_as send(cu)
			get :edit, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update consent with #{cu} login" do
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
#				:patient => FactoryGirl.attributes_for(:patient),
			put :update, :study_subject_id => study_subject.id,
				:patient => patient_attributes_on_consent,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should NOT update consent with invalid study_subject_id and #{cu} login" do
			login_as send(cu)
			put :update, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update consent with #{cu} login and invalid enrollment" do
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
			Enrollment.any_instance.stubs(:valid?).returns(false)
#				:patient => FactoryGirl.attributes_for(:patient),
			put :update, :study_subject_id => study_subject.id,
				:patient => patient_attributes_on_consent,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:notice]
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update consent with #{cu} login and save fails" do
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
#				:patient => FactoryGirl.attributes_for(:patient),
			put :update, :study_subject_id => study_subject.id,
				:patient => patient_attributes_on_consent,
				:enrollment => FactoryGirl.attributes_for(:consented_enrollment)
			assert_nil     flash[:notice]
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT edit consent with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update consent with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

		test "should get consents with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'show'
		end

		test "should NOT get consents with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :show, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT get consents for mother with #{cu} login" do
			login_as send(cu)
			mother = FactoryGirl.create(:mother_study_subject)
			get :show, :study_subject_id => mother.id
			assert_nil flash[:error]
			assert_match /data is only collected for child subjects. Please go to the record for the subject's child for details/, 
				@response.body
			assert_response :success
			assert_template 'show_mother'
			assert_nil assigns(:enrollment)
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get consents with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get consents without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :show, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get edit consent without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :edit, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT update consent without login" do
		study_subject = FactoryGirl.create(:study_subject)
		put :update, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :enrollment,
		[ :vaccine_authorization_received_at, :is_eligible, :ineligible_reason_id, 
		:other_ineligible_reason, :consented, :refusal_reason_id, 
		:other_refusal_reason, :consented_on, :use_smp_future_rsrch, 
		:use_smp_future_cancer_rsrch, :use_smp_future_other_rsrch, 
		:share_smp_with_others, :contact_for_related_study, :provide_saliva_smp, 
		:receive_study_findings ],
		[:study_subject_id])

	#	These are separate and NOT NESTED!
	add_strong_parameters_tests( :patient, [ 
		:was_previously_treated, :was_ca_resident_at_diagnosis ])


	#	This will require some mods.
	test "add subject language attributes tests" do
		pending
	end


end
__END__

I'm surprised that this isn't entirely study_subject with nested attributes?


"enrollment"=>{"vaccine_authorization_received_at"=>"", "is_eligible"=>"1", "ineligible_reason_id"=>"", "other_ineligible_reason"=>"", "consented"=>"1", "refusal_reason_id"=>"", "other_refusal_reason"=>"", "consented_on"=>"10/14/1996", "use_smp_future_rsrch"=>"", "use_smp_future_cancer_rsrch"=>"", "use_smp_future_other_rsrch"=>"", "share_smp_with_others"=>"", "contact_for_related_study"=>"", "provide_saliva_smp"=>"", "receive_study_findings"=>""}, 

"study_subject"=>{"subject_languages_attributes"=>{"0"=>{"language_code"=>"1", "_destroy"=>"0", "id"=>"450"}, "1"=>{"language_code"=>""}, "2"=>{"language_code"=>"", "other_language"=>""}}}, 

"patient"=>{"was_previously_treated"=>"2", "was_ca_resident_at_diagnosis"=>""}, 

"study_subject_id"=>"7674"}





