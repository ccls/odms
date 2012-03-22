#	==	requires
#	*	address_id
#	*	interviewer_id
#	*	study_subject_id
class Interview < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected( :study_subject_id, :study_subject )

	##
	#	why is this here?	Homex for assigning interview outcome
	accepts_nested_attributes_for :study_subject

	belongs_to :address
	belongs_to :interviewer, :class_name => 'Person'
	belongs_to :instrument_version
	belongs_to :interview_method
	belongs_to :language
	belongs_to :subject_relationship

	delegate :is_other?, :to => :subject_relationship, :allow_nil => true, :prefix => true

	validates_complete_date_for :began_on, :allow_nil => true
	validates_complete_date_for :ended_on, :allow_nil => true
	validates_complete_date_for :intro_letter_sent_on, :allow_nil => true

	validates_length_of :other_subject_relationship, 
		:respondent_first_name, :respondent_last_name,
			:maximum => 250, :allow_blank => true

#	validate :presence_of_other_subject_relationship
	validates_presence_of :other_subject_relationship,
		:message => "You must specify a relationship with 'other relationship' is selected",
		:if => :subject_relationship_is_other?

	validates_absence_of :other_subject_relationship,
		:message => "not allowed",
		:if => :subject_relationship_id_blank?

	validates_inclusion_of :began_at_hour, :in => (1..12),
		:allow_blank => true
	validates_inclusion_of :began_at_minute, :in => (0..59),
		:allow_blank => true
	validates_format_of    :began_at_meridiem, :with => /\A(AM|PM)\z/i,
		:allow_blank => true
	validates_inclusion_of :ended_at_hour, :in => (1..12),
		:allow_blank => true
	validates_inclusion_of :ended_at_minute, :in => (0..59),
		:allow_blank => true
	validates_format_of    :ended_at_meridiem, :with => /\A(AM|PM)\z/i,
		:allow_blank => true

	before_save :update_intro_operational_event,
		:if => :intro_letter_sent_on_changed?

	before_save :set_began_at
	before_save :set_ended_at
	attr_protected :began_at
	attr_protected :ended_at

	#	Returns string containing respondent's first and last name
	def respondent_full_name
		[respondent_first_name, respondent_last_name].compact.join(' ')
	end

protected

	def set_began_at
		if [began_on, began_at_hour,began_at_minute,began_at_meridiem].all?
			self.began_at = DateTime.parse(
				"#{began_on} #{began_at_hour}:#{began_at_minute} #{began_at_meridiem}")
#				"#{began_on} #{began_at_hour}:#{began_at_minute} #{began_at_meridiem} PST")
		else
			self.began_at = nil
		end
	end

	def set_ended_at
		if [ended_on, ended_at_hour,ended_at_minute,ended_at_meridiem].all?
			self.ended_at = DateTime.parse(
				"#{ended_on} #{ended_at_hour}:#{ended_at_minute} #{ended_at_meridiem}")
#				"#{ended_on} #{ended_at_hour}:#{ended_at_minute} #{ended_at_meridiem} PST")
		else
			self.ended_at = nil
		end
	end

	def subject_relationship_id_blank?
		subject_relationship_id.blank?
	end

	def update_intro_operational_event
		oet = OperationalEventType['intro']
		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
		if oet && hxe
#			oe = study_subject.operational_events.find(:first,
#				:conditions => { 
#					:project_id                => Project['HomeExposures'].id,
#					:operational_event_type_id => oet.id } )
			oe = study_subject.operational_events.where(
					:project_id => Project['HomeExposures'].id ).where(
					:operational_event_type_id => oet.id ).limit(1).first
			if oe
#				oe.update_attributes(
				oe.update_attributes!(
					:description => oet.description,
					:occurred_on => intro_letter_sent_on
				)
			else
#				study_subject.operational_events.new(
				study_subject.operational_events.create!(
					:project_id                => Project['HomeExposures'].id,
					:operational_event_type_id => oet.id,
					:description               => oet.description,
					:occurred_on               => intro_letter_sent_on
				)
#				).save!
			end
		end
	end

#	#	custom validation for custom message without standard attribute prefix
#	def presence_of_other_subject_relationship
#		if subject_relationship_is_other? and other_subject_relationship.blank?
#			errors.add(:other_subject_relationship, 
#					"You must specify a relationship with 'other relationship' is selected." )
#		end
#	end

end
