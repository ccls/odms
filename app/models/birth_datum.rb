class BirthDatum < ActiveRecord::Base

#	gotta use after_* so that have own id to pass

#	still need to know which field is the unique one.

	belongs_to :birth_datum_update
	attr_protected :birth_datum_update_id, :birth_datum_update
	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control

	has_many :odms_exception_exceptables, :as => :exceptable
	has_many :odms_exceptions, :through => :odms_exception_exceptables

	after_create :post_processing

	def post_processing
		if masterid.blank?
#			OdmsException.create(:notes => "masterid blank for birth datum id:#{attributes['id']}:")
			odms_exceptions.create(:notes => "masterid blank")
		else
			subject = StudySubject.where(:icf_master_id => masterid).first
			if subject.nil?
#				OdmsException.create(:notes => "No subject found with masterid :#{masterid}: for birth datum id:#{attributes['id']}:")
				odms_exceptions.create(:notes => "No subject found with masterid :#{masterid}:")
			elsif !subject.is_case?
#				OdmsException.create(:notes => "Subject found with masterid :#{masterid}: for birth datum id:#{attributes['id']}: is not a case subject.")
				odms_exceptions.create(:notes => "Subject found with masterid :#{masterid}: is not a case subject.")
			else
				if case_control_flag == 'control'
					control_options = { :related_patid => subject.patid }
#
#	if dob or sex is blank, pre-reject control on creation
#	create an OdmsException too????
#
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
#					OdmsException.create(:notes => "Candidate control for birth datum id:#{attributes['id']}: was pre-rejected because #{reasons.join(',')}.") unless reasons.empty?
					odms_exceptions.create(:notes => "Candidate control was pre-rejected because #{reasons.join(',')}.") unless reasons.empty?
				elsif case_control_flag == 'case'


#a.for records with match_confidence = “definite”, processes case subjects and updates pertinent study_subjects fields as necessary,
					#	assign study_subject_id to case's id
					self.update_attribute(:study_subject_id, subject.id)
#					study_subject = subject
#					save
					#	update case study_subject data
#
#
#1.For each record in the USC birth data file identified as a “case,” find the corresponding ODMS subject using the master_id provided by USC (name to be determined -- it may be icf_master_id or master_id).  
#2.Write the study_subject_id of the case found in it’s correspondent birth_data record.
#3.Evaluate and modify the USC birth data identified in the table below resolving conflicts between the USC and ODMS data as follows:
#a.Columns in ODMS missing values are modified using the data from USC.
#b.Values in ODMS that conflict with USC data are replaced by the USC data provided and an operational_event is created as described below.
#c.Errors updating case records in ODMS are noted in the odms_exceptions table (see below).
#4.A new operational event (id 27: birthDataReceived) is added for each subject successfully updated.
#5.Add a new operational event for each occurrence described in aboven
#a.id 28 (birthDataConflict) 
#b.description: “Birth record data conflicted with existing ODMS data.  Field: [fieldname], ODMS Value: [original value],  Birth Record Value: [birth data value].  ODMS record modified with birth record data.”
#6.Add an odms_exception for each case record that cannot be successfully updated in ODMS as follows:
#a.name: “birth_data update” 
#b.description: exception-specific error message (to be defined at the judgment of the programmer) or a general error: “Error importing record into birth_data table.  Exception record master_id = xxxxxxxxx.”  Or “Error importing record into birth_data table.  Exception record master_id not provided.”
#c.occurred_on: timestamp
#
#The fields to be evaluated and updated, as necessary for case records are:
#
#
#	Confirm, create exception if no match
#		dob sex first_name last_name
#	Add if missing.  Otherwise, confirm and create exception if no match.
#		middle_name father_first_name father_first_name father_middle_name father_last_name 
#		mother_first_name mother_middle_name mother_maiden_name

				else
#					OdmsException.create(:notes => "Unknown case_control_flag for birth datum id:#{attributes['id']}:")
					odms_exceptions.create(:notes => "Unknown case_control_flag")
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
