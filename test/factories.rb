def random_pos_neg
	[nil,1,2][rand(3)]
end
def random_true_or_false
	[true,false][rand(2)]
end
def random_yndk
	[nil,1,2,999][rand(4)]
end
def random_date
	Date.jd( 2440000 + rand(15000) )
end
def random_float
	rand * 100
end
def random_sex
	%w( M F )[rand(2)]
end
	
FactoryBot.define do
	#
	#	Note the double {} around *_attributes. One for the hash and one for the proc.
	#
	#	These factories (the non-minimum ones) should ONLY include those fields 
	#	actually on the RAF forms so I should probably NOT use the FactoryBot.attributes_for
	#	method for the other factories.  For now, I do though as they actually do only 
	#	include those fields.
	#
	factory :minimum_raf_form_attributes, :class => 'StudySubject' do |f|
		f.sex "M" 
		#	Always want this date between yesterday and <15 years ago
		#	as default was_under_15 is Yes and admit_date is Today.
		f.dob { Date.jd( ((Date.current - 14.years).jd)+ rand(5000)).to_s }	# like this
		f.patient_attributes { FactoryBot.attributes_for(:waivered_patient) }
	end
	factory :raf_form_attributes, :parent => :minimum_raf_form_attributes do |f|
		f.first_name ''
		f.middle_name ''
		f.last_name ''
		f.mother_first_name ''
		f.mother_middle_name ''
		f.mother_last_name ''
		f.mother_maiden_name ''
		f.father_first_name ''
		f.father_middle_name ''
		f.father_last_name ''
		f.guardian_relationship ''
		f.other_guardian_relationship ''
		f.guardian_first_name ''
		f.guardian_middle_name ''
		f.guardian_last_name ''
		f.subject_languages_attributes {{
			"0"=>{"language_code"=>"1"}, 
			"1"=>{"language_code"=>""}, 
			"2"=>{"language_code"=>"", "other_language"=>""} }}
		f.addresses_attributes {{
			"0"=> FactoryBot.attributes_for(:address) }}
		f.phone_numbers_attributes {{
			"0"=> FactoryBot.attributes_for(:phone_number),
			"1"=>{"phone_number"=>""} }}
		f.patient_attributes { FactoryBot.attributes_for(:waivered_patient,{
			"raf_zip" => '12345',
			"raf_county" => "some county, usa",
			"was_previously_treated"=> YNDK[:no].to_s,
			"admitting_oncologist"=>"", 
			"was_under_15_at_dx"=> YNDK[:yes].to_s,
			"was_ca_resident_at_diagnosis"=> YNDK[:yes].to_s
		}) }
		f.enrollments_attributes {{
			"0"=>{
				"project_id"=>"10",
				"other_refusal_reason"=>"", 
				"consented_on"=>"", 
				"refusal_reason_id"=>""
			}
		}}
	end
	
	
	#	ruby 1.9.3 really doesn't like rand() for some reason
	#	TypeError: no implicit conversion from nil to integer
	#	TypeError: nil can't be coerced into Fixnum
	
	#	This is no longer used in this gem, but is used in the apps
	factory :page do |f|
		f.sequence(:path)    { |n| "/path#{n}" }
		f.sequence(:menu_en) { |n| "Menu #{n}" }
		f.sequence(:title_en){ |n| "Title #{n}" }
		f.body_en  "Page Body"
	end
	
	factory :user do |f|
		f.sequence(:uid) { |n| "UID#{n}" }
	end
	
	factory :role do |f|
		f.sequence(:name) { |n| "name#{n}" }
	end
	


	factory :abstract do |f|
		f.association :study_subject, :factory => :case_study_subject
	end

	factory :address do |f|
		f.association :study_subject
		f.address_type 'Residence'
		f.sequence(:line_1) { |n| "Box #{n}" }
		f.city "Berkeley"
		f.state "CA"
		f.zip "12345"
		f.data_source 'RAF (CCLS Rapid Ascertainment Form)'
	end
	factory :blank_line_1_address, :parent => :address do |f|
		f.line_1 ""
	end
	factory :mailing_address, :parent => :address do |f|
		f.address_type 'Mailing'
		f.current_address { YNDK[:no] }
	end
	factory :current_mailing_address, :parent => :mailing_address do |f|
		f.address_type 'Mailing'
		f.current_address { YNDK[:yes] }
	end
	factory :residence_address, :parent => :address do |f|
		f.address_type 'Residence'
		f.current_address { YNDK[:no] }
	end
	factory :current_residence_address, :parent => :residence_address do |f|
		f.address_type 'Residence'
		f.current_address { YNDK[:yes] }
	end
	
	factory :alternate_contact do |f|
		f.association :study_subject
	end

	factory :bc_request do |f|
		f.sequence(:notes) { |n| "Notes#{n}" }	#	forces an update
	end
	
	factory :blood_spot_request do |f|
		f.sequence(:notes) { |n| "Notes#{n}" }	#	forces an update
	end
	
	factory :birth_datum do |f|
	#
	#	These are not required, but without them, conversion to subject will fail
	#
		f.sequence(:dob) { random_date }
		f.sequence(:sex) { random_sex }
	end
	factory :case_birth_datum, :parent => :birth_datum do |f|
		f.case_control_flag 'case'
		f.match_confidence 'definite'
	end
	factory :control_birth_datum, :parent => :birth_datum do |f|
		f.case_control_flag 'control'
	end
	factory :bogus_birth_datum, :parent => :birth_datum do |f|
		f.case_control_flag 'bogus'
	end
	
	factory :candidate_control do |f|
		f.reject_candidate false
	end
	factory :rejected_candidate_control, :parent => :candidate_control do |f|
		f.reject_candidate true
		f.rejection_reason "Some test reason"
	end
	
	factory :county do |f|
		f.sequence(:name){ |n| "Name #{n}" }
		f.state_abbrev 'XX'
	end
	
	factory :subjectless_enrollment, :class => 'Enrollment' do |f|
		f.association :project
	end
	factory :enrollment, :parent => :subjectless_enrollment do |f|
		f.association :study_subject
	end
	factory :eligible_enrollment, :parent => :enrollment do |f|
		f.is_eligible   { YNDK[:yes] }	#1	#true
	end
	factory :consented_enrollment, :parent => :enrollment do |f|
		f.consented   { YNDK[:yes] }	#1	#true
		f.consented_on Date.yesterday
	end
	factory :declined_enrollment, :parent => :enrollment do |f|
		f.consented   { YNDK[:no] }	#	2
		f.consented_on Date.yesterday
		f.association :refusal_reason
	end
	
	factory :guide do |f|
		f.sequence(:controller){ |n| "controller#{n}" }
		f.sequence(:action)    { |n| "action#{n}" }
		f.sequence(:body)      { |n| "Body #{n}" }
	end
	
	factory :hospital do |f|
		f.association :organization
	end
	factory :waivered_hospital, :parent => :hospital do |f|
		f.has_irb_waiver true
	end
	factory :nonwaivered_hospital, :parent => :hospital do |f|
		f.has_irb_waiver false
	end
	
	factory :icf_master_id do |f|
	end
	
	factory :ineligible_reason do |f|
		f.sequence(:key)         { |n| "Key#{n}" }
		f.sequence(:description) { |n| "Desc#{n}" }
	end
	
	factory :medical_record_request do |f|
		f.sequence(:notes) { |n| "Notes#{n}" }	#	forces an update
	end
	
	factory :language do |f|
		f.sequence(:code)        { |n| 1000 + n }	#	fixtures go up to 999
		f.sequence(:key)         { |n| "Key#{n}" }
		f.sequence(:description) { |n| "Desc#{n}" }
	end
	
	factory :operational_event do |f|
	end
	
	factory :operational_event_type do |f|
		f.sequence(:key)            { |n| "Key#{n}" }
		f.sequence(:description)    { |n| "Desc#{n}" }
		f.sequence(:event_category) { |n| "Cat#{n}" }
	end
	
	factory :organization do |f|
		f.sequence(:key)  { |n| "Key #{n}" }
		f.sequence(:name) { |n| "Name #{n}" }
	end
	
	factory :subjectless_patient, :class => 'Patient' do |f|
		#	Today should always be after the dob.
		#	However, with all of the date chronology tests, still may cause problems.
		f.admit_date Date.current	
	
		#	in order to test presence or uniqueness, MUST BE HERE
		f.sequence(:hospital_no){|n| "#{n}"}	
	
		#	Doing it this way will actually include organization_id 
		f.sequence(:organization_id){|n| 
			Hospital.active()[ n % Hospital.active.count ].organization_id }
	
		f.diagnosis 'ALL'
	end
	factory :patient, :parent => :subjectless_patient do |f|
		#	really don't see the point of a patient w/o a study_subject
		f.association :study_subject, :factory => :case_study_subject
	end
	factory :waivered_patient, :parent => :patient do |f|
		f.sequence(:organization_id){|n| 
			Hospital.active.waivered()[ n % Hospital.active.waivered.length ].organization_id }
	end
	factory :nonwaivered_patient, :parent => :patient do |f|
		f.sequence(:organization_id){|n| 
			Hospital.active.nonwaivered()[ n % Hospital.active.nonwaivered.length ].organization_id }
	end
	
	factory :phone_number do |f|
		f.association :study_subject
		f.phone_type 'Home'
		f.data_source 'RAF (CCLS Rapid Ascertainment Form)'
		f.sequence(:phone_number){|n| sprintf("%010d",n) }
	end
	factory :primary_phone_number, :parent => :phone_number do |f|
		f.is_primary true
	end
	factory :alternate_phone_number, :parent => :phone_number do |f|
		f.is_primary false
	end
	factory :current_phone_number, :parent => :phone_number do |f|
		f.current_phone YNDK[:yes]
	end
	factory :current_primary_phone_number, :parent => :current_phone_number do |f|
		f.is_primary true
	end
	factory :current_alternate_phone_number, :parent => :current_phone_number do |f|
		f.is_primary false
	end
	
	factory :project do |f|
		f.sequence(:key)         { |n| "Key#{n}" }
		f.sequence(:label)       { |n| "Label#{n}" }
		f.sequence(:description) { |n| "Desc#{n}" }
	end
	
	factory :race do |f|
		f.sequence(:code)       {|n| 1000 + n }	#	fixtures go up to 999
		f.sequence(:key)        {|n| "Key#{n}"}
		f.sequence(:description){|n| "Desc#{n}"}
	end
	
	factory :refusal_reason do |f|
		f.sequence(:key)         { |n| "Key#{n}" }
		f.sequence(:description) { |n| "Desc#{n}" }
	end
	
	factory :sample do |f|
		f.association :study_subject
		f.association :project
		f.association :sample_type
	end
	
	factory :sample_location do |f|
		f.association :organization
	end
	
	factory :sample_outcome do |f|
		f.sequence(:key) { |n| "Key#{n}" }
		f.sequence(:description) { |n| "Desc#{n}" }
	end
	
	factory :sample_transfer do |f|
		f.association :sample
	end
	factory :active_sample_transfer, :parent => :sample_transfer do |f|
		f.status 'active'
	end
	factory :waitlist_sample_transfer, :parent => :sample_transfer do |f|
		f.status 'waitlist'
	end
	
	factory :sample_type do |f|
		f.sequence(:key)         { |n| "Key#{n}" }
		f.sequence(:description) { |n| "Desc#{n}" }
		f.association :parent, :factory => :sample_type_parent
	end
	factory :sample_type_parent, :parent => :sample_type do |f|
		f.parent nil
	end
	
	factory :state do |f|
		f.sequence(:code) { |n| "Code#{n}" }
		f.sequence(:name) { |n| "Name#{n}" }
		f.sequence(:fips_state_code){|n|
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')[n/26] <<
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')[n%26] }
		f.fips_country_code 'US'
	end
	
	factory :raf_study_subject, :class => 'StudySubject'  do |f|
		f.sequence(:sex) { random_sex }
		f.sequence(:dob) { random_date }
	end
	factory :study_subject do |f|
		f.subject_type 'Control'
		f.sequence(:sex) { random_sex }
		f.sequence(:dob) { random_date }
		f.sequence(:case_control_type){|n| '123456789'.split('')[n%9] }
		f.sequence(:do_not_use_state_id_no){|n| "#{n}"}
		f.sequence(:do_not_use_state_registrar_no){|n| "#{n}"}
		f.sequence(:do_not_use_local_registrar_no){|n| "#{n}"}
	end
	factory :case_study_subject, :parent => :study_subject do |f|
		f.subject_type 'Case'
		f.case_control_type 'c'
	end
	factory :complete_case_study_subject, :parent => :case_study_subject do |f|
		#	wrap in {} so is a proc/lambda and runs at runtime NOT at definition
		#	when the fixtures have been loaded and these will work.
		#	Only really needed for patient as gets Hospital and Diagnosis.
	
		f.patient_attributes { FactoryBot.attributes_for(:patient) }
	end
	factory :complete_waivered_case_study_subject, :parent => :complete_case_study_subject do |f|
		f.patient_attributes { FactoryBot.attributes_for(:waivered_patient) }
	end
	factory :complete_nonwaivered_case_study_subject, :parent => :complete_case_study_subject do |f|
		f.patient_attributes { FactoryBot.attributes_for(:nonwaivered_patient) }
	end
	factory :control_study_subject, :parent => :study_subject do |f|
		f.subject_type 'Control'
	end
	factory :complete_control_study_subject, :parent => :control_study_subject do |f|
	end
	factory :mother_study_subject, :parent => :study_subject do |f|
		f.subject_type 'Mother'
		f.sex 'F'
		f.case_control_type 'm'
	end
	factory :complete_mother_study_subject, :parent => :mother_study_subject do |f|
	end
	
	factory :father_study_subject, :parent => :study_subject do |f|
		f.subject_type 'Father'
	end
	factory :twin_study_subject, :parent => :study_subject do |f|
		f.subject_type 'Twin'
	end
	
	factory :subject_language do |f|
		f.association :study_subject
		f.association :language
	end
	
	factory :subject_race do |f|
		f.association :study_subject
		f.association :race
	end
	
	factory :zip_code do |f|
		f.sequence(:zip_code){ |n| sprintf("X%04d",n) }
		f.sequence(:city){ |n| sprintf("%05d",n) }
		f.sequence(:state){ |n| sprintf("%05d",n) }
		f.zip_class "TESTING"
	end
	
	
	#	simply putting calls in {} no longer delays execution
	#	seems like must use "sequence" even if ignoring
	#	the operator in ruby 1.9.3.
	#
	#	there is probably a better way, but I suspect that this'll work for now.
	#	
	#	this only seems to be a problem with random_sex and random_date?
	#
	#	this makes no sense.
	#
	#	I undid this and everything works again?  So confused.
	#
	#	it seems that in "script/rails console test" the "sequencing"
	#	is not needed, however, in the actual tests it is????
	#
	#	Using sequence for all random_* calls
end
