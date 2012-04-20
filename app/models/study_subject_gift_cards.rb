#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectGiftCards
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :gift_cards

	accepts_nested_attributes_for :gift_cards

end	#	class_eval
end	#	included
end	#	StudySubjectGiftCards
