class ActiveScaffold::PatientsController < ActiveScaffoldController

	active_scaffold :patient do |config|
		#	Not entirely necessary as uses titleized resource
#		config.label = "Subject Race"

		#	even though it isn't yet edittable, these convert the values in show.
		config.columns[:was_ca_resident_at_diagnosis].form_ui = :select
		config.columns[:was_ca_resident_at_diagnosis].options[:options] = as_yndk_select

		config.columns[:was_previously_treated].form_ui = :select
		config.columns[:was_previously_treated].options[:options] = as_yndk_select

		config.columns[:was_under_15_at_dx].form_ui = :select
		config.columns[:was_under_15_at_dx].options[:options] = as_yndk_select

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [:races]

#	Any associations need an activescaffold or normal controller as well.

#		#	Or specifically exclude some columns
#		config.columns.exclude :abstracts, :addresses
	end

end
