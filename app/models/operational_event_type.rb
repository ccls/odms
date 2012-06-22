#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class OperationalEventType < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :operational_events

	validates_presence_of   :event_category
	validates_uniqueness_of :event_category
	validates_length_of     :event_category, 
		:in => 4..250, :allow_blank => true

	#	Returns event_category.
	def to_s
		"#{event_category}:#{description}"
	end

	def self.categories
#		where('event_category IS NOT NULL'
#			).order('event_category ASC'
#			).group(:event_category
#		).collect(&:event_category)
#	breaking up to try to make 100% coverage (20120411)
		oets = where('event_category IS NOT NULL')
		oets = oets.order('event_category ASC')
		oets = oets.group(:event_category)
		oets.collect(&:event_category)
	end

	def self.with_category(category=nil)
		( category.blank? ) ? scoped : where(:event_category => category)
	end

end
