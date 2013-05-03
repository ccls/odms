module Sunspotability
def self.included(base)
base.class_eval do

	cattr_accessor :all_sunspot_columns
	self.all_sunspot_columns = []		#	order is only relevant to the facets

	def self.sunspot_orderable_columns
		all_sunspot_columns.select{|c|c.orderable}.collect(&:name)
	end

	def self.sunspot_default_columns
		all_sunspot_columns.select{|c|c.default}.collect(&:name)
	end

	#	in the order that they will appear on the page
	def self.sunspot_all_facets
		all_sunspot_columns.select{|c|c.facetable}.collect(&:name)
	end

	def self.sunspot_columns
		all_sunspot_columns.collect(&:name)
	end

	def self.sunspot_available_columns
		sunspot_columns.sort
	end

	def self.sunspot_time_columns
		all_sunspot_columns.select{|c|c.type == :time }.collect(&:name)
	end

	def self.sunspot_date_columns
		all_sunspot_columns.select{|c|c.type == :date }.collect(&:name)
	end

	def self.sunspot_integer_columns
		all_sunspot_columns.select{|c|c.type == :integer }.collect(&:name)
	end

	def self.sunspot_long_columns
		all_sunspot_columns.select{|c|c.type == :long }.collect(&:name)
	end

	def self.sunspot_double_columns
		all_sunspot_columns.select{|c|c.type == :double }.collect(&:name)
	end

	def self.sunspot_float_columns
		all_sunspot_columns.select{|c|c.type == :float }.collect(&:name)
	end

	def self.sunspot_boolean_columns
		all_sunspot_columns.select{|c|c.type == :boolean }.collect(&:name)
	end

	def self.sunspot_string_columns
#	don't do this.  the cached value ends up being shared across all models that use this
#	last caller wins.
#		@@sunspot_string_columns ||= all_sunspot_columns.select{|c|c.type == :string }.collect(&:name)
		all_sunspot_columns.select{|c|c.type == :string }.collect(&:name)
	end

	def self.sunspot_nulled_string_columns
		all_sunspot_columns.select{|c|c.type == :nulled_string }.collect(&:name)
	end

#	What was an unindexed column for???
#	def self.sunspot_unindexed_columns
#		all_sunspot_columns.select{|c|c.type == :unindexed }.collect(&:name)
#	end

	def self.searchable_plus(&block)
		searchable do
			sunspot_integer_columns.each {|c| integer c, :trie => true }
			sunspot_long_columns.each {|c| long c, :trie => true }
			sunspot_string_columns.each {|c| string c }
			sunspot_nulled_string_columns.each {|c| string(c){ send(c)||'NULL' } }
			sunspot_date_columns.each {|c| date c }
			sunspot_double_columns.each {|c| double c, :trie => true }
			sunspot_float_columns.each {|c| float c, :trie => true }
			sunspot_time_columns.each {|c| time c, :trie => true }
			sunspot_boolean_columns.each {|c|
				string(c){ ( send(c).nil? ) ? 'NULL' : ( send(c) ) ? 'Yes' : 'No' } }
#			yield if block_given?
#			yield block if block_given?
		end	

#	this works, but why can't I just yield inside the block
		searchable &block if block_given?

	end

end
end
end
