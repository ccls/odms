module Sunspotability
def self.included(base)
base.class_eval do

	cattr_accessor :all_sunspot_columns
	self.all_sunspot_columns = []		#	order is only relevant to the facets

#	self.all_sunspot_columns = []		#	order is only relevant to the facets
#	@@all_sunspot_columns = []		#	order is only relevant to the facets
#	self.all_sunspot_columns << SunspotColumn.new(:id, :default => true)
#	self.all_sunspot_columns << SunspotColumn.new(:sampleid, :default => true)
#	self.all_sunspot_columns << SunspotColumn.new(:subjectid, :default => true)
#	self.all_sunspot_columns << SunspotColumn.new(:sample_type, :default => true, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:sample_format, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:sample_temperature, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:project, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:aliquot_or_sample_on_receipt, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:order_no, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:sample_type_parent, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:subject_type, :facetable => true)
#	self.all_sunspot_columns << SunspotColumn.new(:childid)

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

	def self.sunspot_double_columns
		all_sunspot_columns.select{|c|c.type == :double }.collect(&:name)
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

	def self.sunspot_unindexed_columns
		all_sunspot_columns.select{|c|c.type == :unindexed }.collect(&:name)
	end

end
end
end
