#	==	requires
#	*	name ( unique and > 3 chars )
class Organization < ActiveRecord::Base

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

#	scope :without_hospital, joins('LEFT JOIN hospitals ON organizations.id = hospitals.organization_id').where('hospitals.organization_id' => nil)
#	scope :without_hospital, includes(:hospital).merge(Hospital.without_org)

	scope :without_hospital, joins(
		Arel::Nodes::OuterJoin.new(
			Hospital.arel_table,Arel::Nodes::On.new(
				self.arel_table[:id].eq(Hospital.arel_table[:organization_id]))))
		.merge(Hospital.without_org)
#
#	Oddly enough, using 'includes' will use a LEFT OUTER JOIN 
#		IF AND ONLY IF a condition actually uses it
#
#	may be more appropriate to merge scopes somehow
#
#	scope :without_sample_location, joins('LEFT JOIN sample_locations ON organizations.id = sample_locations.organization_id').where('sample_locations.organization_id' => nil)
#	scope :without_sample_location, includes(:sample_location).merge(SampleLocation.without_org)
#	scope :without_sample_location, joins(:sample_location,Arel::Nodes::OuterJoin).merge(SampleLocation.without_org)

#	using includes generates lots of fake column names
#	SELECT `organizations`.`id` AS t0_r0, `organizations`.`position` AS t0_r1, `organizations`.`key` AS t0_r2, `organizations`.`name` AS t0_r3, `organizations`.`person_id` AS t0_r4, `organizations`.`created_at` AS t0_r5, `organizations`.`updated_at` AS t0_r6, `sample_locations`.`id` AS t1_r0, `sample_locations`.`position` AS t1_r1, `sample_locations`.`organization_id` AS t1_r2, `sample_locations`.`notes` AS t1_r3, `sample_locations`.`is_active` AS t1_r4, `sample_locations`.`created_at` AS t1_r5, `sample_locations`.`updated_at` AS t1_r6 FROM `organizations` LEFT OUTER JOIN `sample_locations` ON `sample_locations`.`organization_id` = `organizations`.`id` WHERE `sample_locations`.`organization_id` IS NULL

#	this also works (trying to be agnostic) (cleaner db query)
	scope :without_sample_location, joins(
		Arel::Nodes::OuterJoin.new(
			SampleLocation.arel_table,Arel::Nodes::On.new(
				self.arel_table[:id].eq(SampleLocation.arel_table[:organization_id]))))
		.merge(SampleLocation.without_org)

#Organization.without_sample_location.to_sql
#=> "SELECT `organizations`.* FROM `organizations` 
#		LEFT OUTER JOIN `sample_locations` 
#			ON `organizations`.`id` = `sample_locations`.`organization_id` 
#		WHERE `sample_locations`.`organization_id` IS NULL"


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
