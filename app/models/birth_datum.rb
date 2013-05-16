class BirthDatum < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true
	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control
	before_create :cleanup_data
	after_create :post_processing

	alias_attribute :mother_years_educ, :mother_yrs_educ
	alias_attribute :father_years_educ, :father_yrs_educ

	after_initialize :set_defaults, :if => :new_record?
	def set_defaults
		# ||= doesn't work with ''
		#	just setting this to a string so that << works
		self.ccls_import_notes ||= ''
	end

	def is_case?
		['1','case'].include?(case_control_flag)
	end

	def is_control?
		['0','control'].include?(case_control_flag)
	end

	def cleanup_data
		#
		#	many times the dob is blank.  Assuming that it is then the same as case dob????
		#
		#	copy case dob to dob if it is blank
		#
		self.dob = case_dob if self.dob.blank?
	end

	def post_processing
#		if master_id.blank? and childid.blank? and 
#				subjectid.blank? and state_registrar_no.blank?
#	state_registrar_no exists in birth data but not in our db?
		if master_id.blank? and childid.blank? and subjectid.blank?
			ccls_import_notes << 'birth data append:master_id, childid and subjectid blank;\n'
		else
			#	DO NOT USE 'study_subject' here as it will conflict with
			#	the study_subject association.
			subject = find_subject

			if subject.nil?
				ccls_import_notes << "birth data append:No subject found with master_id :#{master_id}:;\n"
			elsif !subject.is_case?
				ccls_import_notes << "birth data append:Subject found with master_id :#{master_id}:" <<
						" is not a case subject.;\n"
			else
				if is_control?
					control_options = { :related_patid => subject.patid }
					reasons = []
					control_options[:reject_candidate] = true if dob.blank? or sex.blank?
					reasons << "Birth datum dob is blank." if dob.blank?
					reasons << "Birth datum sex is blank." if sex.blank?
					control_options[:rejection_reason] = reasons.join("\n") unless reasons.empty?
					self.create_candidate_control( control_options )
					ccls_import_notes << "birth data append:Candidate control was pre-rejected " <<
							"because #{reasons.join(',')}.;\n" unless reasons.empty?
					if self.candidate_control.new_record?
						ccls_import_notes << "candidate control creation:" <<
							"Error creating candidate_control for subject;\n"
					else

#irb(main):004:0> BirthDatum.group(:deceased).count
#   (30.0ms)  SELECT COUNT(*) AS count_all, deceased AS deceased FROM `birth_data` GROUP BY deceased
#=> {nil=>547, " "=>1763, "DEFINITE"=>3, "POSSIBLE"=>1}
#irb(main):005:0> quit

#	Don't if deceased

						if match_confidence.present? && match_confidence.match(/definite/i) && 
								!deceased.to_s.match(/definite/i)
#								( deceased.blank? || ( deceased.present? && !deceased.match(/definite/i) ) )
							#	see candidate_controls_controller#update
							case_study_subject = StudySubject.cases.with_patid(
								self.candidate_control.related_patid).first
							#	why do I need to pass this info? can't it find it?
							self.candidate_control.create_study_subjects( case_study_subject )
							#	hoping to get the study subject that was assigned
							self.reload
						end


					end
				elsif is_case?
					if match_confidence.present? && match_confidence.match(/definite/i)
						#	assign study_subject_id to case's id
						self.update_study_subject_attributes
						self.update_bc_request
						self.create_address_from_attributes
					else
						ccls_import_notes << "birth data append:"<<
							"Match confidence not 'definite':#{match_confidence}:;\n"
					end	#	if match_confidence.match(/definite/i)
				else
					ccls_import_notes << "birth data append:"<<
							"Unknown case_control_flag :#{case_control_flag}:;\n"
				end
			end
		end
		save if ccls_import_notes.present?
	end

	def create_control_study_subject_and_mother
	end

	def find_subject
		if master_id.present?
			StudySubject.with_icf_master_id( master_id ).first
		elsif childid.present?
			StudySubject.with_childid( childid ).first
		elsif subjectid.present?
			StudySubject.with_subjectid( subjectid ).first
