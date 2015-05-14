class BirthDatum < ActiveRecord::Base

	belongs_to :study_subject		#, :counter_cache => true
#	attr_protected :study_subject_id, :study_subject
	has_one :candidate_control
	before_create :cleanup_data
	after_create :post_processing

	alias_attribute :mother_years_educ, :mother_yrs_educ
	alias_attribute :father_years_educ, :father_yrs_educ

#	This interferes with some tests, so don't leave it live.
	delegate :subjectid, :subject_type, :patid, :birth_year, :state_id_no, 
		:to => :study_subject, :allow_nil => true
#	delegate :subject_type, :patid, :birth_year, :state_id_no, 
#		:to => :study_subject, :allow_nil => true

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
		self.derived_state_file_no_last6 = sprintf("%06d",derived_state_file_no_last6.to_i) unless derived_state_file_no_last6.blank?
		self.derived_local_file_no_last6 = sprintf("%06d",derived_local_file_no_last6.to_i) unless derived_local_file_no_last6.blank?
	end

	def post_processing
		#	There are exactly 3 records with childids
		if master_id.blank? and childid.blank? and subjectid.blank?
			append_notes "master_id, childid and subjectid blank"
		else
			#	DO NOT USE 'study_subject' here as it will conflict with
			#	the study_subject association.
			case_subject = find_case_subject

			if case_subject.nil?
				append_notes "No subject found with master_id :#{master_id}:"
			elsif !case_subject.is_case?
				append_notes "Subject found with master_id :#{master_id}: is not a case subject."
			else	#	case_subject is case
				if is_control?
					create_candidate_control_for( case_subject )
				elsif is_case?

					if match_confidence.to_s.match(/definite/i)	||
						( match_confidence.to_s.match(/^NO$/i) and case_subject.birth_state != 'CA' )
#
# The 'NO' matches in the case files that were not born in California should still be imported with their controls into ODMS.  We can determine that they are valid b/c we have their birth state in the bc_info data that was imported from ICF.  So, basically if birth state is not equal to CA, they should be imported with controls and updated in the same way that a definite match would be.
#
						#	assign study_subject_id to case's id
						update_case_study_subject_attributes
						mark_all_incomplete_bc_requests_as_complete
						create_address_from_attributes
					else
						append_notes "Match confidence not 'definite':#{match_confidence}:"
					end	#	if match_confidence.match(/definite/i)

				else
					append_notes "Unknown case_control_flag :#{case_control_flag}:"
				end
			end
		end
	end

	#	import notes are added along the way from different places
	#	rather than saving at the end, just update the column each time
	def append_notes(notes)
		ccls_import_notes ||= ''
		ccls_import_notes << notes << ";\n"
		self.update_column(:ccls_import_notes, ccls_import_notes)
	end

	def create_candidate_control_for(case_subject)
		if self.candidate_control.nil?
			control_options = { :related_patid => case_subject.patid }
			reasons = []
			control_options[:reject_candidate] = true if dob.blank? or sex.blank?
			reasons << "Birth datum dob is blank." if dob.blank?
			reasons << "Birth datum sex is blank." if sex.blank?
			control_options[:rejection_reason] = reasons.join("\n") unless reasons.empty?
			self.create_candidate_control( control_options )
			append_notes "Candidate control was pre-rejected " <<
				"because #{reasons.join(',')}." unless reasons.empty?
		else	#	if self.candidate_control.nil?

		end	#	if self.candidate_control.nil?

		if self.candidate_control.new_record?
			append_notes "candidate control creation:" <<
				"Error creating candidate_control for subject"

		#
		#	TODO perhaps add errors.full_messages.to_sentence to ccls_import_notes?
		#
		#			append_notes self.candidate_control.errors.full_messages.to_sentence
		#

		else
			create_control_study_subject_and_mother( case_subject )
		end
	end

	#
	#	I'm still not a fan of the automatic creation.  
	#	It no longer does any of the duplicate checking.
	#	Of course, I still don't know how important that was.
	#
	def create_control_study_subject_and_mother( case_subject )
		#irb(main):004:0> BirthDatum.group(:deceased).count
		#   (30.0ms)  SELECT COUNT(*) AS count_all, deceased AS deceased 
		#		FROM `birth_data` GROUP BY deceased
		#=> {nil=>547, " "=>1763, "DEFINITE"=>3, "POSSIBLE"=>1}
		#irb(main):005:0> quit

		if study_subject.nil?

			if( match_confidence.to_s.match(/definite/i) and !deceased.to_s.match(/definite/i) ) ||
					( match_confidence.to_s.match(/^NO$/i) and case_subject.birth_state != 'CA' )
	
	#
	# The 'NO' matches in the case files that were not born in California should still be imported with their controls into ODMS.  We can determine that they are valid b/c we have their birth state in the bc_info data that was imported from ICF.  So, basically if birth state is not equal to CA, they should be imported with controls and updated in the same way that a definite match would be.
	#
	#	case_subject.birth_state
	#
	
				#	see candidate_controls_controller#update
	#			case_study_subject = StudySubject.cases.with_patid(
	#				self.candidate_control.related_patid).first
				#	why do I need to pass this info? can't it find it?
				self.candidate_control.create_study_subjects( case_subject )
	
			else



	


	#	TODO	append_notes "Study Subject not created because ....."


