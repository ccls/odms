class ActiveSupport::TestCase

#			:race_ids => [Race.random.id],
	def complete_case_study_subject_attributes(options={})
#	MUST use strings for keys and NOT symbols due to to_hash
#	conversion for deep_merging
		{ 'study_subject' => Factory.attributes_for(:study_subject,
#			'subject_type_id' => SubjectType['Case'].id,
#	NOT on the form or currently required
#			'subject_races_attributes' => {
#				"0"=>{"race_id"=>"1"} },
			'subject_languages_attributes' => {
				"0"=>{"language_id"=>"1"} },
			'pii_attributes' => Factory.attributes_for(:pii),
			'patient_attributes' => Factory.attributes_for(:patient),
			'identifier_attributes' => Factory.attributes_for(:identifier),
			'phone_numbers_attributes' => {
				'0' => Factory.attributes_for(:phone_number) },
#				'phone_type_id' => PhoneType['home'].id )},
			'addressings_attributes' => {
				'0' => Factory.attributes_for(:addressing,
				'address_attributes' => Factory.attributes_for(:address) ) },
#					'address_type_id' => AddressType['residence'].id ) )},
			'enrollments_attributes' => {
				'0' => Factory.attributes_for(:enrollment) }
#				'project_id' => Project['non-specific'].id)}
#		) }.deep_merge(options)
		) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
	end

	def assert_all_differences(count=0,&block)
		assert_difference('StudySubject.count',count){
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',count){
		assert_difference('Identifier.count',count){
		assert_difference('Patient.count',count){
		assert_difference('Pii.count',count){
		assert_difference('Enrollment.count',count){
		assert_difference('PhoneNumber.count',count){
		assert_difference('Addressing.count',count){
		assert_difference('Address.count',count){
			yield
		} } } } } } } } } #}
	end

	def successful_raf_creation(&block)
		assert_difference('StudySubject.count',2){
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',1){
		assert_difference('Identifier.count',2){
		assert_difference('Patient.count',1){
		assert_difference('Pii.count',2){
		assert_difference('Enrollment.count',2){	#	subject AND mother
		assert_difference('PhoneNumber.count',1){
		assert_difference('Addressing.count',1){
		assert_difference('Address.count',1){
			yield
		} } } } } } } } } #}
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

	def minimum_successful_raf_creation(&block)
		assert_difference('Enrollment.count',2){	#	both child and mother
		assert_difference('Pii.count',2){
		assert_difference('Patient.count',1){
		assert_difference('Identifier.count',2){
		assert_difference('StudySubject.count',2){
			yield
		} } } } }
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

end
