#	==	requires
#	*	address_id
#	*	interviewer_id
#	*	study_subject_id
class Interview < ActiveRecord::Base

#	NOTE this is not used

	belongs_to :study_subject, :counter_cache => true
	attr_protected( :study_subject_id, :study_subject )

	##
	#	why is this here?	Homex for assigning interview outcome
	accepts_nested_attributes_for :study_subject

#	belongs_to :address
	belongs_to :interviewer, :class_name => 'Person'
	belongs_to :instrument_version
	belongs_to :interview_method
	belongs_to :language
	belongs_to :subject_relationship

	delegate :is_other?, :to => :subject_relationship, :allow_nil => true, :prefix => true

	validations_from_yaml_file

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
