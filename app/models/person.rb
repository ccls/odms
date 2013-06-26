# don't know exactly
class Person < ActiveRecord::Base

	acts_as_list

	has_many :interviews, :foreign_key => 'interviewer_id'
	has_many :organizations

	validations_from_yaml_file

	scope :interviewers, ->{ where( :person_type_id => 3 ) }

	#	Returns string containing first and last name
	def full_name
		"#{first_name} #{last_name}"
	end

	#	Returns full_name
	def to_s
		full_name
	end

end
