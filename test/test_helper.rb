ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
	fixtures :all

#			:race_ids => [Race.random.id],
	def complete_case_subject_attributes(options={})
#	MUST use strings for keys and NOT symbols due to to_hash
#	conversion for deep_merging
		Factory.attributes_for(:subject,
			'subject_type_id' => SubjectType['Case'].id,
			'subject_races_attributes' => {
				"0"=>{"race_id"=>"1"} },
			'subject_languages_attributes' => {
				"0"=>{"language_id"=>"1"} },
			'pii_attributes' => Factory.attributes_for(:pii),
			'patient_attributes' => Factory.attributes_for(:patient),
			'identifier_attributes' => Factory.attributes_for(:identifier),
			'phone_numbers_attributes' => [Factory.attributes_for(:phone_number)],
			'addressings_attributes' => [Factory.attributes_for(:addressing,
				'address_attributes' => Factory.attributes_for(:address,
					'address_type_id' => AddressType['residence'].id ) )],
			'enrollments_attributes' => [Factory.attributes_for(:enrollment,
				'project_id' => Project['non-specific'].id)]
		).deep_merge(options)
	end

	def assert_all_differences(count=0,&block)
		assert_difference('Subject.count',count){
		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',count){
		assert_difference('Identifier.count',count){
		assert_difference('Patient.count',count){
		assert_difference('Pii.count',count){
		assert_difference('Enrollment.count',count){
		assert_difference('PhoneNumber.count',count){
		assert_difference('Addressing.count',count){
		assert_difference('Address.count',count){
			yield
		} } } } } } } } } }
	end


end

class ActionController::TestCase
	setup :turn_https_on

	def self.site_administrators
		@site_administrators ||= %w( superuser administrator )
	end

	def self.non_site_administrators
		@non_site_administrators ||= ( all_test_roles - site_administrators )
	end

	def self.site_editors
		@site_editors ||= %w( superuser administrator editor )
	end

	def self.non_site_editors
		@non_site_editors ||= ( all_test_roles - site_editors )
	end

	def self.site_readers
		@site_readers ||= %w( superuser administrator editor interviewer reader )
	end

	def self.non_site_readers
		@non_site_readers ||= ( all_test_roles - site_readers )
	end

	def self.all_test_roles
		@all_test_roles = %w( superuser administrator editor interviewer reader active_user )
	end

end
