#	==	requires
#	*	description ( unique and > 3 chars )
class SampleType < ActiveRecord::Base

	attr_accessible :parent_id, :key, :description, :for_new_sample, :t2k_sample_type_id, :gegl_sample_type_id #	position ?

	acts_as_list :scope => :parent_id
	acts_like_a_hash

	has_many :samples

	belongs_to :parent, :class_name => 'SampleType'
	has_many :children, 
		:class_name => 'SampleType',
		:foreign_key => 'parent_id',
		:dependent => :nullify
	
	scope :roots,     ->{ where( :parent_id => nil ) }
	scope :not_roots, ->{ where(self.arel_table[:parent_id].not_eq(nil)) }
	scope :for_new_samples, ->{ where( :for_new_sample => true ) }

	validations_from_yaml_file

	#	kinda needed for group_method when calling grouped_collection_select
	#	as it takes a single symbol that is sent and I don't think that the
	#	symbol can be a chain of methods, just a single method.
	def children_for_new_samples
		children.for_new_samples
	end

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
