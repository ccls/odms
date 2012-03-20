#	==	requires
#	*	description ( unique and > 3 chars )
class SampleType < ActiveRecord::Base

	acts_as_list :scope => :parent_id
#	default_scope :order => :position
#	Don't use default_scope with acts_as_list
#	default_scope :order => 'parent_id, position, description ASC'

	acts_like_a_hash

	has_many :samples

	belongs_to :parent, :class_name => 'SampleType'
	has_many :children, 
		:class_name => 'SampleType',
		:foreign_key => 'parent_id',
		:dependent => :nullify
	
#	scope :roots, :conditions => { :parent_id => nil }
#	scope :not_roots, :conditions => ['sample_types.parent_id IS NOT NULL' ]
	scope :roots,     where( :parent_id => nil )
	scope :not_roots, where( 'sample_types.parent_id IS NOT NULL' )

	#	Returns description
	def to_s
		description
	end

	def is_root?
		parent_id.blank?
	end

	def is_child?
		!is_root?
	end

end
