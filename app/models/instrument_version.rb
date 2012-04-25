#	==	requires
#	*	key ( unique )
#	*	description ( unique and > 3 chars )
#	*	interview_type_id
class InstrumentVersion < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	belongs_to :language
	belongs_to :instrument_type
	belongs_to :instrument
	has_many :interviews

#	validates_presence_of :instrument_type_id
#		those in fixtures do not have instrument types
	validates_presence_of :instrument_type, :if => :instrument_type_id

	validates_complete_date_for :began_use_on, :ended_use_on, 
		:allow_nil => true

	#	Returns description
	def to_s
		description
	end

end
