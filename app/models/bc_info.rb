require 'ostruct'
#
#	Non-ActiveRecord class created primarily for adding testability to rake task.
#
class BcInfo < OpenStruct

	def initialize(*args)
		super
		self.verbose ||= false
		self.icf_master_id ||= icf_master_id || masterid
	end

	def code_correct(*args)
		hash = args.shift
		args.each do |key|
			hash[key] = 888 if hash[key] == '0'
			hash[key] = 999 if hash[key] == '9'
		end	#	args.each do |key|
	end

	def process
#	would work with childid or subjectid, but rake task won't be expecting
#	these column names so will need to make adjustments there for this.
#	this modification was meant for the birth_data files!
		identifier = if !icf_master_id.blank? 
			:icf_master_id
#		elsif !childid.blank?
#			:childid
#		elsif !subjectid.blank?
#			:subjectid
		else
			nil
		end

		if identifier.blank?
			Notification.plain(
				"#{bc_info_file} contained line with blank icf_master_id",
					:subject => "ODMS: Blank ICF Master ID in #{bc_info_file}"
			).deliver
			return	#	next
		end

		subjects = StudySubject.where(identifier => send(identifier))

		#	Shouldn't be possible as icf_master_id is unique in the db
		#raise "Multiple case subjects? with icf_master_id:" <<
		#	"#{line['icf_master_id']}:" if subjects.length > 1
		unless subjects.length == 1
			Notification.plain(
				"#{bc_info_file} contained line with #{identifier} " <<
				"but no subject with #{identifier}:#{send(identifier)}:",
					:subject => "ODMS: No Subject with #{identifier} in #{bc_info_file}"
			).deliver
			return	#	next
		end

		self.study_subject = subjects.first

		#	using "a" as a synonym for "new_attributes" since is a Hash (pointer)
		a = new_attributes = {
			:mother_first_name  => ( new_mother_first_name || 
				new_mother_first ).to_s.squish.namerize,
			:mother_last_name   => ( new_mother_last_name ||
				new_mother_last ).to_s.squish.namerize,
			:mother_maiden_name => ( new_mother_maiden_name ||
				new_mother_maiden ).to_s.squish.namerize,
			:father_first_name  => ( new_father_first_name ||
				new_father_first ).to_s.squish.namerize,
			:father_last_name   => ( new_father_last_name ||
				new_father_last ).to_s.squish.namerize,
			:first_name  => ( new_first_name ||
				new_child_first ).to_s.squish.namerize,
			:middle_name => ( new_middle_name ||
				new_child_middle ).to_s.squish.namerize,
			:last_name   => ( new_last_name ||
				new_child_last ).to_s.squish.namerize,
			:birth_city    => birth_city.to_s.squish.namerize,
			:birth_state   => birth_state.to_s.squish,
			:birth_country => birth_country.to_s.squish,
			:birth_year => new_dob_year || dob_year ||
										new_child_doby || child_doby,
			:mother_hispanicity     => mother_hispanicity.to_s.squish,
			:mother_hispanicity_mex => mother_hispanicity_mex.to_s.squish,
			:father_hispanicity     => father_hispanicity.to_s.squish,
			:father_hispanicity_mex => father_hispanicity_mex.to_s.squish,
			:mom_is_biomom => mom_is_biomom || biomom,
			:father_race_code => ( father_race || father_race_code ).to_s.squish,
			:mother_race_code => ( mother_race || mother_race_code ).to_s.squish,
			:dad_is_biodad => dad_is_biodad || biodad,
			:other_mother_race => ( other_mother_race || 
				mother_race_other ).to_s.squish.namerize,
			:other_father_race => ( other_father_race || 
				father_race_other ).to_s.squish.namerize,
			:sex => new_sex || new_child_gender,
			:dob => new_dob || new_child_dobfull
		}.with_indifferent_access

		if( a[:dob].blank? && 
			!( new_child_doby.blank? || 
				new_child_dobm.blank? || 
				new_child_dobd.blank?) )
			a[:dob] = sprintf( "%4d-%02d-%02d", 
				new_child_doby,new_child_dobm,new_child_dobd ) 
		end

		code_correct(a,:father_hispanicity,:mother_hispanicity,:father_hispanicity_mex,
			:mother_hispanicity_mex,:father_race_code,:mother_race_code)

		a[:hispanicity] = 999
		if( a[:mother_hispanicity] == a[:father_hispanicity] ) && 
				!a[:father_hispanicity].blank?
			a[:hispanicity] = a[:father_hispanicity]
		end
		a[:hispanicity] = 1 if ( 
			[a[:mother_hispanicity],a[:father_hispanicity]].include?('1') )


		a[:hispanicity_mex] = 999
		if( a[:mother_hispanicity_mex] == a[:father_hispanicity_mex] ) &&
				!a[:father_hispanicity_mex].blank?
			a[:hispanicity_mex] = a[:father_hispanicity_mex]
		end
		a[:hispanicity_mex] = 1 if ( 
			[a[:mother_hispanicity_mex],a[:father_hispanicity_mex]].include?('1') )

		new_attributes.each do |k,v|
			#	NOTE always check if attribute is blank as don't want to delete data
			study_subject.send("#{k}=",v) unless v.blank?
		end

		#	gotta save the changes before the subject, otherwise ... poof
		#	probably not necessary to save them to the bc_info though
		self.changes = study_subject.changes
