class SampleTransfer < ActiveRecord::Base
#  attr_accessible :destination_org_id, :notes, :sample_id, :sent_on, :source_org_id, :status

	belongs_to :sample
	belongs_to :source_org,      :class_name => "Organization"
	belongs_to :destination_org, :class_name => "Organization"

#	validates_presence_of :sample_id
#	validates_presence_of :sample, :if => :sample_id
#	validates_presence_of :source_org_id
#	validates_presence_of :source_org, :if => :source_org_id
#	validates_presence_of :destination_org_id
#	validates_presence_of :destination_org, :if => :destination_org_id

	validates_length_of   :status, :maximum => 250, :allow_blank => true
	validates_length_of   :notes,  :maximum => 65000, :allow_blank => true

end
