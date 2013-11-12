#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectSunspot
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	def newest_birth_data
		@newest_birth_data ||= birth_data.order('created_at DESC')
	end
#	def father_ssn
#		newest_birth_data.collect(&:father_ssn).collect(&:to_ssn).compact.first
#	end
#	def mother_ssn
#		newest_birth_data.collect(&:mother_ssn).collect(&:to_ssn).compact.first
#	end

	#	is indexed as text too, so NEED actual method (at least for now)
	def derived_state_file_no_last6
		newest_birth_data.collect(&:derived_state_file_no_last6).compact.first
	end
	#	is text so NEED actual method (at least for now)
	def derived_local_file_no_last6
		newest_birth_data.collect(&:derived_local_file_no_last6).compact.first
	end


	#
	#	thought of adding birth_type, but is in StudySubject AND BirthDatum
	#

	def hospital
		patient.try(:organization).try(:to_s)	#	use try so stays nil if nil
	end
	def hospital_key
		patient.try(:organization).try(:key)
	end

	#
	#	NOTE what about 
	#
	#	matchingid,familyid,case_subjectid?
	#

	include Sunspotability

	add_sunspot_column( :id, 
		:default => true, :type => :integer )
	add_sunspot_column( :subject_type, 
		:facetable => true, :default => true )
	add_sunspot_column( :vital_status, 
		:facetable => true, :default => true )
	add_sunspot_column( :case_control_type, 
		:facetable => true )
	add_sunspot_column( :sex, 
		:facetable => true, :default => true )
	add_sunspot_column( :phase,
		:facetable => true, :type => :integer )

	#
	#	DON'T USE THE KEY :method IN AN OPENSTRUCT
	#
	#	Use subject_races and subject_languages so can get "Other"
	#
	add_sunspot_column( :races, :meth => ->(s){ s.subject_races.collect(&:to_s) },
		:facetable => true, :type => :string, :multiple => true )
	add_sunspot_column( :languages, :meth => ->(s){ s.subject_languages.collect(&:to_s) },
		:facetable => true, :type => :string, :multiple => true )

	add_sunspot_column( :projects, :meth => ->(s){ s.enrollments.collect(&:project) },
		:facetable => true, :type => :string, :multiple => true )

	add_sunspot_column( :hospital, 
		:facetable => true )
	add_sunspot_column( :diagnosis, 
		:facetable => true )
	add_sunspot_column( :other_diagnosis )
	add_sunspot_column( :sample_types, :meth => ->(s){ s.samples.collect(&:sample_type).collect(&:to_s) },
		:facetable => true, :type => :string, :multiple => true )
	add_sunspot_column( :operational_event_types,
		:meth => ->(s){ s.operational_events.collect(&:operational_event_type).collect(&:to_s) },
		:facetable => true, :type => :string, :multiple => true )
	add_sunspot_column( :ccls_consented, :label => 'Consented?',
		:meth => ->(s){ YNDK[s.ccls_enrollment.try(:consented)]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ccls_is_eligible, :label => 'Is Eligible?',
		:meth => ->(s){ YNDK[s.ccls_enrollment.try(:is_eligible)]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :interviewed, 
		:meth => ->(s){ s.ccls_enrollment.try(:interview_completed_on).present? ? 'Yes' : 'No' },
		:facetable => true, :type => :string )
	add_sunspot_column( :patient_was_ca_resident_at_diagnosis,
		:meth  => ->(s){ YNDK[s.patient.try(:was_ca_resident_at_diagnosis)]||'NULL' },
		:label => 'Was CA Resident at Diagnosis?',
		:facetable => true, :type => :string )
	add_sunspot_column( :patient_was_previously_treated,
		:meth  => ->(s){ YNDK[s.patient.try(:was_previously_treated)]||'NULL' },
		:label => 'Was Previously Treated?',
		:facetable => true, :type => :string )
	add_sunspot_column( :patient_was_under_15_at_dx,
		:label => 'Was Under 15 at Diagnosis?',
		:meth => ->(s){ YNDK[s.patient.try(:was_under_15_at_dx)]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :icf_master_id, 
		:default => true )
	add_sunspot_column( :case_icf_master_id, 
		:default => true )
	add_sunspot_column( :mother_icf_master_id, 
		:default => true )
	add_sunspot_column( :dob, 
		:default => true, :type => :date )
	add_sunspot_column( :first_name, 
		:default => true )
	add_sunspot_column( :last_name, 
		:default => true )
	add_sunspot_column( :primary_phone )
	add_sunspot_column( :alternate_phone )
	add_sunspot_column( :address_street )
	add_sunspot_column( :address_unit )
	add_sunspot_column( :address_city )
	add_sunspot_column( :address_state )
	add_sunspot_column( :address_zip )

	add_sunspot_column( :location, 
		:type => :latlon, :orderable => false,
		:meth => ->(s){ Sunspot::Util::Coordinates.new(s.address_latitude, s.address_longitude) } )
	add_sunspot_column( :address_latitude, 
		:type => :float, :orderable => false )
	add_sunspot_column( :address_longitude, 
		:type => :float, :orderable => false )

	#	do_not_contact has default false set. will only be true or false
	add_sunspot_column( :do_not_contact, 
		:meth => ->(s){ s.do_not_contact? ? 'Yes' : 'No' },
		:type => :string )
	add_sunspot_column( :birth_year, 
		:type => :integer )
	add_sunspot_column( :reference_date, 
		:type => :date )
	add_sunspot_column( :died_on, 
		:type => :date )
	add_sunspot_column( :admit_date, 
		:type => :date )


	add_sunspot_column( :age_at_admittance, :type => :integer, :facetable => true,
		:meth => ->(s){( s.dob.blank? or s.admit_date.blank? ) ? nil : s.dob.diff(s.admit_date)[:years] })
	add_sunspot_column( :age_at_diagnosis, :type => :integer, :facetable => true,
		:meth => ->(s){( s.dob.blank? or s.diagnosis_date.blank? ) ? nil : s.dob.diff(s.diagnosis_date)[:years] })


	add_sunspot_column( :ccls_assigned_for_interview_on, 
		:meth => ->(s){ s.ccls_enrollment.try(:assigned_for_interview_at).try(:to_date).try(:strftime,'%m/%d/%Y') },
		:type => :date )
	add_sunspot_column( :ccls_interview_completed_on, 
		:meth => ->(s){ s.ccls_enrollment.try(:interview_completed_on).try(:strftime,'%m/%d/%Y') },
		:type => :date )
	add_sunspot_column( :studyid )
	add_sunspot_column( :mother_first_name )
	add_sunspot_column( :mother_maiden_name )
	add_sunspot_column( :mother_last_name )
	add_sunspot_column( :father_first_name )
	add_sunspot_column( :father_last_name )
	add_sunspot_column( :middle_name )
	add_sunspot_column( :maiden_name )
	add_sunspot_column( :father_ssn,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_ssn).collect(&:to_ssn).compact.first } )
	add_sunspot_column( :mother_ssn,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_ssn).collect(&:to_ssn).compact.first } )
	add_sunspot_column( :patid )
	add_sunspot_column( :childid )
	add_sunspot_column( :subjectid )
	add_sunspot_column( :hospital_key )
	add_sunspot_column( :hospital_no )
	add_sunspot_column( :state_id_no )
	add_sunspot_column( :state_registrar_no )
	add_sunspot_column( :local_registrar_no )
	add_sunspot_column( :cdcid, :type => :integer )
	add_sunspot_column( :derived_local_file_no_last6, :type => :integer )
