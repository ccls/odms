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


#	validates_length_of   :status, :maximum => 250, :allow_blank => true
#	validates_length_of   :notes,  :maximum => 65000, :allow_blank => true

	def self.statuses
		%w( active waitlist complete )
	end
	#	statuses must be defined above before it can be used below.
#	validates_inclusion_of :status, :in => statuses, :allow_blank => true
	validations_from_yaml_file

	scope :active,   where( :status => 'active' )
	scope :waitlist, where( :status => 'waitlist' )
#	scope :pending,  where( :status => 'pending' )
	scope :complete, where( :status => 'complete' )

	def self.with_status(status=nil)
		( status.blank? ) ? scoped : where(:status => status)
	end

	def active?
		status == 'active'
	end

#	def waitlist?
#		status == 'waitlist'
#	end

end
