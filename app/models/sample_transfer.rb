class SampleTransfer < ActiveRecord::Base

#	attr_accessible :sample_id, :source_org_id, :destination_org_id, :sent_on, :status, :notes

	belongs_to :sample
	belongs_to :source_org,      :class_name => "Organization"
	belongs_to :destination_org, :class_name => "Organization"

	def self.statuses
		%w( active waitlist complete )
	end

	#	statuses must be defined above before it can be used below.
	validations_from_yaml_file

	scope :active,   ->{ where( :status => 'active' ) }
	scope :waitlist, ->{ where( :status => 'waitlist' ) }
#	scope :pending,  ->{ where( :status => 'pending' ) }
	scope :complete, ->{ where( :status => 'complete' ) }
	scope :with_status, ->(s=nil){ ( s.blank? ) ? all : where(:status => s) }

	def active?
		status == 'active'
	end

	#	primarily for the destroy confirmation pop-up
	def to_s
		"for SampleID #{sample.try(:sampleid)||'------'}"
	end

#	def waiting?
#		status == 'waitlist'
#	end
#
#	def complete?
#		status == 'complete'
#	end

end