#	deceased?
#	not definite?
#	not definite and still CA?





	
			end

		else	#	if study_subject.nil?

		end	#	if study_subject.nil?
	end

	def find_case_subject
		if master_id.present?
			StudySubject.with_icf_master_id( master_id ).first
		elsif childid.present?
			StudySubject.with_childid( childid ).first
		elsif subjectid.present?
			StudySubject.with_subjectid( subjectid ).first
		else
			nil
		end
	end

	def assign_case_subject
		if study_subject
			study_subject
		else
			case_subject = find_case_subject
			return if case_subject.nil?
#			case_subject.birth_data << self
			case_subject.birth_datum = self
			case_subject
		end
	end

	def mark_all_incomplete_bc_requests_as_complete
		return unless study_subject
		#	Should only be one bc_request, nevertheless, ...
		study_subject.bc_requests.incomplete.each do |bcr|
			bcr.status = 'completed'
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
	def update_case_study_subject_attributes
		assign_case_subject unless study_subject
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

		#	may not want to do this	(why namerize a number?)
		a[:state_registrar_no] = self.state_registrar_no.to_s.squish	#.namerize	

		new_attributes.each do |k,v|
			#	NOTE always check if attribute is blank as don't want to delete data
			study_subject.send("#{k}=",v) if v.present?
		end

		if study_subject.changed?

			#	gotta save the changes before the subject, otherwise ... poof
			changes = study_subject.changes

			self.update_column(:study_subject_changes, changes.to_s)

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
					:notes => "StudySubject save failed." << 
						study_subject.errors.full_messages.to_sentence)

				append_notes "birth data update:Error updating case study subject. " <<
					"Save failed! #{study_subject.errors.full_messages.to_sentence}"
			end	#	if study_subject.save

		else

#				study_subject.operational_events.create(
#					:occurred_at => DateTime.current,
#					:project_id => Project['ccls'].id,
#					:operational_event_type_id => OperationalEventType['birthDataConflict'].id,
#					:description => "Birth Record data NO changes from #{birth_data_file_name}" )

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
		address = study_subject.addresses.new(
			:line_1       => mother_residence_line_1.namerize,
			:city         => mother_residence_city.namerize,
			:county       => mother_residence_county.decode_county,
			:country      => 'United States',
			:state        => mother_residence_state.decode_state_abbrev,
			:zip          => mother_residence_zip,
			:address_type => "Residence",
			:current_address => YNDK[:no],
			:address_at_diagnosis => YNDK[:no],
			:data_source => "Live Birth data from USC",
			:notes => "Address was mother's residential address at child's birth per CA State Birth Record.")

		unless address.save
			#	Address possibly contained PO Box which is invalid as a residence.
			#	Try to create as mailing address...
			address.address_type = "Mailing"
			study_subject.operational_events.create(
				:occurred_at => DateTime.current,
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['bc_received'].id,
				:description => "Insufficient maternal residence information in birth data to "<<
					"create address record. See subject's Birth Record page for details.\n"<<
					"#{address.errors.full_messages.to_sentence}" ) unless address.save
		end
		address
	end

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Birth Datum changed so reindexing study subject"
		#	this used to work without the new_record check (new_record? doesn't work? using persisted? )
		#	the persisted check only seems to matter when the before_destroy callback exists
		#	my "assert_should_belong_to" test method does a destroy 
		#	which is what makes this required. (was for testing attachments, but still viable)
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
	end

end

__END__
