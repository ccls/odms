class ActiveScaffold::AddressingsController < ActiveScaffoldController

#	TEST ME

  active_scaffold :addressing do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Addressings"

		config.actions.add :update
		config.columns[:data_source].form_ui = :select

		config.columns[:address_at_diagnosis].form_ui = :select
		config.columns[:address_at_diagnosis].options[:options] = [
			['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		config.columns[:is_valid].form_ui = :select
		config.columns[:is_valid].options[:options] = [
			['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [

#	Any associations need an activescaffold or normal controller as well.

		#	Or specifically exclude some columns

		#	use 'update' instead of 'config' to exclude from 'update' action.
		update.columns.exclude :address
	end

end
