class SampleLocation < ActiveRecord::Base

	attr_accessible :organization_id, :notes, :is_active #	position ?

	acts_as_list

	belongs_to :organization

	validations_from_yaml_file

	scope :active,      ->{ where( :is_active => true ) }
	scope :without_org, ->{ where( :organization_id => nil ) }

	delegate :to_s, :to => :organization, :allow_nil => true

end
