#	Rich join of Subject and Address
class Addressing < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true
	attr_protected :study_subject_id, :study_subject

	belongs_to :address

	delegate :address_type, :street,
		:line_1,:line_2,:unit,:city,:state,:zip,:csz,:county,
			:to => :address, :allow_nil => true

	#	flag used in study_subject's nested attributes for addressing
	#		to not reject if address fields are blank.
	attr_accessor :address_required

	scope :current,  
		->{ where(:current_address => YNDK[:yes]) }
	scope :historic, 
		->{ where(self.arel_table[:current_address].not_eq(YNDK[:yes])) }

	scope :mailing, ->{ joins(:address).merge(Address.mailing) }

	#	Don't do the rejections here.
	accepts_nested_attributes_for :address

	attr_accessor :subject_moved

	#	Used in validations_from_yaml_file, so must be defined BEFORE its calling
	def self.valid_data_sources
		["RAF (CCLS Rapid Ascertainment Form)", "Study Consent Form", "Interview with Subject", 
			"USPS Address Service", "Other Source", "Migrated from Tracking2k database", 
			"Unknown Data Source", "Provided by Survey Research Center ('SRC')", 
			"Provided to CCLS by ICF", "Live Birth data from USC" ]
	end

	# This method is predominantly for a form selector.
	# It will show the existing value first followed by the other valid values.
	# This will allow an existing invalid value to show on the selector,
	#   but should fail on save as it is invalid.  This way it won't
	#   silently change the data source.
	#	On a new form, this would be blank, plus the normal blank, which is ambiguous
	def data_sources
	#	[self.data_source] + ( self.class.valid_data_sources - [self.data_source])
		[self.data_source].compact + ( self.class.valid_data_sources - [self.data_source])
	end

	def data_source_is_other?
		data_source == 'Other Source'
	end

	validations_from_yaml_file

	after_save :create_subject_moved_event, :if => :subject_moved

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Addressing changed so reindexing study subject"
		#	don't know why birth_datum needs persisted? check but here doesn't
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
	end

	#	this will actually create an event on creation as well
	#	if attributes match
	def create_subject_moved_event
		if ['1','true'].include?(subject_moved) &&
				current_address == YNDK[:no] &&
				current_address_was != YNDK[:no] &&
				address.address_type == 'Residence'
			study_subject.operational_events.create!(
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['subject_moved'].id,
				:occurred_at               => DateTime.current
			)
		end
	end

end
__END__
