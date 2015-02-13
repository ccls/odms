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
		sprintf('%07d',self.id) unless new_record?
	end

	#	for destroy confirmation pop-up
	def to_s
		"SampleID #{sampleid}"
	end

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	VALID_SAMPLE_TEMPERATURES = ["Room Temperature", "Refrigerated"]

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the phone type.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def sample_temperatures
		([self.sample_temperature] + VALID_SAMPLE_TEMPERATURES ).compact.uniq
	end

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	#
	#	Only have Guthrie Cards in db
	#
	VALID_SAMPLE_FORMATS = ["Guthrie Card", "Slide", "Vacuum Bag", "Other Source", 
			"Migrated from CCLS Legacy Tracking2k database", "Unknown Data Source"]

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the phone type.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def sample_formats
		([self.sample_format] + VALID_SAMPLE_FORMATS ).compact.uniq
	end

	validations_from_yaml_file

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

	include ActiveRecordSunspotter::Sunspotability

	#	Added a leading space so Microsoft doesn't muck up the csv
	
	add_sunspot_column(:id, :default => true, :type => :integer)
	add_sunspot_column(:sampleid, :default => true,
		:meth => ->(s){" #{s.sampleid}"} )
	add_sunspot_column(:subjectid, :default => true,
		:meth => ->(s){" #{s.subjectid}"} )
	add_sunspot_column(:sample_super_type,
		:default => true, :facetable => true)
	add_sunspot_column(:sample_type,
		:default => true, :facetable => true)
	add_sunspot_column(:gegl_sample_type_id, :default => true, :facetable => true,
		:meth => ->(s){ s.sample_type.gegl_sample_type_id })
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
		:type => :integer, :orderable => true)
	add_sunspot_column(:first_name)
	add_sunspot_column(:last_name)
	add_sunspot_column(:icf_master_id)
	add_sunspot_column(:patid)
	add_sunspot_column(:studyid)
	add_sunspot_column(:childid)
	add_sunspot_column(:external_id)
	add_sunspot_column(:external_id_source, :facetable => true)
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

	searchable_plus

protected

	def reindex_study_subject!
		logger.debug "Sample changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
	end

end
