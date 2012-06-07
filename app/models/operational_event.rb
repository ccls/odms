#	==	requires
#	*	operational_event_type_id
class OperationalEvent < ActiveRecord::Base

	belongs_to :operational_event_type
#	validates_presence_of :operational_event_type_id
	validates_presence_of :operational_event_type, :if => :operational_event_type_id

	belongs_to :study_subject
#	validates_presence_of :study_subject_id
	validates_presence_of :study_subject, :if => :study_subject_id
	attr_protected :study_subject_id, :study_subject

	belongs_to :project
#	validates_presence_of :project_id
	validates_presence_of :project, :if => :project_id

	validates_complete_date_for :occurred_at, :allow_nil => true
	validates_length_of :description, :maximum => 250, :allow_blank => true
	validates_length_of :event_notes, :maximum => 65000, :allow_blank => true

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

protected

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

#	TODO perhaps move the search stuff into OperationalEventSearch?

#	#	find wrapper
#	def self.search(options={})
#		find(:all,
#			:joins => joins(options),
#			:order => order(options),
#			:conditions => conditions(options)
#		)
#	end

#	def self.order(options={})
#		if options.has_key?(:order) && valid_order?(options[:order])
#			order_string = case options[:order]
#				when 'type' then 'operational_event_types.description'
#				else options[:order]
#			end
#			dir = case options[:dir].try(:downcase)
#				when 'asc'  then 'asc'
#				when 'desc' then 'desc'
#				else 'desc'
#			end
#			[order_string,dir].join(' ')
#		else
#			nil
#		end
#	end
#
#	def self.joins(options={})
##	TODO may have to use sql for LEFT JOINS rather than the rails symbol
#		joins = []
#		if options.has_key?(:order) && valid_order?(options[:order])
#			case options[:order]
#				when 'type' then joins << :operational_event_type
##	'LEFT JOIN operational_event_types ON operational_events.operational_event_type_id = operational_event_types.id',
#			end
#		end	
#		if options.has_key?(:study_subject_id) and !options[:study_subject_id].blank?
#			joins << :enrollment
##	'LEFT JOIN enrollments ON operational_events.enrollment_id = enrollments.id',
#		end
#		joins
#	end
#
#	def self.conditions(options={})
#		conditions = [[],[]]
#		if options.has_key?(:study_subject_id) and !options[:study_subject_id].blank?
#			conditions[0] << '(enrollments.study_subject_id = ?)'
#			conditions[1] << options[:study_subject_id]
#		end
#		unless conditions.flatten.empty?
#			[ conditions[0].join(' AND '), *(conditions[1].flatten) ]
#		else
#			nil
#		end
#	end

