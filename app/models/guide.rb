class Guide < ActiveRecord::Base
	default_scope :order => 'controller ASC, action ASC'
	validates_uniqueness_of :action, :scope => :controller
	with_options :maximum => 250, :allow_blank => true do |o|
		o.validates_length_of :controller
		o.validates_length_of :action
	end
end
