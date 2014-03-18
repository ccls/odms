class SampleCollector < ActiveRecord::Base

	attr_accessible :organization_id, :other_organization

	belongs_to :organization

	validations_from_yaml_file

	delegate :is_other?, :to => :organization, :allow_nil => true, :prefix => true

	delegate :to_s, :to => :organization, :allow_nil => true

end
