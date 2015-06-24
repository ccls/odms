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

#	def newest_birth_data
#		@newest_birth_data ||= birth_data.order('created_at DESC')
#	end
#	def father_ssn
#		newest_birth_data.collect(&:father_ssn).collect(&:to_ssn).compact.first
#	end
#	def mother_ssn
#		newest_birth_data.collect(&:mother_ssn).collect(&:to_ssn).compact.first
#	end

	#	is indexed as text too, so NEED actual method (at least for now)
	def derived_state_file_no_last6
#		newest_birth_data.collect(&:derived_state_file_no_last6).compact.first
		birth_datum.try(:derived_state_file_no_last6)
	end
	#	is text so NEED actual method (at least for now)
	def derived_local_file_no_last6
#		newest_birth_data.collect(&:derived_local_file_no_last6).compact.first
		birth_datum.try(:derived_local_file_no_last6)
	end


	#
	#	thought of adding birth_type, but is in StudySubject AND BirthDatum
	#
	#	Delegate these 2 methods - done 20150213
	#
#	def hospital
#		patient.try(:organization).try(:to_s)	#	use try so stays nil if nil
#	end
#	def hospital_key
#		patient.try(:organization).try(:key)
#	end


	#
	#	Used other places too
	#
	def ccls_consented
		YNDK[ccls_enrollment.try(:consented)]
	end
	alias_method :ccls_is_consented, :ccls_consented

	def ccls_is_eligible
		YNDK[ccls_enrollment.try(:is_eligible)]
	end

	#
	#	NOTE what about 
	#
	#	matchingid,familyid,case_subjectid?
	#

	include ActiveRecordSunspotter::Sunspotability

	#		default_options = {
	#			:group     => 'Main',
	#			:type      => :string, 
	#			:orderable => true, 
	#			:facetable => false, 
	#			:filterable => false, ??? can't remember the purpose of this?
	#			:multiple  => false, 
	#			:default   => false
	#		}
	#	:label is the facet label

	add_sunspot_column( :id, :default => true, :type => :integer )
	add_sunspot_column( :subject_type, :facetable => true, :default => true )

	add_sunspot_column( :childs_subject_type, :facetable => true, 
		:label => "Child's Subject Type",
		:meth => ->(s){ s.child.try(:subject_type) })

	add_sunspot_column( :vital_status, :facetable => true, :default => true )
	add_sunspot_column( :case_control_type, :facetable => true )
	add_sunspot_column( :sex, :facetable => true, :default => true )
	add_sunspot_column( :phase, :facetable => true, :type => :integer )

	#
	#	DON'T USE THE KEY :method IN AN OPENSTRUCT (why did I use an OpenStruct and not just a hash?)
	#
	#	Use subject_races and subject_languages so can get "Other"
	#
	add_sunspot_column( :races, :facetable => true, :multiple => true,
		:meth => ->(s){ s.subject_races.collect(&:to_s) } )
	add_sunspot_column( :languages, :facetable => true, :multiple => true,
		:meth => ->(s){ s.subject_languages.collect(&:to_s) } )

	add_sunspot_column( :projects, :facetable => true, :multiple => true,
		:meth => ->(s){ s.enrollments.collect(&:project) } )

	add_sunspot_column( :hospital, :facetable => true )
	add_sunspot_column( :diagnosis, :facetable => true )
	add_sunspot_column( :other_diagnosis )
	add_sunspot_column( :sample_types, :facetable => true, :multiple => true,
		:meth => ->(s){ s.samples.collect(&:sample_type).collect(&:to_s) } )
	add_sunspot_column( :operational_event_types, :facetable => true, :multiple => true,
		:meth => ->(s){ s.operational_events.collect(&:operational_event_type).collect(&:to_s) } )
	add_sunspot_column( :ccls_consented, :label => 'Consented?', :facetable => true,
		:meth => ->(s){ s.ccls_consented||'NULL' } )
	add_sunspot_column( :ccls_is_eligible, :label => 'Is Eligible?', :facetable => true,
		:meth => ->(s){ s.ccls_is_eligible||'NULL' } )
	add_sunspot_column( :interviewed, :facetable => true,
		:meth => ->(s){ s.ccls_enrollment.try(:interview_completed_on).present? ? 'Yes' : 'No' })
	add_sunspot_column( :patient_was_ca_resident_at_diagnosis, :facetable => true,
		:meth  => ->(s){ YNDK[s.patient.try(:was_ca_resident_at_diagnosis)]||'NULL' },
		:label => 'Was CA Resident at Diagnosis?' )
	add_sunspot_column( :patient_was_previously_treated, :facetable => true,
		:meth  => ->(s){ YNDK[s.patient.try(:was_previously_treated)]||'NULL' },
		:label => 'Was Previously Treated?' )
	add_sunspot_column( :patient_was_under_15_at_dx, :facetable => true,
		:label => 'Was Under 15 at Diagnosis?',
		:meth => ->(s){ YNDK[s.patient.try(:was_under_15_at_dx)]||'NULL' } )
	add_sunspot_column( :icf_master_id, :default => true )
	add_sunspot_column( :case_icf_master_id, :default => true )
	add_sunspot_column( :mother_icf_master_id, :default => true )
	add_sunspot_column( :dob, :default => true, :type => :date )
	add_sunspot_column( :first_name, :default => true )
	add_sunspot_column( :last_name, :default => true )
	add_sunspot_column( :primary_phone )
	add_sunspot_column( :alternate_phone )
	add_sunspot_column( :address_street )
	add_sunspot_column( :address_unit )
	add_sunspot_column( :address_city )
	add_sunspot_column( :address_county )
	add_sunspot_column( :address_state )
	add_sunspot_column( :address_zip )

	add_sunspot_column( :location, :type => :latlon, :orderable => false,
		:meth => ->(s){ Sunspot::Util::Coordinates.new(s.address_latitude, s.address_longitude) } )
	add_sunspot_column( :address_latitude, :type => :float, :orderable => false )
	add_sunspot_column( :address_longitude, :type => :float, :orderable => false )

	#	do_not_contact has default false set. will only be true or false
	add_sunspot_column( :do_not_contact, 
		:meth => ->(s){ s.do_not_contact? ? 'Yes' : 'No' } )
	add_sunspot_column( :birth_year, :type => :integer )
	add_sunspot_column( :reference_date, :type => :date )
	add_sunspot_column( :died_on, :type => :date )
	add_sunspot_column( :admit_date, :type => :date )

	add_sunspot_column( :age_at_admittance, :type => :integer, :facetable => true,
		:meth => ->(s){( s.dob.blank? or s.admit_date.blank? ) ? nil : s.dob.diff(s.admit_date)[:years] })


	add_sunspot_column( :ccls_assigned_for_interview_on, :type => :date,
		:meth => ->(s){ s.ccls_enrollment.try(:assigned_for_interview_at).try(:to_date).try(:strftime,'%m/%d/%Y') } )
	add_sunspot_column( :ccls_interview_completed_on, :type => :date,
		:meth => ->(s){ s.ccls_enrollment.try(:interview_completed_on).try(:strftime,'%m/%d/%Y') } )
	add_sunspot_column( :studyid )
	add_sunspot_column( :mother_first_name )
	add_sunspot_column( :mother_maiden_name )
	add_sunspot_column( :mother_last_name )
	add_sunspot_column( :father_first_name )
	add_sunspot_column( :father_last_name )
	add_sunspot_column( :middle_name )
	add_sunspot_column( :maiden_name )
	add_sunspot_column( :father_ssn,
		:meth => ->(s){ s.birth_datum.try(:father_ssn).try(:to_ssn) } )
