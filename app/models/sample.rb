#	==	requires
#	*	enrollment_id
#	*	unit_id
class Sample < ActiveRecord::Base

	belongs_to :sample_type
	belongs_to :organization, :foreign_key => 'location_id'
	belongs_to :unit     #	NOTE not yet really used
	has_many :aliquots   #	NOTE not yet really used
	has_many :sample_transfers
	belongs_to :project
	belongs_to :study_subject
	belongs_to :sample_format
	belongs_to :sample_temperature

	attr_protected :study_subject_id, :study_subject

#	TODO I don't believe that a sample_kit has any meaning anymore. Remove?
	has_one :sample_kit
	accepts_nested_attributes_for :sample_kit

	validations_from_yaml_file

	#	unfortunately, there are a few samples that do not have a subject????
	delegate :subject_type, :subjectid, :childid, :to => :study_subject, :allow_nil => true

	#	prefix is require as sample has a parent too (well, it will eventually)
	delegate :parent, :to => :sample_type, :allow_nil => true, :prefix => true

	after_initialize :set_defaults, :if => :new_record?
	def set_defaults
		# ||= doesn't work with ''
		self.aliquot_or_sample_on_receipt ||= 'Sample'
		self.order_no ||= 1
		self.location_id ||= Organization['CCLS'].id
	end

	def sampleid
#	I think back in ruby 1.8.7 self.id returned the object id, NOT the database record id.  VERY DIFFERENT.
#		sprintf('%07d',self.attributes['id']) unless new_record?
		sprintf('%07d',self.id) unless new_record?
	end

	#	for destroy confirmation pop-up
	def to_s
		"SampleID #{sampleid}"
	end

	after_save :reindex_study_subject!


	include Sunspotability
	
	self.all_sunspot_columns << SunspotColumn.new(:id, :default => true, :type => :integer)
	self.all_sunspot_columns << SunspotColumn.new(:sampleid, :default => true)
	self.all_sunspot_columns << SunspotColumn.new(:subjectid, :default => true)
	self.all_sunspot_columns << SunspotColumn.new(:sample_type, :default => true, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:sample_format, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:sample_temperature, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:project, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:aliquot_or_sample_on_receipt, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:order_no, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:sample_type_parent, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:subject_type, :facetable => true)
	self.all_sunspot_columns << SunspotColumn.new(:childid)
	self.all_sunspot_columns << SunspotColumn.new(:external_id)
	self.all_sunspot_columns << SunspotColumn.new(:external_id_source)

	searchable do
##		string :parent_sampleid
##		string :sample_collector
##		string :location #	will require some magic

		sunspot_integer_columns.each {|c| integer c }
		sunspot_string_columns.each {|c| string c }
		sunspot_nulled_string_columns.each {|c| string(c){ send(c)||'NULL' } }
		sunspot_date_columns.each {|c| date c }
		sunspot_double_columns.each {|c| double c }
		sunspot_time_columns.each {|c| time c }
		sunspot_boolean_columns.each {|c|
			string(c){ ( send(c).nil? ) ? 'NULL' : ( send(c) ) ? 'Yes' : 'No' } }
		
#		cdcid?
#		external_id_source?

#	1420 | sent_to_subject_at           | datetime     | YES  |     | NULL    |                |
#	1421 | collected_from_subject_at    | datetime     | YES  |     | NULL    |                |
#	1422 | shipped_to_ccls_at           | datetime     | YES  |     | NULL    |                |
#	1423 | received_by_ccls_at          | datetime     | YES  |     | NULL    |                |
#	1424 | sent_to_lab_at               | datetime     | YES  |     | NULL    |                |
#	1425 | received_by_lab_at           | datetime     | YES  |     | NULL    |                |
#	1426 | aliquotted_at                | datetime     | YES  |     | NULL    |                |
#	1427 | external_id                  | varchar(255) | YES  |     | NULL    |                |
#	1428 | external_id_source           | varchar(255) | YES  |     | NULL    |                |
#	1429 | receipt_confirmed_at         | datetime     | YES  |     | NULL    |                |
#	1430 | receipt_confirmed_by         | varchar(255) | YES  |     | NULL    |                |
#	1431 | future_use_prohibited        | tinyint(1)   | NO   |     | 0       |                |
#	1432 | state                        | varchar(255) | YES  |     | NULL    |                |
#	1435 | notes 


#		text?	#	may need to modify the free text token algorithm so searches partial words
#		text :notes
	
	end	#	searchable do

protected

	def reindex_study_subject!
		study_subject.index if study_subject
	end

end
