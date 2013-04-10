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

	after_save :copy_case_icf_master_id
	after_save :copy_mother_icf_master_id

	#	We probably don't want to auto assign icf_master_ids 
	#		as it would add icf_master_ids to the old data.
	#	Perhaps, after the old data is imported, but that
	#		will definitely break a bunch of existing tests.
	def assign_icf_master_id
		if icf_master_id.blank?
			next_icf_master_id = IcfMasterId.next_unused.first
			if next_icf_master_id

#	why update_column? and not update_attribute?
#	update_column is strictly database update
#	update_attribute will skip validations, but trigger callback

#				self.update_column(:icf_master_id, next_icf_master_id.to_s)
				self.update_attribute(:icf_master_id, next_icf_master_id.to_s)

				next_icf_master_id.study_subject = self
				next_icf_master_id.assigned_on   = Date.current
				next_icf_master_id.save!
			end
		end
		self
	end

	def icf_master_id_to_s
		( icf_master_id.blank? ) ?  "[no ID assigned]" : icf_master_id
	end

	def copy_case_icf_master_id

		StudySubject.with_matchingid(self.matchingid).update_all(
			:case_icf_master_id => self.try(:case_subject).try(:icf_master_id))

#		self.case_icf_master_id = case_subject.try(:icf_master_id)
#StudySubject.with_matchingid(matchingid)

#		if case_icf_master_id.blank?
#			self.case_icf_master_id = case_subject.try(:icf_master_id)
#		end
	end

	def copy_mother_icf_master_id
#StudySubject.with_familyid(familyid).update_all(:
#		self.mother_icf_master_id = mother.try(:icf_master_id)
#		if is_mother? 	#	tell family your icf_master_id if you have one
#			if !icf_master_id.blank?
#				#	StudySubject.with_familyid(familyid).update_all(:mother_icf_master_id => icf_master_id)
#			else
#
#			end
#		else	#	case or control child
#			if mother_icf_master_id.blank?
#				#	get mom's icf_master_id
#
#			end
#		end
		StudySubject.with_familyid(self.familyid).update_all(
			:mother_icf_master_id => self.try(:mother).try(:icf_master_id))
	end

end	#	class_eval
end	#	included
end	#	StudySubjectIcfMasterId

__END__

In theory,

	the case subject is created first
	it is then assigned an icf_master_id

	the case mother is then created
	and it is assigned an icf_master_id


	eventually controls are created
	and also assigned icf_master_ids

	then control mothers
	and their icf_master_ids




	This brute force should work.  Any time that any subject is saved,
	the associated mother's and case subject's icf_master_ids are
	distributed.

	This would avoid an array of senseless conditions.

	If the mother exists and has an icf master id, all family are set
	If the case exists and has an icf master id, all matching are set
	If s.is_mother, s.mother == self
	If s.is_case, s.case_subject == self

		StudySubject.with_familyid(s.familyid).update_all(
			:mother_icf_master_id => s.try(:mother).try(:icf_master_id))

		StudySubject.with_matchingid(s.matchingid).update_all(
			:case_icf_master_id => s.try(:case_subject).try(:icf_master_id))






