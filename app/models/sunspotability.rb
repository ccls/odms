module Sunspotability
def self.included(base)
base.class_eval do
#
#	MUST delay execution of code until included as cattr_accessor is ActiveRecord specific
#
	cattr_accessor :all_sunspot_columns
	self.all_sunspot_columns = []		#	order is only relevant to the facets

	def self.add_sunspot_column(*args)
		self.all_sunspot_columns.push( SunspotColumn.new( *args ) )
	end

	def self.sunspot_orderable_columns
		all_sunspot_columns.select{|c|c.orderable}	#.collect(&:name)
	end

	def self.sunspot_orderable_column_names
		sunspot_orderable_columns.collect(&:name)
	end

	def self.sunspot_default_columns
		all_sunspot_columns.select{|c|c.default}
	end

	def self.sunspot_default_column_names
		sunspot_default_columns.collect(&:name)
	end

	#	in the order that they will appear on the page
	def self.sunspot_all_facet_names
		all_sunspot_columns.select{|c|c.facetable}.collect(&:name)
	end

	def self.sunspot_columns
		all_sunspot_columns
	end

	def self.sunspot_column_names
		all_sunspot_columns.collect(&:name)
	end

	def self.sunspot_available_columns
		sunspot_columns
	end

	def self.sunspot_available_column_names
		sunspot_column_names.sort
	end

#	def self.sunspot_time_columns
#		all_sunspot_columns.select{|c|c.type == :time }	#.collect(&:name)
#	end
#
	def self.sunspot_date_columns
		all_sunspot_columns.select{|c|c.type == :date }	#.collect(&:name)
	end
#
#	def self.sunspot_integer_columns
#		all_sunspot_columns.select{|c|c.type == :integer }	#.collect(&:name)
#	end
#
#	def self.sunspot_long_columns
#		all_sunspot_columns.select{|c|c.type == :long }	#.collect(&:name)
#	end
#
#	def self.sunspot_double_columns
#		all_sunspot_columns.select{|c|c.type == :double }	#.collect(&:name)
#	end
#
#	def self.sunspot_float_columns
#		all_sunspot_columns.select{|c|c.type == :float }	#.collect(&:name)
#	end
#
#	def self.sunspot_boolean_columns
#		all_sunspot_columns.select{|c|c.type == :boolean }	#.collect(&:name)
#	end
#
#	def self.sunspot_string_columns
##	don't do this.  the cached value ends up being shared across all models that use this
##	last caller wins.
##		@@sunspot_string_columns ||= all_sunspot_columns.select{|c|c.type == :string }.collect(&:name)
#		all_sunspot_columns.select{|c|c.type == :string }	#.collect(&:name)
#	end
#
##	def self.sunspot_nulled_string_columns
##		all_sunspot_columns.select{|c|c.type == :nulled_string }	#.collect(&:name)
##	end
##
##	def self.sunspot_multistring_columns
#	def self.sunspot_multi_columns
#		all_sunspot_columns.select{|c| c.multiple }
#	end

#	What was an unindexed column for???
#	def self.sunspot_unindexed_columns
#		all_sunspot_columns.select{|c|c.type == :unindexed }.collect(&:name)
#	end

	def self.searchable_plus(&block)
		searchable do
#			sunspot_integer_columns.each {|c| 
#				integer c.name, :trie => true }
#			sunspot_long_columns.each {|c| 
#				long c.name, :trie => true }
#			sunspot_string_columns.select{|c| !c.multiple }.each {|c| 
#				string c.name }
#			sunspot_nulled_string_columns.each {|c| 
#				string(c.name){ send(c.name)||'NULL' } }
#			sunspot_date_columns.each {|c| 
#				date c.name }
#			sunspot_double_columns.each {|c| 
#				double c.name, :trie => true }
#			sunspot_float_columns.each {|c| 
#				float c.name, :trie => true }
#			sunspot_time_columns.each {|c| 
#				time c.name, :trie => true }
#			sunspot_boolean_columns.each {|c|
#				string(c.name){ ( send(c.name).nil? ) ? 'NULL' : ( send(c.name) ) ? 'Yes' : 'No' } }
#			sunspot_multi_columns.each {|c|
#				string(c.name, :multiple => true) do 
#					c.hash_table.has_key?(:meth) ? c.meth.call(self) : send( c.meth???? c.name right? )
#				end
#			}

			#
			#	Trying to simplify.  Simplify?  Minimize?
			#	Will I need all of the above methods after this is done?
			#
			all_sunspot_columns.select{|c| ![:boolean,:nulled_string].include?(c.type) }.each{|c|
				options = {}
				options[:multiple] = true if( c.multiple )
				options[:trie] = true if( [:integer,:long,:double,:float,:time].include?(c.type) )
				send( c.type, c.name, options ){
					c.hash_table.has_key?(:meth) ? c.meth.call(self) : send( c.name )
				}
#
#	booleans? nulled_strings?
#
			}


#			yield if block_given?
#			yield block if block_given?
		end	

#	this works, but why can't I just yield inside the block
		searchable &block if block_given?

	end

end
end
end