#puts changes.inspect

#
#	TODO gonna have to remember this but will need to pull it out in rake task DONE
#
#		study_subjects.push(study_subject)
#

		if study_subject.changed?

			#	kinda crued, but just want to remember that this was changed in email
			study_subject.instance_variable_set("@bc_info_changed",true) 

			if study_subject.save

#				if( Rails.env == 'development' )
#					new_attributes.each do |k,v|
#						next if %w(dob).include?(k)
#						unless v.blank?
#							#	puts "comparing #{k}"
#							#	puts "#{study_subject.send(k)}:#{v}"
#							assert_string_equal( study_subject.send(k), v, k) 
#						end
#					end
#					assert_string_equal( study_subject.dob, 
#						new_attributes['dob'].to_date, 'dob'
#						) unless new_attributes['dob'].blank?
#				end

				study_subject.operational_events.create(
					:occurred_at => DateTime.current,
					:project_id => Project['ccls'].id,
					:operational_event_type_id => OperationalEventType['datachanged'].id,
					:description => "ICF Screening data changes from #{bc_info_file}",
					:event_notes => "Changes:  #{changes}")

			else

#				puts "Subject #{study_subject.icf_master_id} didn't save?!?!?!"
#				raise "Subject #{study_subject.icf_master_id} didn't save?!?!?!"

#				Notification.plain(
#					"#{bc_info_file} subject save failed?  " <<
#					"I'm confused?  Help me.  " <<
#					"Subject #{study_subject.icf_master_id}. " <<
#					"Error messages ...:#{study_subject.errors.full_messages.to_sentence}:",
#					email_options.merge({ 
#						:subject => "ODMS: ERROR!  Subject save failed?  in #{bc_info_file}" })
#				).deliver
#				puts study_subject.errors.full_messages.to_sentence
#				puts study_subject.inspect
#				puts study_subject.errors.inspect

			end	#	if study_subject.save

		end	#	if study_subject.changed?

		#	I think that this OE should be created regardless of whether the 
		#	subject's info has changed.  It simply flags the existance in a bc_info.
		study_subject.operational_events.create(
			:occurred_at => date || DateTime.current,
			:project_id  => Project['ccls'].id,
			:operational_event_type_id => OperationalEventType['screener_complete'].id,
			:description => "ICF screening complete from #{bc_info_file}" ) if (
				study_subject.operational_events.where(
					:operational_event_type_id => OperationalEventType['screener_complete'].id)
					.where(:project_id => Project[:ccls].id).empty? )

		unless study_subject.mother.try(:id).nil?
			#	ReadOnlyRecord due to joins so need to re-find.
			mother = StudySubject.find(study_subject.mother.id)

			mother.hispanicity = study_subject.mother_hispanicity unless(
				study_subject.mother_hispanicity.blank? )
			mother.hispanicity_mex = study_subject.mother_hispanicity_mex unless(
				study_subject.mother_hispanicity_mex.blank? )
			mother.first_name  = study_subject.mother_first_name unless(
				study_subject.mother_first_name.blank? )
			mother.last_name   = study_subject.mother_last_name unless(
				study_subject.mother_last_name.blank? )
			mother.maiden_name = study_subject.mother_maiden_name unless(
				study_subject.mother_maiden_name.blank? )

#			puts "Mother changes"
			#	probably not necessary to save them to the bc_info though
			self.mother_changes = mother.changes
#			puts changes
			mother.save

			mother.operational_events.create(
				:occurred_at => DateTime.current,
				:project_id => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['datachanged'].id,
				:description => "ICF Screening data changes from #{bc_info_file}",
				:event_notes => "Changes:  #{changes}")

			if study_subject.mother_race_code
				mr = Race.where(:code => study_subject.mother_race_code).first
				if mr.nil?
					Notification.plain("No race found with code :#{study_subject.mother_race_code}:",
							:subject => "ODMS: Invalid mother_race_code"
					).deliver
				elsif mr.is_other? or mr.is_mixed?
					msr = if mother.races.include?( mr )
						mother.subject_races.where(:race_code => mr.code).first
					else
						mother.subject_races.new(:race_code => mr.code)
					end

					new_other_race = study_subject.other_mother_race || "UNSPECIFIED IN BC_INFO"
					msr.other_race = if msr.other_race.blank?
						new_other_race
					elsif msr.other_race.downcase.include?(new_other_race.downcase)
						msr.other_race
					else
						"#{msr.other_race}, #{new_other_race}"
					end
					msr.save
				else
					mother.races << mr unless mother.races.include?( mr )
				end	#	if mr.nil? (mr is not nil or other or mixed)
			end	#	if study_subject.mother_race_code

		end	#	unless study_subject.mother.id.nil?

		study_subject.bc_requests.create(:status => 'waitlist') unless( 
			study_subject.bc_requests.incomplete.exists? )

	end

end
__END__
