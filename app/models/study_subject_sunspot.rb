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

	#	
	#	Pointless.  Most subjects don't have a diagnosis_date.  (Only 1 does, actually)
	#
	#	add_sunspot_column( :age_at_diagnosis, :type => :integer, :facetable => true,
	#		:meth => ->(s){( s.dob.blank? or s.diagnosis_date.blank? ) ? nil : s.dob.diff(s.diagnosis_date)[:years] })

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
	add_sunspot_column( :derived_state_file_no_last6, :type => :integer )


	#
	#	Perhaps, make these columns ":multiple => true"?  Not really using yet anyway.
	#
	add_sunspot_column( :mother_hispanic_origin_code, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_hispanic_origin_code).compact.first })
	add_sunspot_column( :mother_race_ethn_1, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_1).compact.first })
	add_sunspot_column( :mother_race_ethn_2, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_2).compact.first })
	add_sunspot_column( :mother_race_ethn_3, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:mother_race_ethn_3).compact.first })
	add_sunspot_column( :father_hispanic_origin_code, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_hispanic_origin_code).compact.first })
	add_sunspot_column( :father_race_ethn_1, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_1).compact.first })
	add_sunspot_column( :father_race_ethn_2, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_2).compact.first })
	add_sunspot_column( :father_race_ethn_3, :type => :integer, :facetable => true,
		:meth => ->(s){ s.newest_birth_data.collect(&:father_race_ethn_3).compact.first })



	add_sunspot_column( :current_address_count, :type => :integer, :facetable => true,
		:meth => ->(s){ s.addresses.current.count })
	add_sunspot_column( :current_address_at_dx, :facetable => true,
		:meth => ->(s){ YNDK[s.addresses.current.order('created_at DESC').first.try(:address_at_diagnosis)]||'NULL' })

	add_sunspot_column( :medical_record_request_sent, :facetable => true,
		:meth => ->(s){ ( s.medical_record_requests.collect(&:sent_on).any? ) ? 'Yes' : 'No' } )
	add_sunspot_column( :medical_record_request_received, :facetable => true,
		:meth => ->(s){ ( s.medical_record_requests.collect(&:returned_on).any? ) ? 'Yes' : 'No' } )


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
	#	Feel like I'm getting closer ..... yet still miles away.  Its indexed, but how can I extract to column.
	#	Say column "enrollments:ccls__consented" is selected.  How to get its value?
	#	Could create method, but dependent on subject.
	#	Labels?
	#
	#	Now that I've tried this, I don't think that this will ever work.
	#	How's that for motivational!
	#
