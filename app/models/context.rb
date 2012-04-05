#	==	requires
#	*	description (unique and >3 chars)
class Context < ActiveRecord::Base

	acts_as_list
#	Don't use default_scope with acts_as_list
#	default_scope :order => :position

	acts_like_a_hash

	has_many :units
#	has_many :people

	has_many :context_contextables
	has_many :data_sources, :through => :context_contextables, 
		:source => :contextable, :source_type => 'DataSource'
	has_many :languages, :through => :context_contextables, 
		:source => :contextable, :source_type => 'Language'

	validates_length_of :notes, :maximum => 65000, :allow_blank => true

	#	Returns description
	def to_s
		description
	end

end
