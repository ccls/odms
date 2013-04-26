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

#	#	Returns the parent of this sample type
#	def sample_type_parent
#		sample_type.parent
#	end

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




	def self.sunspot_orderable_columns
		%w( id sampleid sample_format sample_temperature project aliquot_or_sample_on_receipt order_no sample_type sample_type_parent subject_type subjectid childid )
	end

	def self.sunspot_available_columns
		%w( id sampleid sample_format sample_temperature project aliquot_or_sample_on_receipt order_no sample_type sample_type_parent subject_type subjectid childid ).sort
	end

	def self.sunspot_default_columns
		%w( id sampleid subjectid sample_type )
	end

	#	in the order that they will appear on the page
	def self.sunspot_all_facets
		%w( sample_format sample_temperature project aliquot_or_sample_on_receipt order_no sample_type sample_type_parent subject_type )
	end

	def self.sunspot_columns
		%w( id sampleid sample_format sample_temperature project aliquot_or_sample_on_receipt order_no sample_type sample_type_parent subject_type subjectid childid )
	end

	searchable do
		integer :id
#		string :parent_sampleid
		string :sampleid
		string :sample_format
		string :sample_temperature
#		string :sample_collector
		string :project
#		string :location #	will require some magic
		string :subjectid	#	more magic, perhaps black
		string :childid		#	more magic, perhaps black
		string :aliquot_or_sample_on_receipt
		string :order_no
		string :sample_type
		string :sample_type_parent	#	rename sample_type_class?
		string :subject_type

#		cdcid?
#		external_id?
#		external_id_source?

#	1419 | aliquot_or_sample_on_receipt | varchar(255) | YES  |     | NULL    |                |
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
