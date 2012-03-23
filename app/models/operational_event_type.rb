#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
class OperationalEventType < ActiveRecord::Base

	acts_as_list
#	Don't use default_scope with acts_as_list
#	default_scope :order => :position

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
#		find(:all,
#			:conditions => 'event_category IS NOT NULL',
#			:order => 'event_category ASC',
#			:group => :event_category
#		).collect(&:event_category)
		where('event_category IS NOT NULL'
			).order('event_category ASC'
			).group(:event_category
		).collect(&:event_category)
	end

end
