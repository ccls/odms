require 'ostruct'
class SunspotColumn < OpenStruct

	def initialize(*args)
		#	some sensible defaults
		default_options = {
			:type      => :string, 
			:orderable => true, 
			:facetable => false, 
			:multiple  => false, 
			:default   => false
		}
		options = args.extract_options!.with_indifferent_access
		if [String,Symbol].include?( args.first.class ) and !options.has_key?(:name)
			options[:name] = args.first.to_s
		end

#		if( options[:type] == :null_yndk_string ) && options[:meth].blank?
#			options[:meth] = ->(s){ YNDK[s.send(:name)]||'NULL' }
#			options[:type] = :string
#		end

		default_options.update(options)
#		default_options[:orderable] = false if options[:type] == :multistring
		default_options[:orderable] = false if options[:multiple]
		super default_options
	end

	def hash_table
		instance_variable_get("@table")
	end

	def to_s
		name
	end

end
