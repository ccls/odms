class BirthDatum < ActiveRecord::Base

	belongs_to :birth_datum_update
	attr_protected :birth_datum_update_id, :birth_datum_update
	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control

	has_many :odms_exceptions, :as => :exceptable

	after_create :post_processing

	def post_processing
		if master_id.blank?
			odms_exceptions.create(:name => 'birth data append',
				:description => "master_id blank")
		else
			#	DO NOT USE 'study_subject' here as it will conflict with
			#	the study_subject association.
			subject = StudySubject.where(:icf_master_id => master_id).first
			if subject.nil?
				odms_exceptions.create(:name => 'birth data append',
					:description => "No subject found with master_id :#{master_id}:")
			elsif !subject.is_case?
				odms_exceptions.create(:name => 'birth data append',
					:description => "Subject found with master_id :#{master_id}:" <<
						" is not a case subject.")
			else


#				if case_control_flag == 'control'
#				if case_control_flag == '0'
				if ['0','control'].include?(case_control_flag)


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
						:description => "Candidate control was pre-rejected " <<
							"because #{reasons.join(',')}.") unless reasons.empty?

					if self.candidate_control.new_record?
						odms_exceptions.create(:name => 'candidate control creation',
							:description => "Error creating candidate_control for subject")
					end


#				elsif case_control_flag == 'case'
#				elsif case_control_flag == '1'
				elsif ['1','case'].include?(case_control_flag)



#					if match_confidence.match(/definite/i)
					if !match_confidence.blank? && match_confidence.match(/definite/i)



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

	#
	#	Separated this out so that can do separately.
	#
	def update_study_subject_attributes
		#	If subject is created after this record (this would be odd)
		#	then study subject isn't set.  Regardless, check if its
		#	set.  If not, try to set it.  If can't, go away.
		unless study_subject
			return if master_id.blank?
			subject = StudySubject.where(:icf_master_id => master_id).first
			return if subject.nil?
			self.update_attribute(:study_subject_id, subject.id)
		end

		error_count = 0

		#	Confirm, create exception if no match
		%w( dob sex first_name last_name ).each do |field|

			if study_subject.send(field) != self.send(field)
				error_count += 1
				study_subject.operational_events.create(
					:occurred_at => DateTime.now,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth record data conflicted with existing ODMS data.  " <<
						"Field: #{field}, " <<
						"ODMS Value: #{study_subject.send(field)}, " <<
						"Birth Record Value: #{self.send(field)}.  " <<
						"ODMS record   NOT   modified with birth record data." )
			end

#	TODO DO I UPDATE OR NOT?
#	Documentation says no, but error message says yes?

		end

		#	Add if missing.  Otherwise, confirm and create exception if no match.
		%w( father_first_name father_middle_name father_last_name 
			mother_first_name mother_middle_name mother_maiden_name
			middle_name ).each do |field|

			if study_subject.send(field).blank? and !self.send(field).blank?
				study_subject.send("#{field}=",self.send(field) )


				study_subject.operational_events.create(
					:occurred_at => DateTime.now,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth record data conflicted with existing ODMS data.  " <<
						"Field: #{field}, " <<
						"ODMS Value was blank, " <<
						"Birth Record Value: #{self.send(field)}.  " <<
						"ODMS record modified with birth record data." )
#
#	This will change the counts on some tests.
#
#	Document this change?


			elsif study_subject.send(field) != self.send(field)
				error_count += 1
				study_subject.operational_events.create(
					:occurred_at => DateTime.now,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth record data conflicted with existing ODMS data.  " <<
						"Field: #{field}, " <<
						"ODMS Value: #{study_subject.send(field)}, " <<
						"Birth Record Value: #{self.send(field)}.  " <<
						"ODMS record   NOT  modified with birth record data." )

#	TODO DO I UPDATE OR NOT?
#	Again, documentation says no, but error message says yes?

			end

		end

		if study_subject.changed?
			saved = study_subject.save
			unless saved
				error_count += 1
				odms_exceptions.create(
					:name        => 'birth data update',
					:description => "Error updating case study subject. " <<
													"Save failed!" ) 
#
#	NOTE that this doesn't stop everything else from happening
#
			end
		end

		if error_count > 0
			odms_exceptions.create(
				:name        => 'birth data update',
				:description => "Error updating case study subject. " <<
												"#{error_count} errors or conflicts." )
		else
			#4.A new operational event (id 27: birthDataReceived) is added for 
			#each subject successfully updated. (  Only those successful??  )
			study_subject.operational_events.create(
				:occurred_at => DateTime.now,
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['birthDataReceived'].id )
		end	#	if error_count > 0
	end

	#	Returns string containing candidates's first, middle and last name
	def full_name
		[first_name, middle_name, last_name].delete_if(&:blank?).join(' ')
	end

	#	Returns string containing candidates's mother's first, middle and maiden name
	def mother_full_name
		[mother_first_name, mother_middle_name, mother_maiden_name].delete_if(&:blank?).join(' ')
	end

end
