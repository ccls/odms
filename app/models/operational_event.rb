#	==	requires
#	*	operational_event_type_id
class OperationalEvent < ActiveRecord::Base

	belongs_to :operational_event_type

	validations_from_yaml_file

	belongs_to :study_subject, :counter_cache => true
	attr_protected :study_subject_id, :study_subject

	belongs_to :project

	scope :screener_complete, joins(:operational_event_type)
		.merge(OperationalEventType.screener_complete).readonly(false)

	scope :unended_project, joins(:project).merge(Project.unended).readonly(false)

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
			order( [col,dir].join(' ') ) : scoped
	end

	#	just in case I missed a spot
	def occurred_on
		occurred_at.try(:to_date)
	end

	after_save :reindex_study_subject!, :if => :changed?

protected

	def reindex_study_subject!
		logger.debug "Operational Event changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
#		study_subject.index if study_subject
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
