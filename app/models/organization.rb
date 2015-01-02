#	==	requires
#	*	name ( unique and > 3 chars )
class Organization < ActiveRecord::Base

	attr_accessible :key, :name, :person_id #	position ?

	acts_as_list
	acts_like_a_hash(:value => :name)

	belongs_to :person
#	has_many :aliquots, :foreign_key => 'owner_id'
#	has_many :incoming_transfers, :class_name => 'Transfer', 
#		:foreign_key => 'to_organization_id'
#	has_many :outgoing_transfers, :class_name => 'Transfer', 
#		:foreign_key => 'from_organization_id'
#	has_many :hospitals
	has_one  :hospital
	has_one  :sample_location
	has_many :patients
#	has_many :sample_collectors

	scope :without_hospital, ->{ joins(
		Arel::Nodes::OuterJoin.new(
			Hospital.arel_table,Arel::Nodes::On.new(
				self.arel_table[:id].eq(Hospital.arel_table[:organization_id]))))
		.merge(Hospital.without_org) }

	scope :without_sample_location, ->{ joins(
		Arel::Nodes::OuterJoin.new(
			SampleLocation.arel_table,Arel::Nodes::On.new(
				self.arel_table[:id].eq(SampleLocation.arel_table[:organization_id]))))
		.merge(SampleLocation.without_org) }

	#	Returns name
	def to_s
		name
	end

	#	Returns boolean of comparison
	#	true only if key == 'other'
	def is_other?
		key == 'other'
	end

end

__END__
