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

	def father_ssn
		birth_data.order('created_at DESC').collect(&:father_ssn).collect(
			&:to_ssn).compact.first
	end
	def mother_ssn
		birth_data.order('created_at DESC').collect(&:mother_ssn).collect(
			&:to_ssn).compact.first
	end
	def derived_state_file_no_last6
		birth_data.order('created_at DESC').collect(&:derived_state_file_no_last6).compact.first
	end
	def derived_local_file_no_last6
		birth_data.order('created_at DESC').collect(&:derived_local_file_no_last6).compact.first
	end
	def hospital
		patient.try(:organization).try(:to_s)	#	use try so stays nil if nil
	end
	def hospital_key
		patient.try(:organization).try(:key)
	end
#	def diagnosis
#		patient.try(:diagnosis).try(:to_s)	#	use try so stays nil if nil
#	end
#	def other_diagnosis
#		patient.try(:other_diagnosis).try(:to_s)	#	use try so stays nil if nil
#	end
#	def ccls_consented
#		YNDK[ccls_enrollment.try(:consented)]
#	end
#	def ccls_is_eligible
#		YNDK[ccls_enrollment.try(:is_eligible)]
#	end
#	def ccls_assigned_for_interview_on
#		ccls_enrollment.try(:assigned_for_interview_at).try(:to_date)
#	end
#	def ccls_interview_completed_on
#		ccls_enrollment.try(:interview_completed_on)
#	end
#	def interviewed
#		ccls_enrollment.try(:interview_completed_on).present?
#	end
#	def patient_was_ca_resident_at_diagnosis
#		YNDK[patient.try(:was_ca_resident_at_diagnosis)]
#	end
#	def patient_was_previously_treated
#		YNDK[patient.try(:was_previously_treated)]
#	end
#	def patient_was_under_15_at_dx
#		YNDK[patient.try(:was_under_15_at_dx)]
#	end

	#
	#	NOTE what about 
	#
	#	matchingid,familyid,case_subjectid?
	#

	include Sunspotability

	self.all_sunspot_columns = [
		SunspotColumn.new( :id, 
			:default => true, :type => :integer ),
		SunspotColumn.new( :subject_type, 
			:facetable => true, :default => true ),
		SunspotColumn.new( :vital_status, 
			:facetable => true, :default => true ),
		SunspotColumn.new( :case_control_type, 
			:facetable => true ),
		SunspotColumn.new( :sex, 
			:facetable => true, :default => true ),
		SunspotColumn.new( :phase,
			:facetable => true, :type => :integer ),

		#
		#	DON'T USE THE KEY :method IN AN OPENSTRUCT
		#
		#	Use subject_races and subject_languages so can get "Other"
		#
		SunspotColumn.new( :races, :meth => ->(s){ s.subject_races.collect(&:to_s) },
			:facetable => true, :type => :string, :multiple => true ),
		SunspotColumn.new( :languages, :meth => ->(s){ s.subject_languages.collect(&:to_s) },
			:facetable => true, :type => :string, :multiple => true ),
		SunspotColumn.new( :hospital, 
			:facetable => true ),
		SunspotColumn.new( :diagnosis, 
			:facetable => true ),
		SunspotColumn.new( :other_diagnosis ),
		SunspotColumn.new( :sample_types, :meth => ->(s){ s.samples.collect(&:sample_type).collect(&:to_s) },
			:facetable => true, :type => :string, :multiple => true ),
		SunspotColumn.new( :operational_event_types,
			:meth => ->(s){ s.operational_events.collect(&:operational_event_type).collect(&:to_s) },
			:facetable => true, :type => :string, :multiple => true ),
		SunspotColumn.new( :ccls_consented, :label => 'Consented?',
			:meth => ->(s){ YNDK[s.ccls_enrollment.try(:consented)]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :ccls_is_eligible, :label => 'Is Eligible?',
			:meth => ->(s){ YNDK[s.ccls_enrollment.try(:is_eligible)]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :interviewed, 
			:meth => ->(s){ s.ccls_enrollment.try(:interview_completed_on).present? ? 'Yes' : 'No' },
			:facetable => true, :type => :string ),
#		normal boolean method ... { ( (c.name).nil? ) ? 'NULL' : ( send(c.name) ) ? 'Yes' : 'No' }
#			:facetable => true, :type => :boolean ),
		SunspotColumn.new( :patient_was_ca_resident_at_diagnosis,
			:meth  => ->(s){ YNDK[s.patient.try(:was_ca_resident_at_diagnosis)]||'NULL' },
			:label => 'Was CA Resident at Diagnosis?',
			:facetable => true, :type => :string ),
		SunspotColumn.new( :patient_was_previously_treated,
			:meth  => ->(s){ YNDK[s.patient.try(:was_previously_treated)]||'NULL' },
			:label => 'Was Previously Treated?',
			:facetable => true, :type => :string ),
		SunspotColumn.new( :patient_was_under_15_at_dx,
			:label => 'Was Under 15 at Diagnosis?',
			:meth => ->(s){ YNDK[s.patient.try(:was_under_15_at_dx)]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :icf_master_id, 
			:default => true ),
		SunspotColumn.new( :case_icf_master_id, 
			:default => true ),
		SunspotColumn.new( :mother_icf_master_id, 
			:default => true ),
		SunspotColumn.new( :dob, 
			:default => true, :type => :date ),
		SunspotColumn.new( :first_name, 
			:default => true ),
		SunspotColumn.new( :last_name, 
			:default => true ),
		SunspotColumn.new( :primary_phone ),
		SunspotColumn.new( :alternate_phone ),
		SunspotColumn.new( :address_street ),
		SunspotColumn.new( :address_unit ),
		SunspotColumn.new( :address_city ),
		SunspotColumn.new( :address_state ),
		SunspotColumn.new( :address_zip ),
#	do_not_contact has default false set. will only be true or false
		SunspotColumn.new( :do_not_contact, 
			:meth => ->(s){ s.do_not_contact? ? 'Yes' : 'No' },
			:type => :string ),
#			:type => :boolean ),
		SunspotColumn.new( :birth_year, 
			:type => :integer ),
		SunspotColumn.new( :reference_date, 
			:type => :date ),
		SunspotColumn.new( :died_on, 
			:type => :date ),
		SunspotColumn.new( :admit_date, 
			:type => :date ),
		SunspotColumn.new( :ccls_assigned_for_interview_on, 
			:meth => ->(s){ s.ccls_enrollment.try(:assigned_for_interview_at).try(:to_date) },
			:type => :date ),
		SunspotColumn.new( :ccls_interview_completed_on, 
			:meth => ->(s){ s.ccls_enrollment.try(:interview_completed_on) },
			:type => :date ),
		SunspotColumn.new( :studyid ),
		SunspotColumn.new( :mother_first_name ),
		SunspotColumn.new( :mother_maiden_name ),
		SunspotColumn.new( :mother_last_name ),
		SunspotColumn.new( :father_first_name ),
		SunspotColumn.new( :father_last_name ),
		SunspotColumn.new( :middle_name ),
		SunspotColumn.new( :maiden_name ),
		SunspotColumn.new( :father_ssn ),
		SunspotColumn.new( :mother_ssn ),
		SunspotColumn.new( :patid ),
		SunspotColumn.new( :childid ),
		SunspotColumn.new( :subjectid ),
		SunspotColumn.new( :hospital_key ),
		SunspotColumn.new( :hospital_no ),
		SunspotColumn.new( :state_id_no ),
		SunspotColumn.new( :state_registrar_no ),
		SunspotColumn.new( :local_registrar_no ),
		SunspotColumn.new( :cdcid, 
			:type => :integer ),
		SunspotColumn.new( :derived_local_file_no_last6,
			:type => :integer ),
		SunspotColumn.new( :derived_state_file_no_last6,
			:type => :integer )
	]	#	self.all_sunspot_columns = [

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
	searchable_plus do	#	adding text search

#		string :races, :multiple => true do
#			races.collect(&:to_s)
#		end
#		string :languages, :multiple => true do
#			languages.collect(&:to_s)
#		end

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

#		string :sample_types, :multiple => true do
#			samples.collect(&:sample_type).collect(&:to_s)
#		end
#
#		string :operational_event_types, :multiple => true do
#			operational_events.collect(&:operational_event_type).collect(&:to_s)
#		end






	#
	#	Uncomment if want full text searching
	#	I don't use it now so ...
	#
		text :first_name
		text :middle_name
		text :maiden_name
		text :last_name
	#	text :mother_first_name
	#	text :mother_middle_name
	#	text :mother_maiden_name
	#	text :mother_last_name
	#	text :father_first_name
	#	text :father_middle_name
	#	text :father_last_name
	#	text :guardian_first_name
	#	text :guardian_middle_name
	#	text :guardian_last_name
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
	end 	#	if Sunspot::Rails::Server.new.running?
	#
	#	This condition is temporary, but does mean
	#	that the server must be started FIRST.
	#


	#
	#	Add something like ...
	#	to associations that contain indexed data?
	#
	#  belongs_to :parent
	#
	#  after_save :reindex_parent!
	#
	#  def reindex_parent!
	#    parent.index
	#  end


	#	bundle exec rake sunspot:solr:start # or sunspot:solr:run to start in foreground


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



require 'factory_girl'
$LOAD_PATH << 'test'
require 'factories'

bundle exec rake sunspot:solr:start
bundle exec rake sunspot:solr:reindex


