class SampleLocation < ActiveRecord::Base
#  attr_accessible :is_active, :notes, :organization_id, :position

	acts_as_list

	belongs_to :organization

	#	if organization_id is not unique, using find_by_organization_id as I do 
	#	WILL cause problems as it will only ever return the first match
	validates_presence_of   :organization_id
	validates_presence_of   :organization, :if => :organization_id
	validates_uniqueness_of :organization_id, 
		:allow_blank => true

	scope :active,      where( :is_active => true )

	delegate :to_s, :to => :organization, :allow_nil => true

end
