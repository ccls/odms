class SampleLocation < ActiveRecord::Base

	belongs_to :organization

	validations_from_yaml_file

	scope :active,      ->{ where( :is_active => true ) }
	scope :without_org, ->{ where( :organization_id => nil ) }

	delegate :to_s, :to => :organization, :allow_nil => true

end
