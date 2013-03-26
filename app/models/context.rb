#	==	requires
#	*	description (unique and >3 chars)
class Context < ActiveRecord::Base
#
#	acts_as_list
#	acts_like_a_hash
#
##	This should probably go away as I do not think that it is ever used
##	Not really sure if it ever was.
#	has_many :units
#
##	has_many :people
#
#	has_many :context_contextables
#	has_many :data_sources, :through => :context_contextables, 
#		:source => :contextable, :source_type => 'DataSource'
#	has_many :languages, :through => :context_contextables, 
#		:source => :contextable, :source_type => 'Language'
#	has_many :diagnoses, :through => :context_contextables, 
#		:source => :contextable, :source_type => 'Diagnosis'
#	has_many :sample_temperatures, :through => :context_contextables, 
#		:source => :contextable, :source_type => 'SampleTemperature'
#
#	validations_from_yaml_file
#
#	#	Returns description
#	def to_s
#		description
#	end
#
##	has_many :contextables, :through => :context_contextables
##	raises error when called
##	irb(main):010:0> c.contextables
##	ActiveRecord::HasManyThroughAssociationPolymorphicSourceError: Cannot have a has_many :through association 'Context#contextables' on the polymorphic object 'Contextable#contextable'.
##	however, this method works
#
#	def contextables
#		context_contextables.collect(&:contextable)
#	end
#
end
