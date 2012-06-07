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

	validates_complete_date_for :began_at, :ended_at, :intro_letter_sent_on, 
		:allow_nil => true

	validates_length_of :other_subject_relationship, 
		:respondent_first_name, :respondent_last_name,
			:maximum => 250, :allow_blank => true

	validates_presence_of :other_subject_relationship,
		:message => "You must specify a relationship with 'other relationship' is selected",
			:if => :subject_relationship_is_other?

	validates_absence_of :other_subject_relationship,
		:message => "Other Subject Relationship not allowed",
			:if => :subject_relationship_id_blank?

	#	Returns string containing respondent's first and last name
	def respondent_full_name
		[respondent_first_name, respondent_last_name].compact.join(' ')
	end

protected

	def subject_relationship_id_blank?
		subject_relationship_id.blank?
	end

end
__END__

#	before_save :update_intro_operational_event,
#		:if => :intro_letter_sent_on_changed?

#	def update_intro_operational_event
#		oet = OperationalEventType['intro']
#		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#		if oet && hxe
#			oe = study_subject.operational_events.where(
#					:project_id => Project['HomeExposures'].id ).where(
#					:operational_event_type_id => oet.id ).limit(1).first
#			if oe
#				oe.update_attributes!(
#					:description => oet.description,
#					:occurred_at => intro_letter_sent_on
#				)
#			else
#				study_subject.operational_events.create!(
#					:project_id                => Project['HomeExposures'].id,
#					:operational_event_type_id => oet.id,
#					:description               => oet.description,
#					:occurred_at               => intro_letter_sent_on
#				)
#			end
#		end
#	end
