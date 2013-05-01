require 'csv'

class CSVFile

#	CSV::HeaderConverters[:debom]=lambda{|s|s.sub("\xEF\xBB\xBF", '')}
#	CSV::HeaderConverters[:debom]=lambda{|s|s.encode('UTF-8',:undef => :replace, :replace => '')}
#	CSV::Converters[:debom]=lambda{|s|s.encode('UTF-8',:undef => :replace, :replace => '')}

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
#		@actual_columns ||= CSV.open(csv_file,'rb',{:header_converters => [:debom]}){|f| f.readline }
#		@actual_columns ||= CSV.open(csv_file,'rb',{:converters => [:debom]}){|f| f.readline }

#		@actual_columns ||= CSV.open(csv_file,'rb',{:headers => true, :header_converters => [:debom]}){|f| 
#			f.readline; f.headers }
#	could just use the header converter if did this a bit differently
#	"headers" aren't available until after the first read.

#
#	or you can use the little known file mode addition ':bom|utf-8'
#
		@actual_columns ||= CSV.open(csv_file,'rb:bom|utf-8'){|f| f.readline }
	end

	# includes header, but so does f.lineno
	def total_lines
		@total_lines ||= CSV.open(csv_file,'rb'){|f| f.readlines.size }
	end

end
__END__

Some of the files coming from Janice have a BOM.

This is proving challenging to deal with.


Current fix ... open 'rt' instead of 'rb'.
Create and use the :debom CSV::HeaderConverter

opening with this converter and 'rb' will raise ...
Encoding::CompatibilityError: incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string)

trying to encode the BOM to UTF-8 will raise ...
Encoding::UndefinedConversionError: "\xEF" from ASCII-8BIT to UTF-8

OOOOOOO
CSV::HeaderConverters[:debom]=lambda{|s|s.encode('UTF-8',:undef => :replace, :replace => '')}

if encode and set replace to '' for undef, it works and don't need the sub
