module RafTestHelper

#	NOTE the deep factories are convenient, but are a bit of a pain in the butt
#		when trying to override the default attributes because FactoryBot doesn't
#		deep_merge, it just merges.  Which means that the nested attribute model
#		needs to be completely defined, rather than just merging in the new attribute.
#		Because of this, if I want to use nested factories and I want to override them,
#		my code will get a bit clumsy unless I write a bunch of factory helpers.
#		Of course, I've already got quite of a few factory helpers, particularly in
#		the ccls_engine gem.  In order to ensure that the everything happened as
#		desired, I wrap everything in a lot of assertions.
#
#		Must also be conscious of whether the keys are STRINGs or SYMBOLs.
#

	def complete_case_study_subject_attributes(options={})
		{ 'study_subject' => FactoryBot.attributes_for(:raf_study_subject,
			'patient_attributes' => FactoryBot.attributes_for(:patient),
			'subject_languages_attributes' => {
				"0"=>{"language_code"=>"1"} },
			'phone_numbers_attributes' => {
				'0' => FactoryBot.attributes_for(:phone_number) },
			'addresses_attributes' => {
				'0' => FactoryBot.attributes_for(:address) },
			'enrollments_attributes' => {
				'0' => FactoryBot.attributes_for(:enrollment,
					:project_id => Project['ccls'].id ) }
			)
		}.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def assert_all_differences(count=0,&block)
		assert_difference('StudySubject.count',count){
		assert_difference('SubjectLanguage.count',count){
		assert_difference('Patient.count',count){
		assert_difference('Enrollment.count',count){
		assert_difference('PhoneNumber.count',count){
		assert_difference('Address.count',count){
			yield
		} } } } } }
	end

	def successful_raf_creation(&block)
		assert_difference('StudySubject.count',2){
		assert_difference('SubjectLanguage.count',1){
		assert_difference('Patient.count',1){
		assert_difference('Enrollment.count',2){	#	subject AND mother
		assert_difference('PhoneNumber.count',1){
		assert_difference('Address.count',1){
			yield

#if assigns(:study_subject).errors.count > 0
#puts "\nIn raf_test_helper.  Shouldn't've been any errors."
#puts assigns(:study_subject).errors.inspect
#end

		} } } } } }
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

	def assert_duplicates_found_and_rerendered_new
		assert !assigns(:duplicates).empty?
		assert assigns(:study_subject)
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	def full_successful_creation(options={})
		successful_raf_creation { 
			post :create, complete_case_study_subject_attributes(options) }
	end

	def minimum_raf_form_attributes(options={})
		{ 'study_subject' => FactoryBot.attributes_for(:minimum_raf_form_attributes
			) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def raf_form_attributes(options={})
		{ 'study_subject' => FactoryBot.attributes_for(:raf_form_attributes
			) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def raf_successful_creation(options={})
		successful_raf_creation { 
			post :create, raf_form_attributes(options) }
	end

	def minimum_raf_successful_creation(options={})
		assert_difference('SubjectLanguage.count',0){
		assert_difference('PhoneNumber.count',0){
		assert_difference('Address.count',0){
		assert_difference('Enrollment.count',2){	#	both child and mother
		assert_difference('Patient.count',1){
		assert_difference('StudySubject.count',2){
			post :create, minimum_raf_form_attributes(options)
		} } } } } }
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

end	#	module RafTestHelper
ActiveSupport::TestCase.send(:include,RafTestHelper)
