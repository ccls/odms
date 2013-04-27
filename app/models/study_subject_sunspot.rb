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
		birth_data.order('created_at DESC').collect(&:father_ssn).collect(&:to_ssn).compact.first
	end
	def mother_ssn
		birth_data.order('created_at DESC').collect(&:mother_ssn).collect(&:to_ssn).compact.first
	end
	def hospital
		patient.try(:organization).try(:to_s)	#	use try so stays nil if nil
	end
	def hospital_key
		patient.try(:organization).try(:key)
	end
	def diagnosis
		patient.try(:diagnosis).try(:to_s)	#	use try so stays nil if nil
	end

#	def ccls_enrollment
#		enrollments.where(:project_id => Project['ccls'].id).first
#	end
	def ccls_consented
		YNDK[ccls_enrollment.try(:consented)]
	end
	def ccls_is_eligible
		YNDK[ccls_enrollment.try(:is_eligible)]
	end
	def ccls_assigned_for_interview_on
		ccls_enrollment.try(:assigned_for_interview_at).try(:to_date)
	end
	def ccls_interview_completed_on
		ccls_enrollment.try(:interview_completed_on)
	end
	def interviewed
		ccls_enrollment.try(:interview_completed_on).present?
	end

	def patient_was_ca_resident_at_diagnosis
		YNDK[patient.try(:was_ca_resident_at_diagnosis)]
	end
	def patient_was_previously_treated
		YNDK[patient.try(:was_previously_treated)]
	end
	def patient_was_under_15_at_dx
		YNDK[patient.try(:was_under_15_at_dx)]
	end


#	cattr_accessor :sunspot_dynamic_columns
#	self.sunspot_dynamic_columns = []

#			patient_was_ca_resident_at_diagnosis
#			patient_was_previously_treated
#			patient_was_under_15_at_dx
	
	#
	#	NOTE what about 
	#
	#	matchingid,familyid,case_subjectid?
	#
	
	
