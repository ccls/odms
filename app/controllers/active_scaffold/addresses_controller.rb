class ActiveScaffold::AddressesController < ActiveScaffoldController

#	TEST ME

  active_scaffold :address do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "Addresses"

		config.actions.add :update
		config.columns[:address_type].form_ui = :select

#		config.columns[:is_valid].form_ui = :select
#		config.columns[:is_valid].options[:options] = [
#			['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [

#	Any associations need an activescaffold or normal controller as well.

#		#	Or specifically exclude some columns
		config.columns.exclude :addressing, :interviews
	end

end