#		:meth => ->(s){ s.newest_birth_data.collect(&:father_ssn).collect(&:to_ssn).compact.first } )
	add_sunspot_column( :mother_ssn,
		:meth => ->(s){ s.birth_datum.try(:mother_ssn).try(:to_ssn) } )
#		:meth => ->(s){ s.newest_birth_data.collect(&:mother_ssn).collect(&:to_ssn).compact.first } )
	add_sunspot_column( :mother_dob, :type => :date,
		:meth => ->(s){ s.birth_datum.try(:mother_dob) } )
#		:meth => ->(s){ s.newest_birth_data.collect(&:mother_dob).compact.first } )
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
	add_sunspot_column( :derived_state_file_no_last6, :type => :integer )


	#
	#	Perhaps, make these columns ":multiple => true"?  Not really using yet anyway.
	#
	with_options( :group => 'Ethnicity', :facetable => true ) do |o|
		o.add_sunspot_column( :mother_hispanic_origin_code,
			:meth => ->(s){ s.birth_datum.try(:mother_hispanic_origin_code) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:mother_hispanic_origin_code).compact.first })
		o.add_sunspot_column( :mother_race_ethn_1, :type => :integer,
			:meth => ->(s){ s.birth_datum.try(:mother_race_ethn_1) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_1).compact.first })
		o.add_sunspot_column( :mother_race_ethn_2, :type => :integer,
			:meth => ->(s){ s.birth_datum.try(:mother_race_ethn_2) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_2).compact.first })
		o.add_sunspot_column( :mother_race_ethn_3, :type => :integer,
			:meth => ->(s){ s.birth_datum.try(:mother_race_ethn_3) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_3).compact.first })
		o.add_sunspot_column( :father_hispanic_origin_code,
			:meth => ->(s){ s.birth_datum.try(:father_hispanic_origin_code) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:father_hispanic_origin_code).compact.first })
		o.add_sunspot_column( :father_race_ethn_1, :type => :integer,
			:meth => ->(s){ s.birth_datum.try(:father_race_ethn_1) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_1).compact.first })
		o.add_sunspot_column( :father_race_ethn_2, :type => :integer,
			:meth => ->(s){ s.birth_datum.try(:father_race_ethn_2) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_2).compact.first })
		o.add_sunspot_column( :father_race_ethn_3, :type => :integer,
			:meth => ->(s){ s.birth_datum.try(:father_race_ethn_3) })
