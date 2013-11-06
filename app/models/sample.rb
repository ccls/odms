#	==	requires
#	*	enrollment_id
#	*	unit_id
class Sample < ActiveRecord::Base

	belongs_to :sample_type
	belongs_to :organization, :foreign_key => 'location_id'
#	belongs_to :unit     #	NOTE not yet really used
#	has_many :aliquots   #	NOTE not yet really used
	has_many :sample_transfers
	belongs_to :project
	belongs_to :study_subject, :counter_cache => true

	attr_protected :study_subject_id, :study_subject

#	TODO I don't believe that a sample_kit has any meaning anymore. Remove?
#	has_one :sample_kit
#	accepts_nested_attributes_for :sample_kit

	#	unfortunately, there are a few samples that do not have a subject????
	delegate :subject_type, :vital_status, :subjectid, :childid, :studyid,
		:first_name, :last_name, :icf_master_id, :patid, :cdcid, :sex,
		:dob, :died_on, :admit_date, :reference_date, :diagnosis_date,
			:to => :study_subject, :allow_nil => true

	#	prefix is required as sample has a parent too (well, it will eventually)
	delegate :parent, :to => :sample_type, :allow_nil => true, :prefix => true

#	delegate :super_type, :to => :sample_type, :allow_nil => true
#		super_type	#	no
#	delegate :super_type, :to => :sample_type, :allow_nil => true, :prefix => true
#		sample_type_super_type	#	no
	#
	#	this is the parent of the sample_type, NOT the sample's parent's sample type.
	#
	#	change this to sample_super_type?
	#
	def sample_super_type
		try(:sample_type).try(:parent)
	end

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

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	def self.valid_sample_temperatures
#
#	Only have room temp and refrigerated in db
#
#		["room temperature", "refrigerated", "legacy data import", "storage temperature unknown"]
		["Room Temperature", "Refrigerated"]
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the phone type.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def sample_temperatures
	#	[self.sample_temperature] + ( self.class.valid_sample_temperatures - [self.sample_temperature])
	#	[self.sample_temperature].compact + ( self.class.valid_sample_temperatures - [self.sample_temperature])
		([self.sample_temperature] + self.class.valid_sample_temperatures ).compact.uniq
	end

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	def self.valid_sample_formats
#
#	Only have Guthrie Cards in db
#
		["Guthrie Card", "Slide", "Vacuum Bag", "Other Source", 
			"Migrated from CCLS Legacy Tracking2k database", "Unknown Data Source"]
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the phone type.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def sample_formats
	#	[self.sample_format] + ( self.class.valid_sample_formats - [self.sample_format])
	#	[self.sample_format].compact + ( self.class.valid_sample_formats - [self.sample_format])
		([self.sample_format] + self.class.valid_sample_formats ).compact.uniq
	end

	validations_from_yaml_file

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

	include Sunspotability
	
	add_sunspot_column(:id, :default => true, :type => :integer)
	add_sunspot_column(:sampleid, :default => true)
	add_sunspot_column(:subjectid, :default => true)
	add_sunspot_column(:sample_super_type,
		:default => true, :facetable => true)
	add_sunspot_column(:sample_type,
		:default => true, :facetable => true)
	add_sunspot_column(:sample_format, :facetable => true)
	add_sunspot_column(:sample_temperature, :facetable => true)
	add_sunspot_column(:project, :facetable => true)
	add_sunspot_column(:aliquot_or_sample_on_receipt,
		:facetable => true)
	add_sunspot_column(:order_no, :facetable => true)
	add_sunspot_column(:subject_type, :facetable => true)
	add_sunspot_column(:sex, :facetable => true)
	add_sunspot_column(:vital_status, :facetable => true)
	add_sunspot_column(:organization, :facetable => true)
	add_sunspot_column(:cdcid,
		:default => true, :type => :integer, :orderable => true)
	add_sunspot_column(:first_name)
	add_sunspot_column(:last_name)
	add_sunspot_column(:icf_master_id)
	add_sunspot_column(:patid)
	add_sunspot_column(:studyid)
	add_sunspot_column(:childid)
	add_sunspot_column(:external_id)
	add_sunspot_column(:external_id_source)
	add_sunspot_column(:sent_to_subject_at, :type => :time)
	add_sunspot_column(:collected_from_subject_at, :type => :time)
	add_sunspot_column(:shipped_to_ccls_at, :type => :time)
	add_sunspot_column(:received_by_ccls_at, :type => :time)
	add_sunspot_column(:sent_to_lab_at, :type => :time)
	add_sunspot_column(:received_by_lab_at, :type => :time)
	add_sunspot_column(:aliquotted_at, :type => :time)
	add_sunspot_column(:receipt_confirmed_at, :type => :time)
	add_sunspot_column(:dob, :type => :date)
	add_sunspot_column(:died_on, :type => :date)
	add_sunspot_column(:admit_date, :type => :date)
	add_sunspot_column(:reference_date, :type => :date)
	add_sunspot_column(:diagnosis_date, :type => :date)
	add_sunspot_column(:has_study_subject, :facetable => true,
		:meth => ->(s){ ( s.study_subject_id.present? ) ? 'Yes' : 'No'   })


#	ADD ...
#	mother ids?

	searchable_plus

###		string :parent_sampleid
###		string :sample_collector
##	1430 | receipt_confirmed_by         | varchar(255) | YES  |     | NULL  
##	1431 | future_use_prohibited        | tinyint(1)   | NO   |     | 0      
##	1432 | state                        | varchar(255) | YES  |     | NULL    
##	1435 | notes 

protected

	def reindex_study_subject!
		logger.debug "Sample changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
	end

end
