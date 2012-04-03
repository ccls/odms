class SampleCollector < ActiveRecord::Base

	belongs_to :organization

	validates_presence_of :organization_id
	validates_presence_of :organization, :if => :organization_id

	delegate :is_other?, :to => :organization, :allow_nil => true, :prefix => true

	validates_presence_of :other_organization, :if => :organization_is_other?

	delegate :to_s, :to => :organization, :allow_nil => true

end
