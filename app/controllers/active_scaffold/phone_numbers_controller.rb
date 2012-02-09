class ActiveScaffold::PhoneNumbersController < ActiveScaffoldController

#	TEST ME

  active_scaffold :phone_number do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Phone Numbers"

		config.actions.add :update

		config.columns[:data_source].form_ui = :select
		config.columns[:phone_type].form_ui = :select

		config.columns[:is_valid].form_ui = :select
		config.columns[:is_valid].options[:options] = [
			['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		config.columns[:current_phone_number].form_ui = :select
		config.columns[:current_phone_number].options[:options] = [
			['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]


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
