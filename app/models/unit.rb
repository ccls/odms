#	==	requires
#	*	description ( unique and > 3 chars )
class Unit < ActiveRecord::Base

#	NOTE this is not used


	acts_as_list
	acts_like_a_hash

#	belongs_to :context
	has_many :aliquots
	has_many :samples

end
