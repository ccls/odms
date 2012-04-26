#
#	The ICF Master Tracker table should be an exact duplicate
#	of ICF's Master Tracker table.
#
#	When a record in this table is updated, a new record
#	in ICF Master Tracker Changes should be created
#	documenting the change.
#
class IcfMasterTracker < ActiveRecord::Base

	validates_presence_of   :master_id
	validates_uniqueness_of :master_id, :allow_blank => true
	attr_protected :master_id

#	validate all string field lengths ?
	validates_length_of :last_update_attempt_errors, 
		:maximum => 65000, :allow_blank => true

	belongs_to :study_subject
	attr_protected( :study_subject_id, :study_subject )

	before_save :attach_study_subject
	before_save :flag_for_update

#	before_create :save_all_changes	#	this will create a "new_record"
#	after_save    :save_all_changes	#	this will document all the changes

after_create :create_new_tracker_record_change
#
#	after_save will be fired after create as well as update.
#	after_update will only be fired after update.
#
#	therefore, after_save will document the change of master_id from '' to 'whatever'
#	this is kinda irrelevant
#
after_update :create_tracker_record_changes
#after_save   :create_tracker_record_changes

	#	purely for passing the date from the IcfMasterTrackerUpdate
	#	to the IcfMasterTrackerChange
	attr_accessor :master_tracker_date

	scope :have_changed, where( :flagged_for_update => true )

	def attach_study_subject
		unless study_subject_id
			self.study_subject_id = StudySubject.where(
				:icf_master_id => self.master_id).limit(1).first.try(:id)
		end
	end

	def ignorable_changes
		%w{ id created_at updated_at
			flagged_for_update last_update_attempt_errors last_update_attempted_at }
	end

	def unignorable_changes
		changes.dup.delete_keys!(*ignorable_changes)
	end

	def flag_for_update
		self.flagged_for_update = true unless unignorable_changes.empty?
	end

	def create_new_tracker_record_change
			IcfMasterTrackerChange.create!(
				:icf_master_id       => self.master_id,
				:master_tracker_date => self.master_tracker_date,
				:new_tracker_record  => true
			)
	end

	def create_tracker_record_changes
			unignorable_changes.each do |field,values|
				IcfMasterTrackerChange.create!(
					:icf_master_id       => self.master_id,
					:master_tracker_date => self.master_tracker_date,
					:modified_column     => field,
					:previous_value      => values[0],
					:new_value           => values[1]
				)
			end
	end

#	def save_all_changes
##
##	this won't really work as the record is first created from the master_id
##	and then it is updated. This means that it create the 'new tracker' and
##	then immediately create changes for each non-nil value. This may be
##	desired, but be aware.
##
#
##	NOTE 20120406 add the !'s
#		if new_record?
#			IcfMasterTrackerChange.create!(
#				:icf_master_id       => self.master_id,
#				:master_tracker_date => self.master_tracker_date,
#				:new_tracker_record  => true
#			)
#		else
#			unignorable_changes.each do |field,values|
#				IcfMasterTrackerChange.create!(
#					:icf_master_id       => self.master_id,
#					:master_tracker_date => self.master_tracker_date,
#					:modified_column     => field,
#					:previous_value      => values[0],
#					:new_value           => values[1]
#				)
#			end
#		end
#	end

end

__END__


changed?() public

Returns true if any attribute have unsaved changes, false otherwise.

person.changed? # => false
person.name = 'bob'
person.changed? # => true


changes() public

Map of changed attrs => [original value, new value].

person.changes # => {}
person.name = 'bob'
person.changes # => { 'name' => ['bill', 'bob'] }


