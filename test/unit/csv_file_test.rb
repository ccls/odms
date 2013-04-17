require 'test_helper'

class CSVFileTest < ActiveSupport::TestCase

	teardown :cleanup_test_file

	test "should return total lines count" do
		File.open(csv_test_file_name,'w'){|f| f.puts "1,2,3"; f.puts "1,2,3"; f.puts "1,2,3"; }
		csv_file = CSVFile.new(csv_test_file_name)
		assert_equal 3, csv_file.total_lines
	end

	test "should return columns" do
		File.open(csv_test_file_name,'w'){|f| f.puts "column1, column 2 , column 3 " }
		csv_file = CSVFile.new(csv_test_file_name)
		assert_equal ['column1',' column 2 ',' column 3 '], csv_file.actual_columns
	end

	def csv_test_file_name
		'tmp/csv_file_test_file.csv'
	end

	def cleanup_test_file
		if File.exists?(csv_test_file_name)
			# explicit delete to remove test file
			File.delete(csv_test_file_name)
		end
		assert !File.exists?(csv_test_file_name)
	end

end
