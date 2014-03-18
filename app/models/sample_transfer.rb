class SampleTransfer < ActiveRecord::Base
#  attr_accessible :destination_org_id, :notes, :sample_id, :sent_on, :source_org_id, :status



	attr_protected	#	rails 4 I shouldn't do this




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

	def self.with_status(status=nil)
		( status.blank? ) ? all : where(:status => status)
	end

	def active?
		status == 'active'
	end

	#	primarily for the destroy confirmation pop-up
	def to_s
		"for SampleID #{sample.try(:sampleid)||'------'}"
	end

#	def waitlist?
#		status == 'waitlist'
#	end

end
