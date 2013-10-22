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
	belongs_to :sample_format
	belongs_to :sample_temperature

	attr_protected :study_subject_id, :study_subject

#	TODO I don't believe that a sample_kit has any meaning anymore. Remove?
#	has_one :sample_kit
#	accepts_nested_attributes_for :sample_kit

	validations_from_yaml_file

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

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

	include Sunspotability
	
	self.all_sunspot_columns = [ 
		SunspotColumn.new(:id, :default => true, :type => :integer),
		SunspotColumn.new(:sampleid, :default => true),
		SunspotColumn.new(:subjectid, :default => true),
#		SunspotColumn.new(:sample_type_parent,
		SunspotColumn.new(:sample_super_type,
			:default => true, :facetable => true),
		SunspotColumn.new(:sample_type,
			:default => true, :facetable => true),
		SunspotColumn.new(:sample_format, :facetable => true),
		SunspotColumn.new(:sample_temperature, :facetable => true),
		SunspotColumn.new(:project, :facetable => true),
		SunspotColumn.new(:aliquot_or_sample_on_receipt,
			:facetable => true),
		SunspotColumn.new(:order_no, :facetable => true),
		SunspotColumn.new(:subject_type, :facetable => true),
		SunspotColumn.new(:sex, :facetable => true),
		SunspotColumn.new(:vital_status, :facetable => true),
		SunspotColumn.new(:organization, :facetable => true),
		SunspotColumn.new(:cdcid,
			:default => true, :type => :integer, :orderable => true),
		SunspotColumn.new(:first_name),
		SunspotColumn.new(:last_name),
		SunspotColumn.new(:icf_master_id),
		SunspotColumn.new(:patid),
		SunspotColumn.new(:studyid),
		SunspotColumn.new(:childid),
		SunspotColumn.new(:external_id),
		SunspotColumn.new(:external_id_source),
		SunspotColumn.new(:sent_to_subject_at, :type => :time),
		SunspotColumn.new(:collected_from_subject_at, :type => :time),
		SunspotColumn.new(:shipped_to_ccls_at, :type => :time),
		SunspotColumn.new(:received_by_ccls_at, :type => :time),
		SunspotColumn.new(:sent_to_lab_at, :type => :time),
		SunspotColumn.new(:received_by_lab_at, :type => :time),
		SunspotColumn.new(:aliquotted_at, :type => :time),
		SunspotColumn.new(:receipt_confirmed_at, :type => :time),
		SunspotColumn.new(:dob, :type => :date),
		SunspotColumn.new(:died_on, :type => :date),
		SunspotColumn.new(:admit_date, :type => :date),
		SunspotColumn.new(:reference_date, :type => :date),
		SunspotColumn.new(:diagnosis_date, :type => :date)
	]	#	self.all_sunspot_columns = [ 


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
