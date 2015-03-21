class Guide < ActiveRecord::Base

#	NOTE this is no longer used

#	attr_accessible :controller, :action, :body
#
#	validates_uniqueness_of :action, :scope => :controller
#
#	validates_length_of :controller, :action, 
#		:maximum => 250, :allow_blank => true

	validations_from_yaml_file

	def to_s
		"#{controller}##{action}"
	end

end
