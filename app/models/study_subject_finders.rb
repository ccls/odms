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

#	Be advised that using a join in a scope will, by default, render those
#	found as "ReadOnly" so attempting to write to one will fail.  This can
#	be countered by adding a "readonly(false)" to the scope chain.  Or you
#	can simply re-find the given subject by id.

	scope :cases,    joins(:subject_type).where('subject_types.key = ?', 'Case')
	scope :controls, joins(:subject_type).where('subject_types.key = ?', 'Control')
	scope :mothers,  joins(:subject_type).where('subject_types.key = ?', 'Mother')
	scope :children, joins(:subject_type).where('subject_types.key IN (?)', ['Case','Control'])

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
			self.class.children.with_subjectid(familyid).where("study_subjects.id != ?",
				id ).includes(:subject_type).first
		else
			nil
		end
	end

	#	Find the subject with matching familyid and subject_type of Mother.
	def mother
		return nil if familyid.blank?
		self.class.mothers.with_familyid(familyid
			).includes(:subject_type).first
	end

	#	Find all the subjects with matching familyid except self.
	def family
		return [] if familyid.blank?
		self.class.with_familyid(familyid).where("study_subjects.id != ?", id
			).includes(:subject_type)
	end

	#	Find all the subjects with matching matchingid except self.
	def matching
		return [] if matchingid.blank?
		self.class.with_matchingid(matchingid).where("study_subjects.id != ?", id
			).includes(:subject_type)
	end

	#	Find all the subjects with matching patid with subject_type Control except self.
	#	If patid is nil, this sql doesn't work.  
	#			TODO Could fix, but this situation is unlikely.
	def controls
		return [] unless is_case?
		self.class.controls.with_patid(patid).where("study_subjects.id != ?", id
			).includes(:subject_type)
	end

	def rejected_controls
		return [] unless is_case?
		CandidateControl.where(
			:related_patid    => patid,
			:reject_candidate => true
		)
	end

	def self.find_case_by_patid(patid)
		cases.with_patid(patid).first
	end

end	#	class_eval
end	#	included
end	#	StudySubjectFinders