#	add_sunspot_column( :"enrollments:project__consented", :namespace => :enrollments, :type => :dynamic, :facetable => true, 
#		:dmeth => ->(s,c){ YNDK[s.enrollments.where(:project_id => Project[c.match(/"enrollments:(.+)__.+/)[1]].id).first.try(:consented)]||'NULL' },
#		:kvp => ->(s){ Hash[s.enrollments.collect{|e| ["#{e.project.key}__consented", YNDK[e.consented]] }] } )
	#
	#	this will create SunspotColumn for "enrollments:project__consented"
	#	need to kinda do this (not facetable), but also create other facetable columns to be used in conjunction?
	#
	#	thinking that the old way was better.  Create normal columns for ALL projects and therefore, ALL enrollments.
	#


	#
	#	If these have ANY value, they will show.
	#	If they don't, they won't.
	#	It is AWESOME that "project" is preserved in these methods.  I wouldn't've thought it'd be.
	#
	Project.order(:position).each do |project|
		pkey = project.key
		plab = project.label
		add_sunspot_column( :"#{pkey}__consented", :facetable => true, :label => "#{plab}:Consented?",
			:meth => ->(s){ YNDK[s.enrollments.where(:project_id => project.id).first.try(:consented)] } )
		add_sunspot_column( :"#{pkey}__is_eligible", :facetable => true, :label => "#{plab}:Is Eligible?",
			:meth => ->(s){ YNDK[s.enrollments.where(:project_id => project.id).first.try(:is_eligible)] } )
		add_sunspot_column( :"#{pkey}__interviewed", :facetable => true, :label => "#{plab}:Interviewed?",
			:meth => ->(s){ e=s.enrollments.where(:project_id => project.id).first
				( e.present? ) ? ( e.try(:interview_completed_on).present? ? 'Yes' : 'No' ) : nil } )
		add_sunspot_column( :"#{pkey}__interview_completed_on", :type => :date,
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:interview_completed_on).try(:strftime,'%m/%d/%Y') } )
		add_sunspot_column( :"#{pkey}__assigned_for_interview_on", :type => :date,
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(
				:assigned_for_interview_at).try(:to_date).try(:strftime,'%m/%d/%Y') } )

		add_sunspot_column( :"#{pkey}__recruitment_priority", :type => :string, :facetable => true, :label => "#{plab}:Recruitment Priority",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:recruitment_priority) } )
		add_sunspot_column( :"#{pkey}__is_candidate", :facetable => true, :label => "#{plab}:Is Candidate?",
			:meth => ->(s){ YNDK[s.enrollments.where(:project_id => project.id).first.try(:is_candidate)] } )
		add_sunspot_column( :"#{pkey}__ineligible_reason", :facetable => true, :label => "#{plab}:Ineligible Reason",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:ineligible_reason) } )
		add_sunspot_column( :"#{pkey}__other_ineligible_reason", :facetable => true, :label => "#{plab}:Other Ineligible Reason",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:other_ineligible_reason).nilify_blank } )
		add_sunspot_column( :"#{pkey}__consented_on", :type => :date,
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:consented_on).try(:strftime,'%m/%d/%Y') } )
		add_sunspot_column( :"#{pkey}__refusal_reason", :facetable => true, :label => "#{plab}:Refusal Reason",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:refusal_reason) } )
		add_sunspot_column( :"#{pkey}__other_refusal_reason", :facetable => true, :label => "#{plab}:Other Refusal Reason",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:other_refusal_reason).nilify_blank } )
		add_sunspot_column( :"#{pkey}__is_chosen", :facetable => true, :label => "#{plab}:Is Chosen?",
			:meth => ->(s){ YNDK[s.enrollments.where(:project_id => project.id).first.try(:is_chosen)] } )
		add_sunspot_column( :"#{pkey}__reason_not_chosen",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:reason_not_chosen) } )
		add_sunspot_column( :"#{pkey}__terminated_participation", :facetable => true, :label => "#{plab}:Terminated Participation?",
			:meth => ->(s){ YNDK[s.enrollments.where(:project_id => project.id).first.try(:terminated_participation)] } )
		add_sunspot_column( :"#{pkey}__terminated_reason",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:terminated_reason) } )
		add_sunspot_column( :"#{pkey}__is_complete", :facetable => true, :label => "#{plab}:Is Complete?",
			:meth => ->(s){ YNDK[s.enrollments.where(:project_id => project.id).first.try(:is_complete)] } )
		add_sunspot_column( :"#{pkey}__completed_on", :type => :date,
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:completed_on).try(:strftime,'%m/%d/%Y') } )
		add_sunspot_column( :"#{pkey}__is_closed", :facetable => true, :label => "#{plab}:Is Closed?",
			:meth => ->(s){ e=s.enrollments.where(:project_id => project.id).first
				( e.try(:is_closed).present? ) ? ( e.try(:is_closed) ? 'Yes' : 'No' ) : nil } )
		add_sunspot_column( :"#{pkey}__reason_closed",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:reason_closed) } )
		add_sunspot_column( :"#{pkey}__document_version", :facetable => true, :label => "#{plab}:Document Version",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:document_version) } )
		add_sunspot_column( :"#{pkey}__project_outcome", :facetable => true, :label => "#{plab}:Project Outcome",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:project_outcome) } )
		add_sunspot_column( :"#{pkey}__project_outcome_on", :type => :date,
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:project_outcome_on).try(:strftime,'%m/%d/%Y') } )
		add_sunspot_column( :"#{pkey}__use_smp_future_rsrch", :facetable => true, :label => "#{plab}:UseSmpFutureRsrch?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:use_smp_future_rsrch)] } )
		add_sunspot_column( :"#{pkey}__use_smp_future_cancer_rsrch", :facetable => true, :label => "#{plab}:UseSmpFutureCancerRsrch?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:use_smp_future_cancer_rsrch)] } )
		add_sunspot_column( :"#{pkey}__use_smp_future_other_rsrch", :facetable => true, :label => "#{plab}:UseSmpFutureOtherRsrch?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:use_smp_future_other_rsrch)] } )
		add_sunspot_column( :"#{pkey}__share_smp_with_others", :facetable => true, :label => "#{plab}:ShareSmpWithOthers?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:share_smp_with_others)] } )
		add_sunspot_column( :"#{pkey}__contact_for_related_study", :facetable => true, :label => "#{plab}:ContactForRelatedStudy?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:contact_for_related_study)] } )
		add_sunspot_column( :"#{pkey}__provide_saliva_smp", :facetable => true, :label => "#{plab}:ProvideSalivaSmp?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:provide_saliva_smp)] } )
		add_sunspot_column( :"#{pkey}__receive_study_findings", :facetable => true, :label => "#{plab}:Receive Study Findings?",
			:meth => ->(s){ ADNA[s.enrollments.where(:project_id => project.id).first.try(:receive_study_findings)] } )
		add_sunspot_column( :"#{pkey}__refused_by_physician", :facetable => true, :label => "#{plab}:Refused By Physician?",
			:meth => ->(s){ e=s.enrollments.where(:project_id => project.id).first
				( e.try(:refused_by_physician).present? ) ? ( e.try(:refused_by_physician) ? 'Yes' : 'No' ) : nil } )
		add_sunspot_column( :"#{pkey}__refused_by_family", :facetable => true, :label => "#{plab}:Refused By Family?",
			:meth => ->(s){ e=s.enrollments.where(:project_id => project.id).first
				( e.try(:refused_by_family).present? ) ? ( e.try(:refused_by_family) ? 'Yes' : 'No' ) : nil } )
		add_sunspot_column( :"#{pkey}__tracing_status", :facetable => true, :label => "#{plab}:Tracing Status",
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(:tracing_status).nilify_blank } )
		add_sunspot_column( :"#{pkey}__vaccine_authorization_received_on", :type => :date,
			:meth => ->(s){ s.enrollments.where(:project_id => project.id).first.try(
				:vaccine_authorization_received_at).try(:to_date).try(:strftime,'%m/%d/%Y') } )
	end	#	Project.all



	#
	#	all_sunspot_columns must be set before calling this
	#
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


#define_method("enrollments:ccls__consented")do puts 'asdf'; end	#	YES, colons allowed?
#	def 'enrollments:ccls__consented'	#	NO, string and colon NOT allowed
#		puts 'asdf'
#	end

#	from generate_association_writer
#		generated_feature_methods.module_eval           
#			if method_defined?(:#{association_name}_attributes=)
#				remove_method(:#{association_name}_attributes=)
#			end
#			def #{association_name}_attributes=(attributes)
#				assign_nested_attributes_for_#{type}_association(:#{association_name}, attributes)
#			end, __FILE__, __LINE__ + 1
#	why def and not define_method ???






#	Hash[StudySubject.find(24135).enrollments.collect{|e| ["#{e.project.key}__consented", YNDK[e.consented]] }]
#	=> {"ccls__consented"=>"Yes", "home_dust__consented"=>"Yes"}




#	dynamic_sunspot_column = { :namespace => :enrollments, 
#		:asdf => ->(s){ s.enrollments.inject({}) do |hash,enrollment|
#				hash.merge( "#{enrollment.project.key}__consented".to_sym => YNDK[enrollment.consented] )
#			end } }
#
#	kinda works, but how to show value in column?
#		:meth => ->(s){ s.enrollments.where(:project_id => Project[


# no no no
#	pre => ->{ s.enrollments.each{|e| define_method("enrollments:#{e.project.key}__consented") { YNDK[e.consented] } } }
#	add "unless method_defined?( "enrollments:#{e.project.key}__consented" ) ??????


	#	This kinda works, but doesn't seem right.
	#
	#	StudySubject.find(24135).send("enrollments:home_dust__consented")
	#
	#Project.all.each do |project|
	#	define_method("enrollments:#{project.key}__consented"){ YNDK[enrollments.where(:project_id => Project[project.key]).first.consented] }
	#end









#		dynamic_string :enrollments do
#			h = enrollments.inject({}) do |hash,enrollment|
#				hash.merge( "#{enrollment.project.key}__consented".to_sym => YNDK[enrollment.consented] )
#			end
#			g = enrollments.inject({}) do |hash,enrollment|
#				hash.merge( "#{enrollment.project.key}__is_eligible".to_sym => YNDK[enrollment.is_eligible] )
#			end
#			g.merge h

#			h = dynamic_sunspot_column[:asdf].call( self )
#puts h.inspect
#			h
#		end







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



#	Not sure yet, whether the ".to_sym" is necessary, but it seems to be treating them differently (but I'm changing other stuff)
#	StudySubject.search{ dynamic :enrollments do facet(:ccls__is_eligible) end }.facet(:enrollments, :ccls__is_eligible).rows	WORKS
#	StudySubject.search{ dynamic :enrollments do facet(:ccls__consented) end }.facet(:enrollments, :ccls__consented).rows DOESN't
#	Only the last line is sustained and returned. The first is executed and then not remembered.
#
#		dynamic_string :enrollments do
#			enrollments.inject({}) do |hash,enrollment|
#				#	hash.merge("#{enrollment.project.key}__consented".to_sym => YNDK[enrollment.consented])
#				#	hash.merge("#{enrollment.project.key}__is_eligible".to_sym => YNDK[enrollment.is_eligible])
#				#	... better ...
#				hash.merge(
#					"#{enrollment.project.key}__consented".to_sym => YNDK[enrollment.consented],
#					"#{enrollment.project.key}__is_eligible".to_sym => YNDK[enrollment.is_eligible])
#			end
#		end
#
#
#	how to identify dynamically created facets from a search?
#	for that matter, any available facet?
#
#	This kinda works for some
#	Sunspot::Setup.for(StudySubject).fields.select{|f| f.name.to_s =~ /ccls/ }
#
#	This only gets the namespace...
#	Sunspot::Setup.for(StudySubject).dynamic_field_factories
#
#	I think that you either query the database or create an index for just the keys and then query that ...
#	
#	class Widget < ActiveRecord::Base
#	   has_many :key_value_pairs
#	
#	   searchable do
#	
#	      string :key_value_pairs_keys, :multiple => true do
#	         key_value_pairs.collect(&:key)
#	      end
#	
#	      dynamic_string :key_value_pairs do
#	         key_value_pairs.inject({}) do |hash, pair|
#	           hash.merge(pair.key.to_sym => pair.value)
#	         end
#	      end
#	   end
#	end
#	
#	search = Widget.search do
#	   dynamic :key_value_pairs do
#	      #  loop over all given keys and facets
#	      Widget.search{ facet :key_value_pairs_keys 
#	         }.facet(:key_value_pairs_keys).rows.collect(&:value).each do |kvp_facet|
#	         facet( kvp_facet )
#	      end
#	   end
#	end
#	
#
#
#
#
#
#	While the above may work, it will be challenging to integrate with my sunspotter gem
#	Sadly, multiple blocks don't work.  Each overwrites the previous one.
#
#	Could still treat them like a column here, but group them together in my gem?
#	Actually don't have a name, so ... hmmm ...
#
#		add_sunspot_column( :namespace => :enrollments, 
#			:
#
#			:meth => ->(s){ s.ccls_enrollment.try(:assigned_for_interview_at).try(:to_date).try(:strftime,'%m/%d/%Y') },
#
#
#
#	This works, but seems ugly.  My gem would rely on it, which would be bad.
#	Interesting solution, though.
#
#	def method_missing(meth, *args, &block)
#		if meth.to_s =~ /^enrollments:(.+)__(.+)$/
#			enrollments.where(:project_id => Project[$1]).first.send($2)
#		else
#			super # You *must* call super if you don't handle the
#                # method, otherwise you'll mess up Ruby's method
#                # lookup.
#		end
#	end




--------------------------------------------------

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

--------------------------------------------------





If you have a hash (perhaps stored in a serialized text field), apparently "dynamic_string :my_hash_attribute" works?
( serialized :custom_string, Hash )
Still haven't figured out how to figure out what all the user-created keys to these hashes are though.










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




#StudySubject.search{ dynamic :enrollments do facet(:ccls__consented) end }.facet(:enrollments, :ccls__consented).rows
#StudySubject.search{ dynamic :enrollments do facet(:ccls__is_eligible) end }.facet(:enrollments, :ccls__is_eligible).rows
#StudySubject.search{ dynamic :enrollments do facet(:home_dust__consented) end }.facet(:enrollments, :home_dust__consented).rows
#StudySubject.search{ dynamic :enrollments do facet(:home_dust__is_eligible) end }.facet(:enrollments, :home_dust__is_eligible).rows
