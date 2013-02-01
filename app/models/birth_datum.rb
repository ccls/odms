class BirthDatum < ActiveRecord::Base

	belongs_to :birth_datum_update
	attr_protected :birth_datum_update_id, :birth_datum_update
	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control

	has_many :odms_exceptions, :as => :exceptable

	after_create :post_processing


	alias_attribute :case_dob, :dob


	def is_case?
		['1','case'].include?(case_control_flag)
	end

	def is_control?
		['0','control'].include?(case_control_flag)
	end

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
				if is_control?
					control_options = { :related_patid => subject.patid }
					reasons = []
					control_options[:reject_candidate] = true if dob.blank? or sex.blank?
					reasons << "Birth datum dob is blank." if dob.blank?
					reasons << "Birth datum sex is blank." if sex.blank?
					control_options[:rejection_reason] = reasons.join("\n") unless reasons.empty?
					self.create_candidate_control( control_options )
					odms_exceptions.create(:name => 'birth data append',
						:description => "Candidate control was pre-rejected " <<
							"because #{reasons.join(',')}.") unless reasons.empty?

					if self.candidate_control.new_record?
						odms_exceptions.create(:name => 'candidate control creation',
							:description => "Error creating candidate_control for subject")
					end
				elsif is_case?
					if !match_confidence.blank? && match_confidence.match(/definite/i)
						#	assign study_subject_id to case's id
						self.update_column(:study_subject_id, subject.id)
						self.update_study_subject_attributes
						self.update_bc_request
						self.create_address_from_attributes
					else
						odms_exceptions.create(:name => 'birth data append',
							:description => "Match confidence not 'definite':#{match_confidence}:")
					end	#	if match_confidence.match(/definite/i)
				else
					odms_exceptions.create(:name => 'birth data append',
						:description => "Unknown case_control_flag :#{case_control_flag}:")
				end
			end
		end
	end

	def update_bc_request
		return unless study_subject
		#	Should only be one bc_request, nevertheless, ...
		study_subject.bc_requests.incomplete.each do |bcr|
			bcr.status = 'complete'
			bcr.is_found = true
			bcr.returned_on = Date.today
			#	possibly having existing notes means we can't use update_all (bummer)
			bcr.notes = '' if bcr.notes.blank?
			bcr.notes << "USC's match confidence = #{match_confidence}."
			bcr.save!
		end
	end

	#
	#	Separated this out so that can do separately if needed.
	#
	def update_study_subject_attributes
		return if master_id.blank?
		#
		#	ONLY DO THIS FOR CASE SUBJECTS!
		#
		return unless is_case?

		#	If subject is created after this record (this would be odd)
		#	then study subject isn't set.  Regardless, check if its
		#	set.  If not, try to set it.  If can't, go away.
		unless study_subject
			subject = StudySubject.where(:icf_master_id => master_id).first
			return if subject.nil?
			self.update_column(:study_subject_id, subject.id)
		end

		error_count = 0

		#	comparing dob might require special handling

		#	Confirm, create exception if no match
		%w( dob ).each do |field|

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

		#	Confirm, create exception if no match
		%w( sex first_name last_name ).each do |field|

			current = study_subject.send(field).to_s
			updated = self.send(field).try(:squish).namerize.to_s
			unless current.match(/#{updated}/i)
				error_count += 1
				study_subject.operational_events.create(
					:occurred_at => DateTime.now,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth record data conflicted with existing ODMS data.  " <<
						"Field: #{field}, " <<
						"ODMS Value: #{current}, " <<
						"Birth Record Value: #{updated}.  " <<
						"ODMS record   NOT   modified with birth record data." )
			end

#	TODO DO I UPDATE OR NOT?
#	Documentation says no, but error message says yes?

		end

		#	Add if missing.  Otherwise, confirm and create exception if no match.
		%w( father_first_name father_middle_name father_last_name 
			mother_first_name mother_middle_name mother_maiden_name
			middle_name ).each do |field|

			current = study_subject.send(field).to_s
			updated = self.send(field).try(:squish).namerize.to_s
			if current.blank? and updated.blank?
				#
				#	nice to pre-filter the last elsif
				#
			elsif current.blank? and !updated.blank?
#				study_subject.send("#{field}=", updated)
				if study_subject.update_attributes(field => updated)
					study_subject.operational_events.create(
						:occurred_at => DateTime.now,
						:project_id => Project['ccls'].id,
						:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
						:description => "Birth record data conflicted with existing ODMS data.  " <<
							"Field: #{field}, " <<
							"ODMS Value was blank, " <<
							"Birth Record Value: #{updated}.  " <<
							"ODMS record modified with birth record data." )
				else
					#	these fields don't have much to validate so shouldn't fail
					error_count += 1
					odms_exceptions.create(
						:name        => 'screening data update',
						:description => "Error updating case study subject. " <<
													"Save failed! " <<
													study_subject.errors.full_messages.to_sentence) 
					study_subject.reload		#	if don't, won't ever save as bad attribute still there
	
#
#	TODO?
#
#				study_subject.operational_events.create(
#					update failed
	
				end


			elsif !current.match(/#{updated}/i)
				error_count += 1
				study_subject.operational_events.create(
					:occurred_at => DateTime.now,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth record data conflicted with existing ODMS data.  " <<
						"Field: #{field}, " <<
						"ODMS Value: #{current}, " <<
						"Birth Record Value: #{updated}.  " <<
						"ODMS record   NOT  modified with birth record data." )

#	TODO DO I UPDATE OR NOT?
#	Again, documentation says no, but error message says yes?

			end

		end



#
#	do individual updates so know exactly what failed (will be a bit slower)
#
#		if study_subject.changed?
#			saved = study_subject.save
#			unless saved
#				error_count += 1
#				odms_exceptions.create(
#					:name        => 'birth data update',
#					:description => "Error updating case study subject. " <<
#													"Save failed!" ) 
##
##	NOTE that this doesn't stop everything else from happening
##
#			end
#		end

		if error_count > 0
			odms_exceptions.create(
				:name        => 'birth data update',
				:description => "Error updating case study subject. " <<
												"#{error_count} errors or conflicts." )


#	TODO if we are sticking with this model, it would be nice to know
#				what those error or conflicts are.
#			:notes => errors_or_conflicts.join('\n')
#	Or create an exception for each?


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

	def create_address_from_attributes
		return unless study_subject
		addressing = study_subject.addressings.new(
			:address_attributes => {
				:line_1          => mother_residence_line_1.namerize,
				:city            => mother_residence_city.namerize,
				:county          => mother_residence_county.decode_county,
				:country         => 'United States',
				:state           => mother_residence_state.decode_state_abbrev,
				:zip             => mother_residence_zip,
				:address_type_id => AddressType["residence"].id,
				:data_source_id  => DataSource["birthdata"].id
			},
			:is_valid    => YNDK[:yes],
			:is_verified => true,
			:how_verified => "CA State Birth Record.",
			:data_source_id => DataSource["birthdata"].id,
			:notes => "Address is mother's residential address found in the CA State Birth Record.")

		unless addressing.save
			#	Address possibly contained PO Box which is invalid as a residence.
			#	Try to create as mailing address...
			addressing.address.address_type = AddressType["mailing"]
			study_subject.operational_events.create(
				:occurred_at => DateTime.now,
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['bc_received'].id,
				:description => "Insufficient maternal residence information in birth data to create address record. See subject's Birth Record page for details.\n#{addressing.errors.full_messages.to_sentence}" ) unless addressing.save
		end
		addressing
	end

	after_save :reindex_study_subject!

protected

	def reindex_study_subject!
		study_subject.index if study_subject
	end

end
