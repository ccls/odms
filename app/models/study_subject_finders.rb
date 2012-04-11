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

	#	making separate to avoid open ended string line in controller
	#	which screws up code coverage counting. (20120411)
	scope :join_patients,
		joins('LEFT JOIN patients ON study_subjects.id = patients.study_subject_id')

	scope :cases,    joins(:subject_type).where('subject_types.key = ?', 'Case')
	scope :controls, joins(:subject_type).where('subject_types.key = ?', 'Control')
	scope :mothers,  joins(:subject_type).where('subject_types.key = ?', 'Mother')
	scope :children, joins(:subject_type).where('subject_types.key IN (?)', 
		['Case','Control'])

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

	def self.not_id(study_subject_id)
		where("study_subjects.id != ?", study_subject_id)
	end

	#	Find the case or control subject with matching familyid except self.
	def child
		if is_mother? && !familyid.blank?
			StudySubject.children.with_subjectid(familyid).not_id(id 
				).includes(:subject_type).first
		else
			nil
		end
	end

	#	Find the subject with matching familyid and subject_type of Mother.
	def mother
		return nil if familyid.blank?
		StudySubject.mothers.with_familyid(familyid
			).includes(:subject_type).first
	end

	#	Find all the subjects with matching familyid except self.
	def family
		return [] if familyid.blank?
		StudySubject.with_familyid(familyid).not_id(id).includes(:subject_type)
	end

	#	Find all the subjects with matching matchingid except self.
	def matching
		return [] if matchingid.blank?
		StudySubject.with_matchingid(matchingid).not_id(id).includes(:subject_type)
	end

	#	Find all the subjects with matching patid with subject_type Control except self.
	#	If patid is nil, this sql doesn't work.  
	#			TODO Could fix, but this situation is unlikely.
	def controls
		return [] unless is_case?
		StudySubject.controls.with_patid(patid).not_id(id).includes(:subject_type)
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
