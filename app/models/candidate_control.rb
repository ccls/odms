class CandidateControl < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :birth_datum
	attr_protected :birth_datum_id, :birth_datum

	has_many :odms_exceptions, :as => :exceptable

	validations_from_yaml_file

	scope :rejected,   where(:reject_candidate => true)

	scope :unrejected, 
		where(self.arel_table[:reject_candidate].eq_any([false,nil]))

	scope :unassigned, where(:assigned_on => nil, :study_subject_id => nil)

	delegate :sex, :full_name, :first_name, :middle_name, :last_name,
		:mother_full_name, :mother_first_name, :mother_middle_name, :mother_maiden_name, 
		:father_first_name, :father_middle_name, :father_last_name, 
		:dob, :birth_type, :match_confidence, :deceased,
		:mother_yrs_educ, :father_yrs_educ,
		:state_registrar_no, :local_registrar_no,
			:to => :birth_datum, :allow_nil => true

	def case_study_subject
		StudySubject.cases.with_patid(related_patid).first
	end

	def case_study_subject_birth_state_CA?
		case_study_subject.birth_state == 'CA'
	end

	#	class method (basically a scope with an argument)
	def self.with_related_patid(patid)
		where(:related_patid => sprintf("%04d",patid.to_i))
	end

	def create_study_subjects(case_subject,grouping = '6')

#	NOTE can't I find my own case_subject?
#	 case_study_subject = StudySubject.cases.with_patid(related_patid).first

		next_orderno = case_subject.next_control_orderno(grouping)

		options_for_odms_exceptions = []

		CandidateControl.transaction do

			#	Use a block so can assign all attributes without concern for attr_protected
			child = StudySubject.new do |s|
				s.subject_type       = 'Control'
				s.vital_status       = 'Living'
				s.sex                = sex.try(:upcase)
				s.mom_is_biomom      = mom_is_biomom
				s.dad_is_biodad      = dad_is_biodad
				s.birth_type         = birth_type
				s.mother_yrs_educ    = mother_yrs_educ
				s.father_yrs_educ    = father_yrs_educ
				s.first_name         = first_name.namerize
				s.middle_name        = middle_name.namerize
				s.last_name          = last_name.namerize
				s.dob                = dob
				s.father_first_name  = father_first_name.namerize
				s.father_middle_name = father_middle_name.namerize
				s.father_last_name   = father_last_name.namerize

				s.mother_first_name  = mother_first_name.namerize
				s.mother_middle_name = mother_middle_name.namerize
#				s.mother_last_name   = mother_last_name
				s.mother_maiden_name = mother_maiden_name.namerize

				s.case_control_type  = grouping
				s.state_registrar_no = state_registrar_no
				s.local_registrar_no = local_registrar_no
				s.orderno            = next_orderno
				s.matchingid         = case_subject.subjectid
				s.patid              = case_subject.patid

#	TODO - probably a better place for this (before creating mother)
				s.case_icf_master_id = case_subject.icf_master_id

				s.is_matched         = true
			end

			child.save
			if child.new_record?
				errors.add(:base, 
					"You should probably reject this candidate. Study Subject invalid. " <<
						child.errors.full_messages.to_sentence )

				options_for_odms_exceptions.push({
					:name => "new subject error",
					:description => child.errors.full_messages.to_sentence })
				raise ActiveRecord::Rollback
			end

			child.assign_icf_master_id

			case_subject.update_attributes!(:is_matched => true)


			#	NOTE this may require passing info
			#	that is in this record, but not in the child subject
			#		mother_hispanicity(actually this is now)
			#	worst case scenario is just create the full mother here
			#	rather than through the child.
			child.create_mother	#	({ .... })
	
			self.study_subject_id = child.id

			birth_datum.study_subject = child
			birth_datum.save!
			birth_datum.create_address_from_attributes

			self.assigned_on = Date.current
			self.save!


#	NOTE
#	This method and transaction may require more personnal handling,
#	condition checking, and yada yada.  For this reason, we MAY want to 
#	"unbang" the methods and manually raise ActiveRecord::Rollback
#	to trigger a rollback if necessary.
#
#	If adding an OdmsException, would have to do outside the transaction
#	as it would be rolled back if done inside.  So we'd need to set a
#	variable or something to reference.
#	


		end
		options_for_odms_exceptions.each do |options_for_odms_exception|
			oe = odms_exceptions.create(options_for_odms_exception)
		end
#
#	NOTE will just crash if something happened when run in rake task
#
		raise ActiveRecord::RecordNotSaved unless options_for_odms_exceptions.empty?
		self
	end

end
