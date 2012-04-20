#class ActiveSupport::TestCase
module RafTestHelper

#	def create_complete_case_study_subject(options={})
#		subject = Factory(:complete_case_study_subject,options)
#	end
#
#	NOTE the deep factories are convenient, but are a bit of a pain in the butt
#		when trying to override the default attributes because Factory doesn't
#		deep_merge, it just merges.  Which means that the nested attribute model
#		needs to be completely defined, rather than just merging in the new attribute.
#		Because of this, if I want to use nested factories and I want to override them,
#		my code will get a bit clumsy unless I write a bunch of factory helpers.
#		Of course, I've already got quite of a few factory helpers, particularly in
#		the ccls_engine gem.  In order to ensure that the everything happened as
#		desired, I wrap everything in a lot of assertions.
#
#		Must also be consious of whether the keys are STRINGs or SYMBOLs.
#

#	NOTE this method is almost unnecessary now that pii and identifier merged
#	def create_complete_case_study_subject_with_mother_maiden_name(mother_maiden_name)
#		subject = nil
#		assert_difference('Patient.count',1) {
#		assert_difference('StudySubject.count',1) {
#			subject = Factory(:complete_case_study_subject, 
#				:mother_maiden_name => mother_maiden_name )
#		} }
#		assert_equal mother_maiden_name, subject.mother_maiden_name
#		subject
#	end

#			:race_ids => [Race.random.id],

#ActiveModel::MassAssignmentSecurity::Error: Can't mass-assign protected attributes: case_control_type
#	if I set it to nil, will it stop the above?

	def complete_case_study_subject_attributes(options={})
		{ 'study_subject' => Factory.attributes_for(:study_subject,
#	NOT on the form or currently required
#			'subject_races_attributes' => {
#				"0"=>{"race_id"=>"1"} },
			'subject_languages_attributes' => {
				"0"=>{"language_id"=>"1"} },
			'patient_attributes' => Factory.attributes_for(:patient),
			'phone_numbers_attributes' => {
				'0' => Factory.attributes_for(:phone_number) },
			'addressings_attributes' => {
				'0' => Factory.attributes_for(:addressing,
				'address_attributes' => Factory.attributes_for(:address) ) },
			'enrollments_attributes' => {
				'0' => Factory.attributes_for(:enrollment) }


			)	#.delete_keys!(:case_control_type)
#	TODO remove protected attributes


		}.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def assert_all_differences(count=0,&block)
		assert_difference('StudySubject.count',count){
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',count){
		assert_difference('Patient.count',count){
		assert_difference('Enrollment.count',count){
		assert_difference('PhoneNumber.count',count){
		assert_difference('Addressing.count',count){
		assert_difference('Address.count',count){
			yield
		} } } } } } } #}
	end

	def successful_raf_creation(&block)
		assert_difference('StudySubject.count',2){
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',1){
		assert_difference('Patient.count',1){
		assert_difference('Enrollment.count',2){	#	subject AND mother
		assert_difference('PhoneNumber.count',1){
		assert_difference('Addressing.count',1){
		assert_difference('Address.count',1){
			yield

#	TODO
if assigns(:study_subject).errors.count > 0
puts "\nIn raf_test_helper.  Shouldn't've been any errors."
puts assigns(:study_subject).errors.inspect
end

		} } } } } } } #}
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

#	def minimum_successful_raf_creation(&block)
##		assert_difference('SubjectRace.count',count){
#		assert_difference('SubjectLanguage.count',0){
#		assert_difference('PhoneNumber.count',0){
#		assert_difference('Addressing.count',0){
#		assert_difference('Address.count',0){
#		assert_difference('Enrollment.count',2){	#	both child and mother
#		assert_difference('Patient.count',1){
#		assert_difference('StudySubject.count',2){
#			yield
#		} } } } } } } # }
#		assert_nil flash[:error]
#		assert_redirected_to assigns(:study_subject)
#	end

	def assert_duplicates_found_and_rerendered_new
		assert !assigns(:duplicates).empty?
		assert assigns(:study_subject)
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	def full_successful_creation(options={})
		#	waivered / nonwaivered? does it matter?
		successful_raf_creation { 
			post :create, complete_case_study_subject_attributes(options) }
	end

	def minimum_nonwaivered_form_attributes(options={})
		{ 'study_subject' => Factory.attributes_for(:minimum_nonwaivered_form_attributes
			) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def nonwaivered_form_attributes(options={})
		{ 'study_subject' => Factory.attributes_for(:nonwaivered_form_attributes
				) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def nonwaivered_successful_creation(options={})
		successful_raf_creation { 
			post :create, nonwaivered_form_attributes(options) }
	end

	def minimum_nonwaivered_successful_creation(options={})
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',0){
		assert_difference('PhoneNumber.count',0){
		assert_difference('Addressing.count',1){
		assert_difference('Address.count',1){
		assert_difference('Enrollment.count',2){	#	both child and mother
		assert_difference('Patient.count',1){
		assert_difference('StudySubject.count',2){
			post :create, minimum_nonwaivered_form_attributes(options)
		} } } } } } } #}
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

	def minimum_waivered_form_attributes(options={})
		{ 'study_subject' => Factory.attributes_for(:minimum_waivered_form_attributes
			) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def waivered_form_attributes(options={})
		{ 'study_subject' => Factory.attributes_for(:waivered_form_attributes
			) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def waivered_successful_creation(options={})
		successful_raf_creation { 
			post :create, waivered_form_attributes(options) }
	end

	def minimum_waivered_successful_creation(options={})
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',0){
		assert_difference('PhoneNumber.count',0){
		assert_difference('Addressing.count',0){
		assert_difference('Address.count',0){
		assert_difference('Enrollment.count',2){	#	both child and mother
		assert_difference('Patient.count',1){
		assert_difference('StudySubject.count',2){
			post :create, minimum_waivered_form_attributes(options)
		} } } } } } } #}
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

end	#	module RafTestHelper
ActiveSupport::TestCase.send(:include,RafTestHelper)
