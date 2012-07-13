class Hospital < ActiveRecord::Base

	acts_as_list

	belongs_to :organization
	belongs_to :contact, :class_name => 'Person'

	#	database will default to false
	validates_inclusion_of :has_irb_waiver, :in => [ true, false ]

	#	if organization_id is not unique, using find_by_organization_id as I do 
	#	WILL cause problems as it will only ever return the first match
	validates_presence_of   :organization_id
	validates_presence_of   :organization, :if => :organization_id
	validates_uniqueness_of :organization_id, 
		:allow_blank => true

	scope :active,      where( :is_active => true )
	scope :waivered,    where( :has_irb_waiver => true )
	scope :nonwaivered, where( :has_irb_waiver => false )

	delegate :to_s, :to => :organization, :allow_nil => true

end
