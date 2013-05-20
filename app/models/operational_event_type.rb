#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class OperationalEventType < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :operational_events

	# Created for simplification of OperationalEvent.screener_complete scope
	scope :screener_complete, where(:key => 'screener_complete')

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

	def self.with_category(category=nil)
		( category.blank? ) ? scoped : where(:event_category => category)
	end

end
