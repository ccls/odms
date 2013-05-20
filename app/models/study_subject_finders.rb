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
#	found as a "ReadOnlyRecord" so attempting to write to one will fail.  This can
#	be countered by adding a "readonly(false)" to the scope chain.  Or you
#	can simply re-find the given subject by id.

	#	making separate to avoid open ended string line in controller
	#	which screws up code coverage counting. (20120411)
#	scope :join_patients,
#		joins('LEFT JOIN patients ON study_subjects.id = patients.study_subject_id')
	scope :join_patients, joins(
		Arel::Nodes::OuterJoin.new(Patient.arel_table,Arel::Nodes::On.new(
			self.arel_table[:id].eq(Patient.arel_table[:study_subject_id]))))

	scope :cases,    where(:subject_type => 'Case')
	scope :controls, where(:subject_type => 'Control')
	scope :mothers,  where(:subject_type => 'Mother')
	scope :children, where(:subject_type => ['Case','Control'])

	scope :living,   where(:vital_status => 'Living')

	def self.with_patid(patid)
		where(:patid => sprintf("%04d",patid.to_i) )
	end

	def self.with_childid(childid)
		where(:childid => childid.to_i)
	end

	def self.with_state_registrar_no(state_registrar_no)
		where(:state_registrar_no => state_registrar_no.to_s.squish)
	end

	def self.with_icf_master_id(icf_master_id)
		where(:icf_master_id => icf_master_id.to_s.squish)
	end

	def self.with_studyid(studyid)
		where(:studyid => studyid.to_s.squish)
	end

	def self.with_familyid(familyid)
		where(:familyid => sprintf("%06d",familyid.to_i) )
	end

	def self.with_matchingid(matchingid)
		where(:matchingid => sprintf("%06d",matchingid.to_i) )
	end

	def self.with_subjectid(subjectid)
		where(:subjectid => sprintf("%06d",subjectid.to_i) )
	end

	def self.not_id(study_subject_id)
		where(self.arel_table[:id].not_eq(study_subject_id))
	end

	#	Find the case or control subject with matching familyid except self.
	def child
		if is_child?
			self
		else
			if !familyid.blank?
				StudySubject.children.with_subjectid(familyid).first
			else
				nil
			end
		end
	end

	#	Find the subject with matching matchingid and subject_type of Case.
	def case_subject
		return nil if matchingid.blank?
		StudySubject.cases.with_matchingid(matchingid).first
	end

	#	Find the subject with matching familyid and subject_type of Mother.
	def mother
		return nil if familyid.blank?
		StudySubject.mothers.with_familyid(familyid).first
	end

	#	Find all the subjects with matching familyid except self.
	def family
		if familyid.blank?
			StudySubject.where('1=0')	#	should NEVER be true
		else
			StudySubject.with_familyid(familyid).not_id(id)
		end
	end

	#	Find all the subjects with matching matchingid except self.
	def matching
		if matchingid.blank?
			StudySubject.where('1=0')	#	should NEVER be true
		else
			StudySubject.with_matchingid(matchingid).not_id(id)
		end
	end

	#	Find all the subjects with matching patid with subject_type Control except self.
	#	If patid is nil, this sql doesn't work.  
	#			TODO Could fix, but this situation is unlikely.
	def controls
		return [] unless is_case?
		StudySubject.controls.with_patid(patid).not_id(id)
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

	def self.find_case_by_icf_master_id(icf_master_id)
		cases.with_icf_master_id(icf_master_id).first
	end

end	#	class_eval
end	#	included
end	#	StudySubjectFinders