#			:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_3).compact.first })
	end



	add_sunspot_column( :current_address_count, :type => :integer, :facetable => true,
		:meth => ->(s){ s.addresses.current.count })
	add_sunspot_column( :current_address_at_dx, :facetable => true,
		:meth => ->(s){ YNDK[s.addresses.current.order('created_at DESC').first.try(:address_at_diagnosis)]||'NULL' })

	add_sunspot_column( :med_record_request_sent, :facetable => true,
		:meth => ->(s){ ( s.medical_record_requests.collect(&:sent_on).any? ) ? 'Yes' : 'No' } )
	add_sunspot_column( :med_record_request_received, :facetable => true,
		:meth => ->(s){ ( s.medical_record_requests.collect(&:returned_on).any? ) ? 'Yes' : 'No' } )

	add_sunspot_column( :birth_record_request_sent, :facetable => true,
		:meth => ->(s){ ( s.bc_requests.collect(&:sent_on).any? ) ? 'Yes' : 'No' } )
	add_sunspot_column( :birth_record_request_received, :facetable => true,
		:meth => ->(s){ ( s.bc_requests.collect(&:returned_on).any? ) ? 'Yes' : 'No' } )

	add_sunspot_column( :replicated, :facetable => true, :label => "Possibly Replicated?",
		:meth => ->(s){ s.replication_id.present? ? 'Yes' : 'No' } )

	#
	#	DO NOT ALLOW BLANK VALUES INTO INDEX.  Only really a problem when faceting on blank values.
	#	However, if it is truely blank, my facet_for helper will deal with it, but can't select it.
	#	So, if blank is a desirable selection, will need to replace it with something as do
	#	with NULL in the nulled strings.  Don't know if can do that with non-string fields.
	#	Can I conditionally change the field?  If blank, string(c){ 'NULL' } else integer(c) ???? doubt it.  Could, but they would be different.
	#
	#	what if I wanted all of the subjects that don't have a phase set?
	#






	#
	#	If these have ANY value, they will show.
	#	If they don't, they won't.
	#	It is AWESOME that "project" is preserved in these methods.
	#		I wouldn't've thought it'd be.
	#
	Project.order(:position).each do |project|
		pkey = project.key
		plab = project.label
		with_options(:group => "#{plab} Enrollment" ) do |o|
		o.add_sunspot_column( :"#{pkey}__consented", 
			:facetable => true, :label => "#{plab}:Consented?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? YNDK[e.consented]||'Blank' : nil })
		o.add_sunspot_column( :"#{pkey}__is_eligible", 
			:facetable => true, :label => "#{plab}:Is Eligible?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? YNDK[e.is_eligible]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__interviewed", 
			:facetable => true, :label => "#{plab}:Interviewed?",
			:meth => ->(s){ ( (e=s.enrollment(pkey)).present? ) ? 
				( e.try(:interview_completed_on).present? ? 'Yes' : 'No' ) : nil } )
		o.add_sunspot_column( :"#{pkey}__interview_completed_on", :type => :date,
			:meth => ->(s){ s.enrollment(pkey).try(:interview_completed_on).try(:strftime,'%m/%d/%Y') } )
		o.add_sunspot_column( :"#{pkey}__assigned_for_interview_on", :type => :date,
			:meth => ->(s){ s.enrollment(pkey).try(
				:assigned_for_interview_at).try(:to_date).try(:strftime,'%m/%d/%Y') } )
		o.add_sunspot_column( :"#{pkey}__recruitment_priority", 
			:type => :string, :facetable => true, :label => "#{plab}:Recruitment Priority",
			:meth => ->(s){ s.enrollment(pkey).try(:recruitment_priority) } )
		o.add_sunspot_column( :"#{pkey}__is_candidate", 
			:facetable => true, :label => "#{plab}:Is Candidate?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? YNDK[e.is_candidate]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__ineligible_reason", 
			:facetable => true, :label => "#{plab}:Ineligible Reason",
			:meth => ->(s){ s.enrollment(pkey).try(:ineligible_reason) } )
		o.add_sunspot_column( :"#{pkey}__other_ineligible_reason", 
			:facetable => true, :label => "#{plab}:Other Ineligible Reason",
			:meth => ->(s){ s.enrollment(pkey).try(:other_ineligible_reason).nilify_blank } )
		o.add_sunspot_column( :"#{pkey}__consented_on", :type => :date,
			:meth => ->(s){ s.enrollment(pkey).try(:consented_on).try(:strftime,'%m/%d/%Y') } )
		o.add_sunspot_column( :"#{pkey}__refusal_reason", 
			:facetable => true, :label => "#{plab}:Refusal Reason",
			:meth => ->(s){ s.enrollment(pkey).try(:refusal_reason) } )
		o.add_sunspot_column( :"#{pkey}__other_refusal_reason", 
			:facetable => true, :label => "#{plab}:Other Refusal Reason",
			:meth => ->(s){ s.enrollment(pkey).try(:other_refusal_reason).nilify_blank } )
		o.add_sunspot_column( :"#{pkey}__is_chosen", 
			:facetable => true, :label => "#{plab}:Is Chosen?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? YNDK[e.is_chosen]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__reason_not_chosen",
			:meth => ->(s){ s.enrollment(pkey).try(:reason_not_chosen) } )
		o.add_sunspot_column( :"#{pkey}__terminated_participation", 
			:facetable => true, :label => "#{plab}:Terminated Participation?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? YNDK[e.terminated_participation]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__terminated_reason",
			:meth => ->(s){ s.enrollment(pkey).try(:terminated_reason) } )
		o.add_sunspot_column( :"#{pkey}__is_complete", 
			:facetable => true, :label => "#{plab}:Is Complete?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? YNDK[e.is_complete]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__completed_on", :type => :date,
			:meth => ->(s){ s.enrollment(pkey).try(:completed_on).try(:strftime,'%m/%d/%Y') } )
		o.add_sunspot_column( :"#{pkey}__is_closed", 
			:facetable => true, :label => "#{plab}:Is Closed?",
			:meth => ->(s){ e=s.enrollment(pkey)
				( e.try(:is_closed).present? ) ? ( e.try(:is_closed) ? 'Yes' : 'No' ) : nil } )
		o.add_sunspot_column( :"#{pkey}__reason_closed",
			:meth => ->(s){ s.enrollment(pkey).try(:reason_closed) } )
#		o.add_sunspot_column( :"#{pkey}__document_version", 
#			:facetable => true, :label => "#{plab}:Document Version",
#			:meth => ->(s){ s.enrollment(pkey).try(:document_version) } )
		o.add_sunspot_column( :"#{pkey}__project_outcome", 
			:facetable => true, :label => "#{plab}:Project Outcome",
			:meth => ->(s){ s.enrollment(pkey).try(:project_outcome) } )
		o.add_sunspot_column( :"#{pkey}__project_outcome_on", :type => :date,
			:meth => ->(s){ s.enrollment(pkey).try(:project_outcome_on).try(:strftime,'%m/%d/%Y') } )
		o.add_sunspot_column( :"#{pkey}__use_smp_future_rsrch", 
			:facetable => true, :label => "#{plab}:UseSmpFutureRsrch?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.use_smp_future_rsrch]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__use_smp_future_cancer_rsrch", 
			:facetable => true, :label => "#{plab}:UseSmpFutureCancerRsrch?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.use_smp_future_cancer_rsrch]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__use_smp_future_other_rsrch", 
			:facetable => true, :label => "#{plab}:UseSmpFutureOtherRsrch?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.use_smp_future_other_rsrch]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__share_smp_with_others", 
			:facetable => true, :label => "#{plab}:ShareSmpWithOthers?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.share_smp_with_others]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__contact_for_related_study", 
			:facetable => true, :label => "#{plab}:ContactForRelatedStudy?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.contact_for_related_study]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__provide_saliva_smp", 
			:facetable => true, :label => "#{plab}:ProvideSalivaSmp?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.provide_saliva_smp]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__receive_study_findings", 
			:facetable => true, :label => "#{plab}:Receive Study Findings?",
			:meth => ->(s){ (e=s.enrollment(pkey)).present? ? ADNA[e.receive_study_findings]||'Blank' : nil } )
		o.add_sunspot_column( :"#{pkey}__refused_by_physician", 
			:facetable => true, :label => "#{plab}:Refused By Physician?",
			:meth => ->(s){ e=s.enrollment(pkey)
				( e.try(:refused_by_physician).present? ) ? ( e.try(:refused_by_physician) ? 'Yes' : 'No' ) : nil } )
		o.add_sunspot_column( :"#{pkey}__refused_by_family", 
			:facetable => true, :label => "#{plab}:Refused By Family?",
			:meth => ->(s){ e=s.enrollment(pkey)
				( e.try(:refused_by_family).present? ) ? ( e.try(:refused_by_family) ? 'Yes' : 'No' ) : nil } )
		o.add_sunspot_column( :"#{pkey}__tracing_status", 
			:facetable => true, :label => "#{plab}:Tracing Status",
			:meth => ->(s){ s.enrollment(pkey).try(:tracing_status).nilify_blank } )
		o.add_sunspot_column( :"#{pkey}__vaccine_authorization_received_on", :type => :date,
			:meth => ->(s){ s.enrollment(pkey).try(
				:vaccine_authorization_received_at).try(:to_date).try(:strftime,'%m/%d/%Y') } )
		end	#	with_options(:group => pkey) do |o|
	end	#	Project.all



	#
	#	all_sunspot_columns must be set before calling this
	#
	#	change solr/conf/schema.rb to allow for partial word search and
	#		use Whitespace Tokenizer so can search for words with hyphens.
	searchable_plus do
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



bundle exec rake sunspot:solr:start
bundle exec rake sunspot:reindex



solr server won't start with 2.1.0 (20140417)
https://github.com/sunspot/sunspot/issues/566


TrieDoubleType and TrieLongType classes are not defined (20131217)
https://github.com/sunspot/sunspot/issues/522


How to identify dynamic fields to facet on (20140818)
https://github.com/sunspot/sunspot/issues/606


Ways to search across multple assocations (20120726)
https://groups.google.com/forum/#!topic/ruby-sunspot/qwc9GqFNL8c

