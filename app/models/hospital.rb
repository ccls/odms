class Hospital < ActiveRecord::Base

	attr_accessible :organization_id, :has_irb_waiver, :is_active, :contact_id	 #	position?

	acts_as_list

	belongs_to :organization
	belongs_to :contact, :class_name => 'Person'

	validations_from_yaml_file

	scope :active,      ->{ where( :is_active => true ) }
	scope :waivered,    ->{ where( :has_irb_waiver => true ) }
	scope :nonwaivered, ->{ where( :has_irb_waiver => false ) }
	scope :without_org, ->{ where( :organization_id => nil ) }

	delegate :to_s, :to => :organization, :allow_nil => true

end
