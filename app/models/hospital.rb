class Hospital < ActiveRecord::Base

	belongs_to :organization

	validations_from_yaml_file

	scope :active,      ->{ where( :is_active => true ) }
	scope :waivered,    ->{ where( :has_irb_waiver => true ) }
	scope :nonwaivered, ->{ where( :has_irb_waiver => false ) }
	scope :without_org, ->{ where( :organization_id => nil ) }

	delegate :to_s, :to => :organization, :allow_nil => true

end
