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

#	validates_presence_of :address_id
	validates_presence_of :address, :if => :address_id

#	validates_presence_of :instrument_version_id
	validates_presence_of :instrument_version, :if => :instrument_version_id

#	validates_presence_of :interview_method_id
	validates_presence_of :interview_method, :if => :interview_method_id

#	validates_presence_of :interviewer_id
	validates_presence_of :interviewer, :if => :interviewer_id

#	validates_presence_of :language_id
	validates_presence_of :language, :if => :language_id

#	validates_presence_of :study_subject_id
	validates_presence_of :study_subject, :if => :study_subject_id

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