#	add_sunspot_column( :derived_local_file_no_last6, :type => :integer,
#		:meth => ->(s){ s.newest_birth_data.collect(&:derived_local_file_no_last6).compact.first })
	add_sunspot_column( :derived_state_file_no_last6, :type => :integer )
#	add_sunspot_column( :derived_state_file_no_last6, :type => :integer,
#		:meth => ->(s){ s.newest_birth_data.collect(&:derived_state_file_no_last6).compact.first })

	add_sunspot_column( :mother_hispanic_origin_code, :type => :string, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_hispanic_origin_code).compact.first })
	add_sunspot_column( :mother_race_ethn_1, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_1).compact.first })
	add_sunspot_column( :mother_race_ethn_2, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_2).compact.first })
	add_sunspot_column( :mother_race_ethn_3, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_3).compact.first })

	add_sunspot_column( :father_hispanic_origin_code, :type => :string, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_hispanic_origin_code).compact.first })
	add_sunspot_column( :father_race_ethn_1, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_1).compact.first })
	add_sunspot_column( :father_race_ethn_2, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_2).compact.first })
	add_sunspot_column( :father_race_ethn_3, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_3).compact.first })


	add_sunspot_column( :current_address_count, :type => :integer, :facetable => true,
		:meth => ->(s){ s.addressings.current.count })
	add_sunspot_column( :current_address_at_dx, :type => :string, :facetable => true,
		:meth => ->(s){ YNDK[s.addressings.current.order('created_at DESC').first.try(:address_at_diagnosis)]||'NULL' })


	#
	#	DO NOT ALLOW BLANK VALUES INTO INDEX.  Only really a problem when faceting on blank values.
	#	However, if it is truely blank, my facet_for helper will deal with it, but can't select it.
	#	So, if blank is a desirable selection, will need to replace it with something as do
	#	with NULL in the nulled strings.  Don't know if can do that with non-string fields.
	#	Can I conditionally change the field?  If blank, string(c){ 'NULL' } else integer(c) ???? doubt it
	#
