class ActiveScaffold::AddressesController < ActiveScaffoldController

	active_scaffold :address do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Addresses"

		config.actions.add :update
		config.columns[:address_type].form_ui = :select

#		config.columns[:is_valid].form_ui = :select
#		config.columns[:is_valid].options[:options] = as_yndk_select

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [

#	Any associations need an activescaffold or normal controller as well.

#		#	Or specifically exclude some columns

		#	study_subject is a problem through addressing
		config.columns.exclude :addressing, :interviews, :study_subject
	end

end
