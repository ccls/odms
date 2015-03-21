class SampleLocation < ActiveRecord::Base

#	attr_accessible :organization_id, :is_active

	belongs_to :organization

	validations_from_yaml_file

	scope :active,      ->{ where( :is_active => true ) }
	scope :without_org, ->{ where( :organization_id => nil ) }

	delegate :to_s, :to => :organization, :allow_nil => true

end
