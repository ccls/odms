#	==	requires
#	*	name ( unique and > 3 chars )
class Organization < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash(:value => :name)

	belongs_to :person
	has_many :aliquots, :foreign_key => 'owner_id'
	has_many :incoming_transfers, :class_name => 'Transfer', 
		:foreign_key => 'to_organization_id'
	has_many :outgoing_transfers, :class_name => 'Transfer', 
		:foreign_key => 'from_organization_id'
#	has_many :hospitals
	has_one  :hospital
	has_one  :sample_location
	has_many :patients
#	has_many :sample_collectors

	scope :without_hospital, joins('LEFT JOIN hospitals ON organizations.id = hospitals.organization_id').where('organization_id IS NULL')

	scope :without_sample_location, joins('LEFT JOIN sample_locations ON organizations.id = sample_locations.organization_id').where('organization_id IS NULL')

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
