class Guide < ActiveRecord::Base

#	default_scope :order => 'controller ASC, action ASC'
	validates_uniqueness_of :action, :scope => :controller

	validates_length_of :controller, :action, 
		:maximum => 250, :allow_blank => true

	def to_s
		"#{controller}##{action}"
	end

end
