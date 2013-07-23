require 'ostruct'
class SunspotColumn < OpenStruct

	def initialize(*args)
		#	some sensible defaults
		default_options = {
			:type      => :string, 
			:orderable => true, 
			:facetable => false, 
			:default   => false
		}
		options = args.extract_options!.with_indifferent_access
		if [String,Symbol].include?( args.first.class ) and !options.has_key?(:name)
			options[:name] = args.first.to_s
		end
		default_options.update(options)
		default_options[:orderable] = false if options[:type] == :multistring
		super default_options
	end

	def to_s
		name
	end

end
