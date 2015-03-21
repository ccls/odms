#	==	requires
#	*	operational_event_type_id
class OperationalEvent < ActiveRecord::Base

	belongs_to :operational_event_type

	validations_from_yaml_file

	belongs_to :study_subject, :counter_cache => true
#	attr_protected :study_subject_id, :study_subject

	belongs_to :project

	scope :screener_complete, ->{ joins(:operational_event_type)
		.merge(OperationalEventType.screener_complete).readonly(false) }

	scope :unended_project, ->{ joins(:project).merge(Project.unended).readonly(false) }

	#	Returns description
	def to_s
		description
	end

	before_save :copy_operational_event_type_description

#	This kinda works, but needs more love
#
	#	1 column with optional direction "id ASC" 
	def self.valid_order(query_order=nil)
		col,dir = (query_order||'').split()
		dir ||= 'ASC'
#		( valid_orders.include?(col.downcase) and %w(ASC DESC).include?(dir.upcase) ) ?
		( valid_column?(col) and %w(ASC DESC).include?(dir.upcase) ) ?
			order( [col,dir].join(' ') ) : all
	end

	#	just in case I missed a spot
	def occurred_on
		occurred_at.try(:to_date)
	end

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Operational Event changed so reindexing study subject"
		#	this used to work without the new_record check (new_record? doesn't work? using persisted? )
		#	the persisted check only seems to matter when the before_destroy callback exists
		#	my "assert_should_belong_to" test method does a destroy 
		#	which is what makes this required. (was for testing attachments, but still viable)
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
	end

	def copy_operational_event_type_description
		if self.description.blank? and !operational_event_type.nil?
			self.description = operational_event_type.description
		end
	end

	def self.valid_column?(col)
		valid_columns.include?(col.downcase)
	end

	def self.valid_columns
		%w( id occurred_at description )	#type )
	end

end
