class CandidateControl < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :birth_datum
	attr_protected :birth_datum_id, :birth_datum

	validates_inclusion_of :reject_candidate, :in => [true, false]
	validates_presence_of  :rejection_reason, :if => :reject_candidate
	validates_length_of    :related_patid, :is => 4, :allow_blank => true

	validates_length_of    :rejection_reason, 
			:maximum => 250, :allow_blank => true

	validates_inclusion_of :mom_is_biomom, :dad_is_biodad,
			:in => YNDK.valid_values,  :allow_blank => true

	scope :rejected,   where('reject_candidate = true')
	scope :unrejected, where('reject_candidate = false or reject_candidate IS NULL')
	scope :unassigned, where('assigned_on IS NULL AND study_subject_id IS NULL')

	delegate :sex, :full_name, :first_name, :middle_name, :last_name,
		:mother_full_name, :mother_first_name, :mother_middle_name, :mother_maiden_name, 
#		:mother_hispanicity_id, :father_hispanicity_id,
		:dob, :birth_type, 
#		:birth_county,
		:mother_yrs_educ, :father_yrs_educ,
#		:mother_race_id, :father_race_id,
		:state_registrar_no, :local_registrar_no,
			:to => :birth_datum, :allow_nil => true

	def self.related_patid(patid)
		where(:related_patid => patid)
	end

#	#	Returns string containing candidates's first, middle and last name
#	def full_name
#		[first_name, middle_name, last_name].delete_if(&:blank?).join(' ')
#	end
#
#	#	Returns string containing candidates's mother's first, middle and last name
#	def mother_full_name
#		[mother_first_name, mother_middle_name, mother_last_name].delete_if(&:blank?).join(' ')
#	end

	def create_study_subjects(case_subject,grouping = '6')
		next_orderno = case_subject.next_control_orderno(grouping)

		CandidateControl.transaction do

			#	Use a block so can assign all attributes without concern for attr_protected
			child = StudySubject.new do |s|
				s.subject_type_id       = SubjectType['Control'].id
				s.vital_status_id       = VitalStatus['living'].id
				s.sex                   = sex
				s.mom_is_biomom         = mom_is_biomom
				s.dad_is_biodad         = dad_is_biodad
#				s.mother_hispanicity_id = mother_hispanicity_id
#				s.father_hispanicity_id = father_hispanicity_id
				s.birth_type            = birth_type
				s.mother_yrs_educ       = mother_yrs_educ
				s.father_yrs_educ       = father_yrs_educ
#				s.birth_county          = birth_county
#				s.hispanicity_id        = ( 
#					( [mother_hispanicity_id,father_hispanicity_id].include?(1) ) ? 1 : nil )
				s.first_name         = first_name
				s.middle_name        = middle_name
				s.last_name          = last_name
				s.dob                = dob
				s.mother_first_name  = mother_first_name
				s.mother_middle_name = mother_middle_name
#				s.mother_last_name   = mother_last_name
				s.mother_maiden_name = mother_maiden_name
#				s.mother_race_id     = mother_race_id
#				s.father_race_id     = father_race_id

				s.case_control_type  = grouping
				s.state_registrar_no = state_registrar_no
				s.local_registrar_no = local_registrar_no
				s.orderno            = next_orderno
				s.matchingid         = case_subject.subjectid
				s.patid              = case_subject.patid
#
#	I suppose that I could also set the reference date, but
#	the current callbacks DO take care of that. (tested)
#				s.reference_date     = case_subject.reference_date
#				s.reference_date     = case_subject.patient.admit_date
#
				s.is_matched         = true
			end
			child.save!
			child.assign_icf_master_id


#	TODO May have to set is_matched for both the Case and Control here [#217]
#	We will default it to null and add logic to set it to true for both the new control and their related case when a new control is added to study_subjects from candidate_controls.
			case_subject.update_attributes!(:is_matched => true)


			#	NOTE this may require passing info
			#	that is in the candidate_control record, but not in the child subject
			#		mother_hispanicity_id	(actually this is now)
			#	worst case scenario is just create the full mother here
			#	rather than through the child.
			child.create_mother	#	({ .... })
	
			self.study_subject_id = child.id

			birth_datum.study_subject = child
			birth_datum.save!

			self.assigned_on = Date.today
			self.save!
		end
		self
	end

end
