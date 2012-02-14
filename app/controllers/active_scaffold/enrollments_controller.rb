class ActiveScaffold::EnrollmentsController < ActiveScaffoldController

	active_scaffold :enrollment do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Enrollments"

#	All these options get stored in the session and will cause ...
#/!\ FAILSAFE /!\  Fri Feb 10 15:00:54 -0800 2012
#  Status: 500 Internal Server Error
#  ActionController::Session::CookieStore::CookieOverflow
#	May need to convert to active_record_session_store

		#	even though it isn't yet edittable, these convert the values in show.
		config.columns[:able_to_locate].form_ui = :select
		config.columns[:able_to_locate].options[:options] = as_yndk_select
		config.columns[:is_candidate].form_ui = :select
		config.columns[:is_candidate].options[:options] = as_yndk_select
		config.columns[:is_eligible].form_ui = :select
		config.columns[:is_eligible].options[:options] = as_yndk_select
		config.columns[:consented].form_ui = :select
		config.columns[:consented].options[:options] = as_yndk_select
		config.columns[:is_chosen].form_ui = :select
		config.columns[:is_chosen].options[:options] = as_yndk_select
		config.columns[:terminated_participation].form_ui = :select
		config.columns[:terminated_participation].options[:options] = as_yndk_select
		config.columns[:is_complete].form_ui = :select
		config.columns[:is_complete].options[:options] = as_yndk_select
		config.columns[:use_smp_future_rsrch].form_ui = :select
		config.columns[:use_smp_future_rsrch].options[:options] = as_yndk_select
		config.columns[:use_smp_future_cancer_rsrch].form_ui = :select
		config.columns[:use_smp_future_cancer_rsrch].options[:options] = as_yndk_select
		config.columns[:use_smp_future_other_rsrch].form_ui = :select
		config.columns[:use_smp_future_other_rsrch].options[:options] = as_yndk_select
		config.columns[:share_smp_with_others].form_ui = :select
		config.columns[:share_smp_with_others].options[:options] = as_yndk_select
		config.columns[:contact_for_related_study].form_ui = :select
		config.columns[:contact_for_related_study].options[:options] = as_yndk_select
		config.columns[:provide_saliva_smp].form_ui = :select
		config.columns[:provide_saliva_smp].options[:options] = as_yndk_select
		config.columns[:receive_study_findings].form_ui = :select
		config.columns[:receive_study_findings].options[:options] = as_yndk_select

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [
#			:identifier,:pii, :patient,
#			:subject_languages,:subject_races,
#			:birth_county,:birth_type, :dad_is_biodad,
#			:do_not_contact, :father_hispanicity_mex, :father_yrs_educ,
#			:is_duplicate_of, :mom_is_biomom, :mother_hispanicity_mex,
#			:mother_yrs_educ, :sex ]

#	Any associations need an activescaffold or normal controller as well.

#		#	Or specifically exclude some columns
#		config.columns.exclude :abstracts, :addresses, :addressings,
#			:analyses, :bc_requests, :enrollments, :first_abstract, 
#			:gift_cards, :home_exposure_response, :homex_outcome, 
#			:identifier, :interviews, :languages, :merged_abstract,
#			:operational_events, :patient, :phone_numbers, :pii, :races,
#			:samples, :second_abstract, :subject_languages, :subject_races,
#			:unmerged_abstracts
#	would be simpler just to list the included columns in this case
#	can I just exclude all associations?
	end

end
