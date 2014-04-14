#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class OperationalEventType < ActiveRecord::Base

	attr_accessible :key, :description, :event_category #	position?

	acts_as_list
	acts_like_a_hash

	has_many :operational_events

	# Created for simplification of OperationalEvent.screener_complete scope
	scope :screener_complete, ->{ where(:key => 'screener_complete') }
	scope :with_category, ->(c=nil){ ( c.blank? ) ? all : where(:event_category => c) }

	validations_from_yaml_file

	#	Returns event_category.
	def to_s
		"#{event_category}:#{description}"
	end

	def self.categories
		#	broke up to try to make 100% coverage (20120411)
		oets = where('event_category IS NOT NULL')
		oets = oets.order('event_category ASC')
		oets = oets.group(:event_category)
		oets.collect(&:event_category)
	end

end
