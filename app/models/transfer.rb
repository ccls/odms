#	==	requires
#	*	aliquot_id
#	*	from_organization_id
#	*	to_organization_id
class Transfer < ActiveRecord::Base
#
##	NOTE this is not used
#
#
#	belongs_to :aliquot
#	belongs_to :from_organization, :class_name => "Organization"
#	belongs_to :to_organization,   :class_name => "Organization"
#
#	validations_from_yaml_file
#
#	before_save :update_aliquot_owner
#
#	#	Associate the given transfer "to" an #Organization
#	def to(organization)
#		self.to_organization = organization
#		self
#	end
#
#protected
#
#	#	Set associated aliquot's owner to the receiving #Organization.
#	def update_aliquot_owner
#		self.aliquot.update_column(:owner_id, self.to_organization.id)
#	end
#
end
