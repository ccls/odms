class BirthDatum < ActiveRecord::Base

	belongs_to :birth_datum_update
	attr_protected :birth_datum_update_id, :birth_datum_update
	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control

	has_many :odms_exceptions, :as => :exceptable

	after_create :post_processing

	def post_processing
		if masterid.blank?
			odms_exceptions.create(:name => 'birth data append',
				:description => "masterid blank")
		else
#	DO NOT USE 'study_subject' here as it will conflict with
#	the study_subject association.
			subject = StudySubject.where(:icf_master_id => masterid).first
			if subject.nil?
				odms_exceptions.create(:name => 'birth data append',
					:description => "No subject found with masterid :#{masterid}:")
			elsif !subject.is_case?
				odms_exceptions.create(:name => 'birth data append',
					:description => "Subject found with masterid :#{masterid}: is not a case subject.")
			else
				if case_control_flag == 'control'
					control_options = { :related_patid => subject.patid }
					reasons = []
					if dob.blank?
						control_options[:reject_candidate] = true
						reasons << "Birth datum dob is blank."
					end
					if sex.blank?
						control_options[:reject_candidate] = true
						reasons << "Birth datum sex is blank."
					end
					control_options[:rejection_reason] = reasons.join("\n") unless reasons.empty?

					self.create_candidate_control( control_options )
					odms_exceptions.create(:name => 'birth data append',
						:description => "Candidate control was pre-rejected because #{reasons.join(',')}.") unless reasons.empty?

					if self.candidate_control.new_record?
						odms_exceptions.create(:name => 'candidate control creation',
							:description => "Error creating candidate_control for subject")
					end
				elsif case_control_flag == 'case'
					if match_confidence.match(/definite/i)
						#	assign study_subject_id to case's id
						self.update_attribute(:study_subject_id, subject.id)
						update_study_subject_attributes
					else
						odms_exceptions.create(:name => 'birth data append',
							:description => "Match confidence not 'definite':#{match_confidence}:")
					end	#	if match_confidence.match(/definite/i)
				else #	elsif case_control_flag == 'case'
					odms_exceptions.create(:name => 'birth data append',
						:description => "Unknown case_control_flag :#{case_control_flag}:")
				end
			end
		end
	end

	def update_study_subject_attributes
		error_count = 0

#	loop through fields and update each
#
#The fields to be evaluated and updated, as necessary for case records are:
#
#a.Columns in ODMS missing values are modified using the data from USC.
#b.Values in ODMS that conflict with USC data are replaced by the USC data provided and an operational_event is created as described below.
#c.Errors updating case records in ODMS are noted in the odms_exceptions table (see below).
#
#	TODO	TODO	TODO	TODO	TODO	TODO	TODO	TODO	TODO	TODO
#
#	Confirm, create exception if no match
#		dob sex first_name last_name
#	Add if missing.  Otherwise, confirm and create exception if no match.
#		middle_name father_first_name father_first_name father_middle_name father_last_name 
#		mother_first_name mother_middle_name mother_maiden_name
#

#	if error or conflict, increment error_count
#		error_count += 1
#5.Add a new operational event for each occurrence described in aboven
#a.id 28 (birthDataConflict) 
#b.description: “Birth record data conflicted with existing ODMS data.  Field: [fieldname], ODMS Value: [original value],  Birth Record Value: [birth data value].  ODMS record modified with birth record data.”
#	study_subject.operational_events.create(:project_id => Project['ccls'].id,
#		:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
#		:description => "Birth record data conflicted with existing ODMS data.  Field: [fieldname], ODMS Value: [original value],  Birth Record Value: [birth data value].  ODMS record modified with birth record data.")


		if error_count > 0
#	odms_exceptions.create(:name => 'birth data update',
#		:description => "Error updating case study subject. #{error_count} errors or conflicts.")
		else
#4.A new operational event (id 27: birthDataReceived) is added for each subject successfully updated. (  Only those successful??  )
#	study_subject.operational_events.create(:project_id => Project['ccls'].id,
#		:operational_event_type_id => OperationalEventType['birthDataReceived'].id )
		end	#	if error_count > 0
	end

	#	Returns string containing candidates's first, middle and last name
	def full_name
		[first_name, middle_name, last_name].delete_if(&:blank?).join(' ')
	end

	#	Returns string containing candidates's mother's first, middle and maiden name
	def mother_full_name
		[mother_first_name, mother_middle_name, mother_maiden_name
			].delete_if(&:blank?).join(' ')
	end

end
