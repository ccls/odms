class IcfMasterId < ActiveRecord::Base

	belongs_to :study_subject
  attr_protected( :study_subject_id, :study_subject )

#	probably shouldn't add validations as this won't be created by users. yet.

	def to_s
		icf_master_id
	end

	scope :unused,      where('study_subject_id IS NULL')
#	scope :next_unused, unused.limit(1)	#	NOTE still returns an array
#	I noticed that there are gaps, so explicitly order by id
	scope :next_unused, unused.order('id asc').limit(1)	#	NOTE still returns an array

end