#	def self.sunspot_string_columns
#		@@sunspot_string_columns ||= %w(
#			case_icf_master_id mother_icf_master_id icf_master_id
#			subject_type vital_status case_control_type
#			sex studyid
#			mother_first_name mother_maiden_name mother_last_name
#			father_first_name father_last_name
#			first_name middle_name maiden_name last_name
#			father_ssn mother_ssn
#			patid subjectid hospital_key
#			diagnosis hospital hospital_no
#			languages races
#			state_id_no state_registrar_no local_registrar_no
#		)
#	end
#	def self.sunspot_nulled_string_columns
#		@@sunspot_nulled_string_columns ||= %w(
#			ccls_consented ccls_is_eligible
#			patient_was_ca_resident_at_diagnosis
#			patient_was_previously_treated
#			patient_was_under_15_at_dx
#		)
#	end
#	def self.sunspot_time_columns
#		@@sunspot_time_columns ||= []
#	end
#	def self.sunspot_date_columns
#		@@sunspot_date_columns ||= %w( reference_date dob died_on admit_date 
#			ccls_assigned_for_interview_on ccls_interview_completed_on
#		)
#	end
#	def self.sunspot_integer_columns
#		@@sunspot_integer_columns ||= %w( id phase birth_year  )
#	end
#	def self.sunspot_boolean_columns
#		@@sunspot_boolean_columns ||= %w( do_not_contact interviewed )
#	end
#	def self.sunspot_double_columns
#		@@sunspot_double_columns ||= []
#	end
#	def self.sunspot_unindexed_columns
#		@@sunspot_unindexed_columns ||= %w( 
#			primary_phone alternate_phone 
#			address_street address_city address_state address_zip
#		)
#	end
#	def self.sunspot_default_columns
#		%w( id case_icf_master_id mother_icf_master_id icf_master_id 
#			subject_type vital_status sex dob 
#			first_name last_name)
#	end
#	def self.sunspot_columns
#		@@sunspot_columns ||= [sunspot_string_columns].compact.flatten +
#			[sunspot_nulled_string_columns].compact.flatten +
#			[sunspot_time_columns].compact.flatten +
#			[sunspot_date_columns].compact.flatten +
#			[sunspot_integer_columns].compact.flatten +
#			[sunspot_double_columns].compact.flatten +
#			[sunspot_boolean_columns].compact.flatten +
#			[sunspot_unindexed_columns].compact.flatten
#	end
#	def self.sunspot_orderable_columns
#		@@sunspot_orderable_columns ||= sunspot_columns - %w(
#			languages races ) - sunspot_unindexed_columns
#	end
#	def self.sunspot_available_columns
#		StudySubject.sunspot_columns.sort
##		StudySubject.sunspot_columns.sort + 
##			StudySubject.sunspot_dynamic_columns.sort
#	end
#	def self.sunspot_all_facets
#		%w( subject_type vital_status case_control_type sex phase 
#			races languages hospital diagnosis sample_types operational_event_types 
#			ccls_consented ccls_is_eligible interviewed 
#			patient_was_ca_resident_at_diagnosis
#			patient_was_previously_treated
#			patient_was_under_15_at_dx
#		)
#	end

	include Sunspotability

	self.all_sunspot_columns << SunspotColumn.new( :subject_type, :facetable => true, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :vital_status, :facetable => true, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :case_control_type, :facetable => true )
	self.all_sunspot_columns << SunspotColumn.new( :sex, :facetable => true, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :phase, 
		:facetable => true, :orderable => false, :type => :integer )
	self.all_sunspot_columns << SunspotColumn.new( :races, 
		:facetable => true, :orderable => false, :type => :multi )
	self.all_sunspot_columns << SunspotColumn.new( :languages, 
		:facetable => true, :orderable => false, :type => :multi )
	self.all_sunspot_columns << SunspotColumn.new( :hospital, :facetable => true )
	self.all_sunspot_columns << SunspotColumn.new( :diagnosis, :facetable => true )
	self.all_sunspot_columns << SunspotColumn.new( :sample_types, 
		:facetable => true, :type => :multi )
	self.all_sunspot_columns << SunspotColumn.new( :operational_event_types, 
		:facetable => true, :type => :multi )
	self.all_sunspot_columns << SunspotColumn.new( :ccls_consented, :facetable => true, :type => :nulled_string )
	self.all_sunspot_columns << SunspotColumn.new( :ccls_is_eligible, :facetable => true, :type => :nulled_string )
	self.all_sunspot_columns << SunspotColumn.new( :interviewed, :facetable => true, :type => :boolean )
	self.all_sunspot_columns << SunspotColumn.new( :patient_was_ca_resident_at_diagnosis, 
		:facetable => true, :type => :nulled_string )
	self.all_sunspot_columns << SunspotColumn.new( :patient_was_previously_treated, 
		:facetable => true, :type => :nulled_string )
	self.all_sunspot_columns << SunspotColumn.new( :patient_was_under_15_at_dx, 
		:facetable => true, :type => :nulled_string )

	self.all_sunspot_columns << SunspotColumn.new( :id, :default => true, :type => :integer )
	self.all_sunspot_columns << SunspotColumn.new( :case_icf_master_id, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :mother_icf_master_id, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :icf_master_id, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :dob, :default => true, :type => :date )
	self.all_sunspot_columns << SunspotColumn.new( :first_name, :default => true )
	self.all_sunspot_columns << SunspotColumn.new( :last_name, :default => true )

	self.all_sunspot_columns << SunspotColumn.new( :primary_phone, :orderable => false, :type => :unindexed )
	self.all_sunspot_columns << SunspotColumn.new( :alternate_phone, :orderable => false, :type => :unindexed )
	self.all_sunspot_columns << SunspotColumn.new( :address_street, :orderable => false, :type => :unindexed )
	self.all_sunspot_columns << SunspotColumn.new( :address_city, :orderable => false, :type => :unindexed )
	self.all_sunspot_columns << SunspotColumn.new( :address_state, :orderable => false, :type => :unindexed )
	self.all_sunspot_columns << SunspotColumn.new( :address_zip, :orderable => false, :type => :unindexed )
	self.all_sunspot_columns << SunspotColumn.new( :do_not_contact, :orderable => false, :type => :boolean )

	self.all_sunspot_columns << SunspotColumn.new( :birth_year, :orderable => false, :type => :integer )

	self.all_sunspot_columns << SunspotColumn.new( :reference_date, :orderable => false, :type => :date )
	self.all_sunspot_columns << SunspotColumn.new( :died_on, :orderable => false, :type => :date )
	self.all_sunspot_columns << SunspotColumn.new( :admit_date, :orderable => false, :type => :date )
	self.all_sunspot_columns << SunspotColumn.new( :ccls_assigned_for_interview_on, :orderable => false, :type => :date )
	self.all_sunspot_columns << SunspotColumn.new( :ccls_interview_completed_on, :orderable => false, :type => :date )

	self.all_sunspot_columns << SunspotColumn.new( :studyid )
	self.all_sunspot_columns << SunspotColumn.new( :mother_first_name )
	self.all_sunspot_columns << SunspotColumn.new( :mother_maiden_name )
	self.all_sunspot_columns << SunspotColumn.new( :mother_last_name )
	self.all_sunspot_columns << SunspotColumn.new( :father_first_name )
	self.all_sunspot_columns << SunspotColumn.new( :father_last_name )
	self.all_sunspot_columns << SunspotColumn.new( :middle_name )
	self.all_sunspot_columns << SunspotColumn.new( :maiden_name )
	self.all_sunspot_columns << SunspotColumn.new( :father_ssn )
	self.all_sunspot_columns << SunspotColumn.new( :mother_ssn )
	self.all_sunspot_columns << SunspotColumn.new( :patid )
	self.all_sunspot_columns << SunspotColumn.new( :subjectid )
	self.all_sunspot_columns << SunspotColumn.new( :hospital_key )
	self.all_sunspot_columns << SunspotColumn.new( :hospital_no )
	self.all_sunspot_columns << SunspotColumn.new( :state_id_no )
	self.all_sunspot_columns << SunspotColumn.new( :state_registrar_no )
	self.all_sunspot_columns << SunspotColumn.new( :local_registrar_no )

	searchable do
		sunspot_integer_columns.each {|c| integer c }
		sunspot_string_columns.each {|c| string c }
		sunspot_nulled_string_columns.each {|c| string(c){ send(c)||'NULL' } }
		sunspot_date_columns.each {|c| date c }
		sunspot_double_columns.each {|c| double c }
		sunspot_time_columns.each {|c| time c }
		sunspot_boolean_columns.each {|c|
			string(c){ ( send(c).nil? ) ? 'NULL' : ( send(c) ) ? 'Yes' : 'No' } }
	end

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
	searchable do



