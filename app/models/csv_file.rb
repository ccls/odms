require 'csv'

class CSVFile

	attr_accessor :csv_file
	attr_accessor :options
	attr_accessor :verbose
	attr_accessor :status

	def initialize(csv_file,options={})
		self.options = options.with_indifferent_access
		self.status = ''
		self.csv_file = csv_file
		self.verbose = self.options[:verbose] || false
	end

	def actual_columns
		@actual_columns ||= CSV.open(csv_file,'rb'){|f| f.readline }
	end

	# includes header, but so does f.lineno
	def total_lines
		@total_lines ||= CSV.open(csv_file,'rb'){|f| f.readlines.size }
	end

end
