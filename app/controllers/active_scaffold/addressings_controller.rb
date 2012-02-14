class ActiveScaffold::AddressingsController < ActiveScaffoldController

	active_scaffold :addressing do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Addressings"

		#	I NEED to explicitly set this to edit or in production it will be show.
		#	config.cache_classes = true	seems to be the "cause"
		#	changing it to false fixes it, but we want it to be true.
		config.columns[:address].actions_for_association_links = [:edit]

		config.actions.add :update
		config.columns[:data_source].form_ui = :select

		config.columns[:address_at_diagnosis].form_ui = :select
		config.columns[:address_at_diagnosis].options[:options] = as_yndk_select
#[ ['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		config.columns[:is_valid].form_ui = :select
		config.columns[:is_valid].options[:options] = as_yndk_select
#[ ['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		config.columns[:current_address].form_ui = :select
		config.columns[:current_address].options[:options] = as_yndk_select
#[ ['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [

#	Any associations need an activescaffold or normal controller as well.

		#	Or specifically exclude some columns

		#	use 'config.update' instead of 'config' to exclude from 'update' action.
		#	config.update MUST be AFTER adding the update action.
		config.update.columns.exclude :address, :study_subject
	end

end
