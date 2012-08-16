#
#	I'm here to allow for the adding to test helper
#	without autotest restarting all of your tests.
#


require 'screening_datum_update_test_helper'

class ActiveSupport::TestCase

	def illegal_csv_quote_line
		"test\""
	end

	def unclosed_csv_quote_line
		",\","
	end

	def stray_csv_quote_line
		"\"asdf\"a,"
	end

	#	I don't think that the actual name really matters.
	#	It just needs to be consistent
	def csv_test_file_name
		"tmp/#{self.class.name.underscore}.csv"
	end

	def create_stray_quote_csv_file
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts stray_csv_quote_line }
	end

	def create_unclosed_quote_csv_file
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts unclosed_csv_quote_line }
	end

	def create_illegal_quote_csv_file
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts illegal_csv_quote_line }
	end

end

