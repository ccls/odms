#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectIcfMasterId
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	attr_protected :icf_master_id

	#	We probably don't want to auto assign icf_master_ids 
	#		as it would add icf_master_ids to the old data.
	#	Perhaps, after the old data is imported, but that
	#		will definitely break a bunch of existing tests.
	def assign_icf_master_id
		if icf_master_id.blank?
			next_icf_master_id = IcfMasterId.next_unused.first
			if next_icf_master_id
				self.update_column(:icf_master_id, next_icf_master_id.to_s)
				next_icf_master_id.study_subject = self
				next_icf_master_id.assigned_on   = Date.today
				next_icf_master_id.save!
			end
		end
		self
	end

	def icf_master_id_to_s
		( icf_master_id.blank? ) ?  "[no ID assigned]" : icf_master_id
	end

end	#	class_eval
end	#	included
end	#	StudySubjectIcfMasterId
