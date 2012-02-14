class ActiveScaffold::PhoneNumbersController < ActiveScaffoldController

	active_scaffold :phone_number do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Phone Numbers"

		config.actions.add :update

		config.columns[:data_source].form_ui = :select
		config.columns[:phone_type].form_ui = :select

		config.columns[:is_valid].form_ui = :select
		config.columns[:is_valid].options[:options] = as_yndk_select

		config.columns[:current_phone].form_ui = :select
		config.columns[:current_phone].options[:options] = as_yndk_select

#	probably shouldn't have these verified columns as editable
#		config.columns[:verified_by_uid].form_ui = :select
#		config.columns[:verified_by_uid].options[:options] = user_uid_select


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
		config.columns.exclude :study_subject, :position
	end

end
