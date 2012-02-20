#
#	Note the double {} around *_attributes. One for the hash and one for the proc.
#
#	These factories (the non-minimum ones) should ONLY include those fields 
#	actually on the RAF forms so I should probably NOT use the Factory.attributes_for
#	method for the other factories.  For now, I do though as they actually do only 
#	include those fields.
#
Factory.define :minimum_raf_form_attributes, :class => 'StudySubject' do |f|
	f.sex "M" 
	f.dob Date.jd(2440000+rand(15000)).to_s
end
Factory.define :minimum_nonwaivered_form_attributes, :parent => :minimum_raf_form_attributes do |f|
	f.addressings_attributes {{ "0"=>{ "address_attributes"=> Factory.attributes_for(:address) } }}
	f.patient_attributes { Factory.attributes_for(:nonwaivered_patient) }
end
Factory.define :nonwaivered_form_attributes, :parent => :minimum_nonwaivered_form_attributes do |f|
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
	f.guardian_relationship_id ''
	f.guardian_relationship_other ''
	f.guardian_first_name ''
	f.guardian_middle_name ''
	f.guardian_last_name ''
	f.addressings_attributes {{ 
		"0"=>{ "address_attributes"=> Factory.attributes_for(:address) } }}
	f.subject_languages_attributes {{
		"0"=>{"language_id"=>"1"}, "1"=>{"language_id"=>""}}}
	f.phone_numbers_attributes {{
		"0"=>{"phone_number"=>"1234567890" }, 
		"1"=>{"phone_number"=>""}
	}}
	f.patient_attributes { Factory.attributes_for(:nonwaivered_patient,{
		"sample_was_collected"=>"1",				
		"was_previously_treated"=> YNDK[:no].to_s,
		"admitting_oncologist"=>"", 
		"was_under_15_at_dx"=> YNDK[:yes].to_s,
		"was_ca_resident_at_diagnosis"=> YNDK[:yes].to_s
	})}
	f.enrollments_attributes {{
		"0"=>{
			"consented_on"=>"", 
			"document_version_id"=>""
		}
	}}
end

Factory.define :minimum_waivered_form_attributes, :parent => :minimum_raf_form_attributes do |f|
	f.patient_attributes { Factory.attributes_for(:waivered_patient) }
end
Factory.define :waivered_form_attributes, :parent => :minimum_waivered_form_attributes do |f|
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
	f.guardian_relationship_id ''
	f.guardian_relationship_other ''
	f.guardian_first_name ''
	f.guardian_middle_name ''
	f.guardian_last_name ''
	f.subject_languages_attributes {{
		"0"=>{"language_id"=>"1"}, 
		"1"=>{"language_id"=>""}, 
		"2"=>{"language_id"=>"", "other"=>""} }}
	f.addressings_attributes {{
		"0"=>{ "address_attributes"=> Factory.attributes_for(:address) } }}
	f.phone_numbers_attributes {{
		"0"=>{"phone_number"=>"1234567890"}, "1"=>{"phone_number"=>""} }}
	f.patient_attributes { Factory.attributes_for(:waivered_patient,{
		"raf_zip" => '12345',
		"raf_county" => "some county, usa",
		"was_previously_treated"=> YNDK[:no].to_s,
		"admitting_oncologist"=>"", 
		"was_under_15_at_dx"=> YNDK[:yes].to_s,
		"was_ca_resident_at_diagnosis"=> YNDK[:yes].to_s
	}) }
	f.enrollments_attributes {{
##	consented does not have a default value, so can send nothing if one button not checked
##	TODO add consented field
		"0"=>{
			"other_refusal_reason"=>"", 
			"consented_on"=>"", 
			"document_version_id"=>"", 
			"refusal_reason_id"=>""
		}
	}}
end