#
#	for example, what if I wanted all of the subjects that don't have a phase set?
#
#	searchable_plus #do

	#
	#	all_sunspot_columns must be set before calling this
	#
	searchable_plus do	#	adding text search


	#	develope a way to search for the NULLs and BLANKs
	#		I don't think that NULL actually gets "faceted"
	#	May have to explicitly assign it NULL or BLANK in index?

	# only letters, numbers, and underscores are allowed in field names

#		string :projects, :multiple => true do
#			enrollments.collect(&:project).collect(&:to_s)
#		end
#		Project.all.each do |project|
#	#
#	#	Is there a facet field name length limit?
#	#
#	#		#	This should be OUTSIDE the Project.all loop
#	#		string "Any_Project_consented", :multiple => true do
#	#			enrollments.collect{|e| YNDK[e.try(:consented)]||'NULL' }.uniq
#	#		end
#	#		string "#{project.html_friendly}_consented" do
#	#			YNDK[enrollments.where(:project_id => project.id).first.try(:consented)]||'NULL'
#	#		end
#	#		string "#{project.html_friendly}_is_eligible" do
#	#			YNDK[enrollments.where(:project_id => project.id).first.try(:is_eligible)]||'NULL'
#	#		end
#	#
#			self.sunspot_dynamic_columns << "#{project.to_s}:consented"
#			self.sunspot_dynamic_columns << "#{project.to_s}:is_eligible"
#			dynamic_string "hex_#{project.to_s.unpack('H*').first}" do
#				(enrollments.where(:project_id => project.id).first.try(:attributes) || {})
#					.select{|k,v|['consented','is_eligible'].include?(k) }
#					.inject({}){|h,pair| h.merge(pair[0] => YNDK[pair[1]]||'NULL') }
#			end
#		end



		text :first_name
		text :middle_name
		text :maiden_name
		text :last_name
		text :studyid
		text :icf_master_id
		text :childid
		text :patid
		text :hospital_no
		text :state_id_no
		text :state_registrar_no
		text :local_registrar_no
		text :subjectid
		text :cdcid
		text :derived_local_file_no_last6
		text :derived_state_file_no_last6

	end

end	#	class_eval
end	#	included
end	#	StudySubjectSunspot
__END__

Dynamic Fields

I wouldn’t be surprised if I’m the only person who ever uses this feature of Sunspot, but just in case, let’s look at a real-world example. Let’s say part of my data model uses free-form key-value pairs, which use a constrained (but user-definable) set of keys and free-form values. I’ll call my model KeyValuePairs.

The trick I would like to pull here is that I would like to treat each key as a separate field in search, so that I can constrain, order, facet, etc. on the values for one key without them being affected by other keys. Since the keys are user-defined, I can’t just set up normal fields at build time; they need to be defined at index time. Enter Sunspot’s dynamic fields (we’ll use Sunspot::Rails’s wrapper API here):

class Business < ActiveRecord::Base
  has_many :key_value_pairs


  searchable do
    dynamic_string :key_value_pairs do
      key_value_pairs.inject({}) do |hash, pair|
        hash.merge(pair.key.to_sym => pair.value)
      end
    end
  end
end

This sets up a dynamic field which is populated using the given block. What’s important there is that the field is populated using a hash - the keys of the hash become individual dynamic fields, and the values populate those fields in the index. The “base name” of the field is key_value_pairs, which is used to namespace the dynamic names that come out of the hash.

Working with dynamic fields is a lot like working with regular ones, except in the query, calls are wrapped in a dynamic block:

Business.search do
  dynamic :key_value_pairs do
    with(:cuisine, 'Sushi')
    facet(:atmosphere)
  end
end

Naturally, those field names (:cuisine, :atmosphere) wouldn’t be hard-coded in a real application, since they would not be known at build time.




bundle exec rake sunspot:solr:start
bundle exec rake sunspot:reindex

