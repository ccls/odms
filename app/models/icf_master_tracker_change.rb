class IcfMasterTrackerChange < ActiveRecord::Base
#
#	#	Would be pointless without the icf_master_id
#	validates_presence_of :icf_master_id
#	validates_presence_of :master_tracker_date
#
##	should probably avoid validations
##	validates_inclusion_of :new_tracker_record, :in => [ true, false ]
#
end
