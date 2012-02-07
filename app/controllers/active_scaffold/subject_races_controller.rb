class ActiveScaffold::SubjectRacesController < ActiveScaffoldController

#	TEST ME

  active_scaffold :subject_race do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Subject Race"

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [:races,:birth_county,:birth_type, :dad_is_biodad,
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
