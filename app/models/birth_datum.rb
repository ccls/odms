class BirthDatum < ActiveRecord::Base

#	gotta use after_* so that have own id to pass

#	still need to know which field is the unique one.

	belongs_to :birth_datum_update
	attr_protected :birth_datum_update_id, :birth_datum_update
	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control

	after_create :post_processing

	def post_processing
		if masterid.blank?
			#		error
		else
			subject = StudySubject.where(:icf_master_id => masterid).first
			if subject.nil?
#	subject not found?
#		error
			elsif !subject.is_case?
#	subject not case?
#		error
			else
				if case_control_flag == 'control'
					self.create_candidate_control( :related_patid => subject.patid )
				elsif case_control_flag == 'case'
					#	assign study_subject_id to case's id
					self.update_attribute(:study_subject_id, subject.id)
#					study_subject = subject
#					save
					#	update case study_subject data
	

				else
#	unknown case_control_flag
#	error

				end
			end
		end
	end

	#	Returns string containing candidates's first, middle and last name
	def full_name
		[first_name, middle_name, last_name].delete_if(&:blank?).join(' ')
	end

	#	Returns string containing candidates's mother's first, middle and maiden name
	def mother_full_name
		[mother_first_name, mother_middle_name, mother_maiden_name].delete_if(&:blank?).join(' ')
	end



#	#	Fortunately, in rails 3, after_create seems to be called before after_save
#	#	I don't think that this was true in rails 2.
#	after_create :create_new_datum_record_change
##	after_save or after_update?
##	after_save   :create_datum_record_changes
#	after_update :create_datum_record_changes
#
##	would be any birth data changes as all will be appended
#
#	def create_new_datum_record_change
##		BirthDatumChange.create!({
##			:birth_datum_id        => self.id,
##			:birth_datum_update_id => self.birth_datum_update_id,
##			:new_datum_record      => true
##		})
#	end
#
#	def create_datum_record_changes
##		unignorable_changes.each do |field,values|
##			BirthDatumChange.create!({
##				:birth_datum_id        => self.id,
##				:birth_datum_update_id => self.birth_datum_update_id,
##				:new_datum_record      => false,
##				:modified_column      => field,
##				:previous_value       => values[0],
##				:new_value            => values[1]
##			})
##		end
#	end

end
