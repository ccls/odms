class ActiveScaffold::PiisController < ActiveScaffoldController

#	TEST ME

  active_scaffold :pii do |config|
		#	Not entirely necessary as uses titleized resource
		config.label = "PII"

		#	The columns shown in the list, show and edit
		#	Don't include calculated columns.
#		config.columns = [:races]

#	Any associations need an activescaffold or normal controller as well.

#		#	Or specifically exclude some columns
#		config.columns.exclude :abstracts, :addresses
	end

end