#		elsif state_registrar_no.present?
#			StudySubject.with_state_registrar_no( state_registrar_no ).first
		else
			nil
		end
	end

	def assign_subject
		if study_subject
			study_subject
		else
			subject = find_subject
			return if subject.nil?

#	this doesn't update counter cache
#			self.update_column(:study_subject_id, subject.id)
#	trying ...
			self.study_subject = subject
			self.save
			
			subject
		end
	end

	def update_bc_request
		return unless study_subject
		#	Should only be one bc_request, nevertheless, ...
		study_subject.bc_requests.incomplete.each do |bcr|
			bcr.status = 'complete'
			bcr.is_found = true
			bcr.returned_on = Date.current
			#	possibly having existing notes means we can't use update_all (bummer)
			bcr.notes = '' if bcr.notes.blank?
			bcr.notes << "USC's match confidence = #{match_confidence}."
			bcr.save!
		end
	end

	#
	#	Separated this out so that can do separately if needed.
	#
	#	Doing this very similar to the bc info updating
	#	
	def update_study_subject_attributes
		assign_subject unless study_subject
		return if study_subject.nil?
		#
		#	ONLY DO THIS FOR CASE SUBJECTS!
		#
		return unless is_case?

		study_subject.operational_events.create(
			:occurred_at               => DateTime.current,
			:project_id                => Project['ccls'].id,
			:operational_event_type_id => OperationalEventType['birthDataReceived'].id )

		#	using "a" as a synonym for "new_attributes" since is a Hash (pointer)
		a = new_attributes = HWIA.new

		%w( father_first_name father_middle_name father_last_name 
				mother_first_name mother_middle_name mother_maiden_name
				first_name middle_name last_name ).each do |field|
			a[field] = self.send(field).to_s.squish.namerize
		end

		a[:sex] = self.sex.to_s.squish.upcase
		a[:dob] = self.dob
		a[:state_registrar_no] = self.state_registrar_no.to_s.squish.namerize	#	may not want to do this

		new_attributes.each do |k,v|
			#	NOTE always check if attribute is blank as don't want to delete data
			study_subject.send("#{k}=",v) if v.present?
		end

		#	gotta save the changes before the subject, otherwise ... poof
		#	probably not necessary to save them to the bc_info though
		changes = study_subject.changes

#puts changes.inspect

#
#	TODO gonna have to remember this but will need to pull it out in rake task DONE
#
#		study_subjects.push(study_subject)
#

		if study_subject.changed?

			#	kinda crued, but just want to remember that this was changed in email
			#study_subject.instance_variable_set("@bc_info_changed",true) 

			if study_subject.save

				study_subject.operational_events.create(
					:occurred_at => DateTime.current,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth Record data changes from #{birth_data_file_name}",
					:notes => "Changes:  #{changes}")

			else

				study_subject.operational_events.create(
					:occurred_at => DateTime.current,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
					:description => "Birth Record data changes from #{birth_data_file_name}",
					:notes => "StudySubject save failed." << study_subject.errors.full_messages.to_sentence)

				ccls_import_notes << "birth data update:Error updating case study subject. " <<
					"Save failed! #{study_subject.errors.full_messages.to_sentence};\n"
			end	#	if study_subject.save

		end	#	if study_subject.changed?

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
			:data_source_id => DataSource["birthdata"].id,
			:notes => "Address is mother's residential address found in the CA State Birth Record.")

		unless addressing.save
			#	Address possibly contained PO Box which is invalid as a residence.
			#	Try to create as mailing address...
			addressing.address.address_type = AddressType["mailing"]
			study_subject.operational_events.create(
				:occurred_at => DateTime.current,
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['bc_received'].id,
				:description => "Insufficient maternal residence information in birth data to "<<
					"create address record. See subject's Birth Record page for details.\n"<<
					"#{addressing.errors.full_messages.to_sentence}" ) unless addressing.save
		end
		addressing
	end

	after_save :reindex_study_subject!, :if => :changed?

protected

	def reindex_study_subject!
		logger.debug "Birth Datum changed so reindexing study subject"
		study_subject.index if study_subject
	end

end

__END__
