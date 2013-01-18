class ScreeningDatum < ActiveRecord::Base
#
#	belongs_to :screening_datum_update
#	attr_protected :screening_datum_update_id, :screening_datum_update
#	belongs_to :study_subject
#	attr_protected :study_subject_id, :study_subject
#
#	has_many :odms_exceptions, :as => :exceptable
#
#	after_create :post_processing
#
#	def post_processing
#		if icf_master_id.blank?
#			odms_exceptions.create(:name => 'screening data append',
#				:description => "icf_master_id blank")
#		else
#			#	DO NOT USE 'study_subject' here as it will conflict with
#			#	the study_subject association.
#			subject = StudySubject.where(:icf_master_id => icf_master_id).first
#			if subject.nil?
#				odms_exceptions.create(:name => 'screening data append',
#					:description => "No subject found with icf_master_id :#{icf_master_id}:")
#			else
#				#	assign study_subject_id to case's id
#				self.update_column(:study_subject_id, subject.id)
#				self.update_study_subject_attributes
#				subject.operational_events.create(
#					:occurred_at => date || DateTime.now,
#					:project_id  => Project['ccls'].id,
#					:operational_event_type_id => OperationalEventType['screener_complete'].id,
#					:description => "ICF screening complete" )
#			end
#		end
#	end	#	def post_processing
#
#	#
#	#	Separated this out so that can do separately if needed.
#	#
#	def update_study_subject_attributes
#		return if icf_master_id.blank?
#
#		#	If subject is created after this record (this would be odd)
#		#	then study subject isn't set.  Regardless, check if its
#		#	set.  If not, try to set it.  If can't, go away.
#		unless study_subject
#			subject = StudySubject.where(:icf_master_id => icf_master_id).first
#			return if subject.nil?
#			self.update_column(:study_subject_id, subject.id)
#		end
#
#		%w( dob sex father_first_name father_last_name 
#			mother_first_name mother_last_name mother_maiden_name
#			first_name middle_name last_name ).each do |field|
#
#			current, updated = if( field == 'dob' )
#				[study_subject.send(field), self.send("new_#{field}")]
#			else
#				[study_subject.send(field).to_s,
#					self.send("new_#{field}").to_s.squish.namerize]
#			end
#
#			if !updated.blank? and ( current != updated )
##
##	It will be database heavy, but perhaps update the database for each attribute
##	This way I can tell when the failure occurs and deal with it more appropriately?
##
##				study_subject.send("#{field}=", updated)
#				if study_subject.update_attributes(field => updated)
#					study_subject.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['datachanged'].id,
#						:description => "ICF Screening data change:  " <<
#							"The value in #{field} has changed from " <<
#							"\"#{current}\" to \"#{updated}\"" )
#				else
#
#
#
##	TODO do something to show failure
#
#
##				odms_exceptions.create(
##					:name        => 'screening data update',
##					:description => "Error updating study subject. " <<
##													"Save failed! " <<
##													study_subject.errors.full_messages.to_sentence) 
#
#
##	study_subject.reload		#	if don't, won't ever save as bad attribute still there
#
#
#
#				end
#			end
#
#		end
#
##  section 3 has fields which we won't already have since this is their point of origin. Any values in those columns can be updated without comparison to the existing record.
#
#		%w( mother_race father_race ).each do |field|
#			unless self.send(field).blank?	#	IS BLANK OK?  UNKNOWN ALWAYS SEEMS POSSIBLE
#				if( race = Race.where(:id => self.send(field)).first )
##					study_subject.send("#{field}_id=", race.id)
#					if study_subject.update_attributes("#{field}_id" => race.id)
#
##						study_subject.operational_events.create(
##							:occurred_at => DateTime.now,
##							:project_id => Project['ccls'].id,
##							:operational_event_type_id => OperationalEventType['datachanged'].id,
##							:description => "ICF Screening data change:  " <<
##								"The value in #{field} has changed from " <<
##								"\"#{current}\" to \"#{updated}\"" )
#					else
#
#
#
#
##	FAILURE
#
#
#
#
#					end
#				else
#					study_subject.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['dataconflict'].id,
#						:description => "ICF screening data conflict:  " <<
#							"#{field} does not match CCLS designations.    " <<
#							"Value = #{self.send(field)}" )
#				end
#			end
#		end
#
#		%w( mother_hispanicity father_hispanicity ).each do |field|
#			unless self.send(field).blank?	#	IS BLANK OK?  UNKNOWN ALWAYS SEEMS POSSIBLE
##				if( race = Race.where(:id => self.send(field)).first )
##					study_subject.send("#{field}_id=", race.id)
#				if( self.send(field) != 0 )
##					study_subject.send("#{field}_id=", self.send(field) )
#					if study_subject.update_attributes("#{field}_id" => self.send(field) )
#
#
#
#
#
#					else
#
#
#
##	FAILURE
#
#
#
#					end
#				else
#					study_subject.operational_events.create(
#						:occurred_at => DateTime.now,
#						:project_id => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['dataconflict'].id,
#						:description => "ICF screening data conflict:  " <<
#							"#{field} does not match CCLS designations.    " <<
#							"Value = #{self.send(field)}" )
#				end
#			end
#		end
#	end
#
end
