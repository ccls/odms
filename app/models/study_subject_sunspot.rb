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

	def case_icf_master_id
		case_subject.try(:icf_master_id)	#||'[No Case Subject]'
	end
	def mother_icf_master_id
		mother.try(:icf_master_id)	#||'[No Mother Subject]'
	end
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

	def ccls_enrollment
		enrollments.where(:project_id => Project['ccls'].id).first
	end
	def ccls_consented
		YNDK[ccls_enrollment.try(:consented)]
	end
	def ccls_is_eligible
		YNDK[ccls_enrollment.try(:is_eligible)]
	end
#	def ccls_assigned_for_interview_at
#		datetime
	def ccls_assigned_for_interview_on
#	date
		ccls_enrollment.try(:assigned_for_interview_at).try(:to_date)
	end
	def ccls_interview_completed_on
#		date
		ccls_enrollment.try(:interview_completed_on)
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


	cattr_accessor :sunspot_dynamic_columns
	self.sunspot_dynamic_columns = []

	#
	#	All these columns are indexed and 
	#
	def self.sunspot_columns
		@@sunspot_columns ||= [sunspot_string_columns].compact.flatten +
			[sunspot_nulled_string_columns].compact.flatten +
			[sunspot_time_columns].compact.flatten +
			[sunspot_date_columns].compact.flatten +
			[sunspot_integer_columns].compact.flatten +
			[sunspot_double_columns].compact.flatten +
			[sunspot_boolean_columns].compact.flatten
	end
	
	def self.sunspot_orderable_columns
		@@sunspot_orderable_columns ||= sunspot_columns - %w(
			languages races )
	end
#			patient_was_ca_resident_at_diagnosis
#			patient_was_previously_treated
#			patient_was_under_15_at_dx
	
	#
	#	NOTE what about 
	#
	#	matchingid,familyid,case_subjectid?
	#
	
	
	def self.sunspot_string_columns
		@@sunspot_string_columns ||= %w(
			case_icf_master_id mother_icf_master_id icf_master_id
			subject_type vital_status case_control_type
			sex studyid
			mother_first_name mother_maiden_name mother_last_name
			father_first_name father_last_name
			first_name middle_name maiden_name last_name
			father_ssn mother_ssn
			patid subjectid hospital_key
			diagnosis hospital hospital_no
			languages races
		)
	end

	def self.sunspot_nulled_string_columns
		@@sunspot_nulled_string_columns ||= %w(
			ccls_consented ccls_is_eligible
			patient_was_ca_resident_at_diagnosis
			patient_was_previously_treated
			patient_was_under_15_at_dx
		)
	end
	def self.sunspot_time_columns
		@@sunspot_time_columns ||= []
	end
	def self.sunspot_date_columns
		@@sunspot_date_columns ||= %w( reference_date dob died_on admit_date 
			ccls_assigned_for_interview_on ccls_interview_completed_on
		)
	end
	def self.sunspot_integer_columns
		@@sunspot_integer_columns ||= %w( id phase birth_year  )
	end
	def self.sunspot_boolean_columns
		@@sunspot_boolean_columns ||= %w( do_not_contact )
	end
	def self.sunspot_double_columns
		@@sunspot_double_columns ||= []
	end

	searchable do
		StudySubject.sunspot_integer_columns.each {|c| integer c }
		StudySubject.sunspot_date_columns.each    {|c| date    c }
		StudySubject.sunspot_boolean_columns.each {|c| boolean c }
		StudySubject.sunspot_string_columns.each  {|c| string  c }
		StudySubject.sunspot_nulled_string_columns.each  {|c| 
			string(c){ send(c)||'NULL' } }
	#	StudySubject.sunspot_double_columns.each  {|c| double  c }
	#	StudySubject.sunspot_time_columns.each    {|c| time    c }

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


