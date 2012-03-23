#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectFinders
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	scope :cases,    where('subject_type_id = ?', SubjectType['Case'].id)
	scope :controls, where('subject_type_id = ?', SubjectType['Control'].id)
	scope :mothers,  where('subject_type_id = ?', SubjectType['Mother'].id)
	scope :children, where('subject_type_id IN (?)', 
		[SubjectType['case'].id,SubjectType['Control'].id])

	def self.with_patid(patid)
		where(:patid => patid)
	end

	def self.with_familyid(familyid)
		where(:familyid => familyid)
	end

	def self.with_matchingid(matchingid)
		where(:matchingid => matchingid)
	end

	def self.with_subjectid(subjectid)
		where(:subjectid => subjectid)
	end

#	HMM?
	#	def not_id(study_subject_id)
	#		where("study_subjects.id != ?", study_subject_id)
	#	end

	#	Find the case or control subject with matching familyid except self.
	def child
		if (subject_type_id == self.class.subject_type_mother_id) && !familyid.blank?
#			self.class.find(:first,
#				:include => [:subject_type],
#				:conditions => [
#					"study_subjects.id != ? AND subjectid = ? AND subject_type_id IN (?)", 
#						id, familyid, 
#						[self.class.subject_type_case_id,self.class.subject_type_control_id] ]
#			)
#			self.class.where("study_subjects.id != ? AND subjectid = ? AND subject_type_id IN (?)", 
#				id, familyid, 
#				[self.class.subject_type_case_id,self.class.subject_type_control_id]
#			self.class.children.where("study_subjects.id != ? AND subjectid = ?",
			self.class.children.with_subjectid(familyid).where("study_subjects.id != ?",
				id ).includes(:subject_type).first
		else
			nil
		end
	end

	#	Find the subject with matching familyid and subject_type of Mother.
	def mother
		return nil if familyid.blank?
#		self.class.find(:first,
#			:include => [:subject_type],
#			:conditions => { 
#				:familyid        => familyid,
#				:subject_type_id => self.class.subject_type_mother_id
#			}
#		)
#		self.class.where(:familyid => familyid
#			).where(:subject_type_id => self.class.subject_type_mother_id
#			).includes(:subject_type).first
		self.class.mothers.with_familyid(familyid
			).includes(:subject_type).first
	end

	#	Find all the subjects with matching familyid except self.
	def family
		return [] if familyid.blank?
#		self.class.find(:all,
#			:include => [:subject_type],
#			:conditions => [
#				"study_subjects.id != ? AND familyid = ?", id, familyid ]
		self.class.with_familyid(familyid).where("study_subjects.id != ?", id
			).includes(:subject_type)
	end

	#	Find all the subjects with matching matchingid except self.
	def matching
		return [] if matchingid.blank?
#		self.class.find(:all,
#			:include => [:subject_type],
#			:conditions => [
#				"study_subjects.id != ? AND matchingid = ?", 
#					id, matchingid ]
#		)
		self.class.with_matchingid(matchingid).where("study_subjects.id != ?", id
			).includes(:subject_type)
	end

	#	Find all the subjects with matching patid with subject_type Control except self.
	#	If patid is nil, this sql doesn't work.  
	#			TODO Could fix, but this situation is unlikely.
	def controls
		return [] unless is_case?
#		self.class.find(:all, 
#			:include => [:subject_type],
#			:conditions => [
#				"study_subjects.id != ? AND patid = ? AND subject_type_id = ?", 
#					id, patid, self.class.subject_type_control_id ] 
#		)
#		self.class.where("study_subjects.id != ? AND patid = ? AND subject_type_id = ?", 
#					id, patid, self.class.subject_type_control_id
#			).includes(:subject_type)
#		self.class.controls.where("study_subjects.id != ? AND patid = ?",
		self.class.controls.with_patid(patid).where("study_subjects.id != ?", id
			).includes(:subject_type)
	end

	def rejected_controls
		return [] unless is_case?
#		CandidateControl.find(:all,
#			:conditions => {
#				:related_patid    => patid,
#				:reject_candidate => true
#			}
#		)
		CandidateControl.where(
			:related_patid    => patid,
			:reject_candidate => true
		)
	end

	def self.find_case_by_patid(patid)
#		self.find(:first,	#	patid is unique so better only be 1
#			:conditions => [
#				'subject_type_id = ? AND patid = ?',
#				subject_type_case_id, patid
#			]
#		)
#		where('subject_type_id = ? AND patid = ?',
#				subject_type_case_id, patid).first
#		cases.where('patid = ?',patid).first
		cases.with_patid(patid).first
	end

	def self.find_all_by_studyid_or_icf_master_id(studyid,icf_master_id)
#	if decide to use LIKE, will need to NOT include nils so
#	will need to add some conditions to the conditions.
#		self.find( :all, 
#			:conditions => [
#				"studyid = :studyid OR icf_master_id = :icf_master_id",
#				{ :studyid => studyid, :icf_master_id => icf_master_id }
#			]
#		)
		where("studyid = :studyid OR icf_master_id = :icf_master_id",
				{ :studyid => studyid, :icf_master_id => icf_master_id })
	end

end	#	class_eval
end	#	included
end	#	StudySubjectFinders