#		StudySubject.sunspot_integer_columns.each {|c| integer c }
#		StudySubject.sunspot_date_columns.each    {|c| date    c }
#
##	20130423
##	noticed that the boolean columns only show the "true" facet.
##	this is probably because false.blank? is true and is rejected in one of my checks.
##	simpler to just convert to strings.  let's see.
##		StudySubject.sunspot_boolean_columns.each {|c| boolean c }
##		StudySubject.sunspot_boolean_columns.each {|c| string c.to_s }	#	NOPE
##		StudySubject.sunspot_boolean_columns.each {|c| string(c){ send(c).to_s } }	#	YEP ... what if NULL in db?
##	both the current boolean fields should never actually be nil, nevertheless, ....
##		StudySubject.sunspot_boolean_columns.each {|c| 
##			string(c){ ( send(c).nil? ) ? 'NULL' : send(c).to_s } }	#	yields 'true' and 'false'
#		StudySubject.sunspot_boolean_columns.each {|c| 
#			string(c){ ( send(c).nil? ) ? 'NULL' : ( send(c) ) ? 'Yes' : 'No' } }
#
#
#		StudySubject.sunspot_string_columns.each  {|c| string  c }
#		StudySubject.sunspot_nulled_string_columns.each  {|c| 
#			string(c){ send(c)||'NULL' } }
#	#	StudySubject.sunspot_double_columns.each  {|c| double  c }
#	#	StudySubject.sunspot_time_columns.each    {|c| time    c }

		string :races, :multiple => true do
			races.collect(&:to_s)
		end
		string :languages, :multiple => true do
			languages.collect(&:to_s)
		end

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

		string :sample_types, :multiple => true do
			samples.collect(&:sample_type).collect(&:to_s)
		end

		string :operational_event_types, :multiple => true do
			operational_events.collect(&:operational_event_type).collect(&:to_s)
		end






	#
	#	Uncomment if want full text searching
	#	I don't use it now so ...
	#
	#	text :first_name
	#	text :middle_name
	#	text :maiden_name
	#	text :last_name
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
	#	text :studyid
	#	text :icf_master_id
	#	text :childid
	#	text :patid
	#	text :hospital_no
	#	text :state_id_no
	#	text :state_registrar_no
	#	text :local_registrar_no
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


