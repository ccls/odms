require 'csv'
#
#	The ICF Master Tracker Update simply takes an uploaded file
#	for parsing to create and update ICF Master Tracker records.
#
#	The csv_file contains icf responses, most of which are 
#	going to be ignored.  "CATI complete" looks like it is
#	the important piece of intel.
#
class IcfMasterTrackerUpdate < ActiveRecord::Base
#
#	has_attached_file :csv_file,
#		YAML::load(ERB.new(IO.read(File.expand_path(
#			File.join(Rails.root,'config/icf_master_tracker_update.yml')
#		))).result)[Rails.env]
#
#	validates_presence_of   :master_tracker_date
#	validates_uniqueness_of :master_tracker_date
#
#	validates_attachment_presence     :csv_file
#
#	validates_inclusion_of :csv_file_content_type,
#		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
#		:allow_blank => true
#
##	perhaps by file extension rather than mime type?
##	validates_format_of :csv_file_file_name,
##		:with => %r{\.csv$}i,
##		:allow_blank => true
#
#	validate :valid_csv_file_column_names
#
#	def valid_csv_file_column_names
#		#	'to_file' needed as the path method wouldn't be
#		#	defined until after save.
#		if !self.csv_file_file_name.blank? && self.csv_file.queued_for_write[:original].path
#			f=CSV.open(self.csv_file.queued_for_write[:original].path,'rb')
#			column_names = f.readline
#			f.close
#			if column_names != expected_column_names 
#				errors.add(:csv_file, "Invalid column names in csv_file.")
#			end
#		end
#	end
#
#	#	This doesn't really do much of anything yet.
#	def parse
#		results = []
#		if !self.csv_file_file_name.blank? &&
#				File.exists?(self.csv_file.path)
#			(f=CSV.open( self.csv_file.path, 'rb',{
#				:headers => true })).each do |line|
#
#				icf_master_tracker = IcfMasterTracker.find_or_create_by_master_id(
#					line['master_id'],
#					:master_tracker_date => self.master_tracker_date )
#
#				successfully_updated = icf_master_tracker.update_attributes!(
#					line.to_hash.delete_keys!(
#						'master_id').merge(
#						:master_tracker_date => self.master_tracker_date) )
#
#				results.push(icf_master_tracker)
#			end	#	(f=CSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
#		end	#	if !self.csv_file_file_name.blank? && File.exists?(self.csv_file.path)
#		results	#	TODO why am I returning anything?  will I use this later?
#	end	#	def parse
#
#	def self.expected_column_names
#		@expected_column_names ||= ( IcfMasterTracker.attribute_names - 
#			%w( id study_subject_id flagged_for_update last_update_attempt_errors 
#				last_update_attempted_at created_at updated_at ) )
#	end
#	
#	def expected_column_names
#		IcfMasterTrackerUpdate.expected_column_names
#	end
#
end
