require 'csv'
#	The ICF Master Tracker Update simply takes an uploaded file
#	for parsing to create and update ICF Master Tracker records.
#
class IcfMasterTrackerUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(Rails.root,'config/icf_master_tracker_update.yml')
		))).result)[Rails.env]

	validates_presence_of   :master_tracker_date
	validates_uniqueness_of :master_tracker_date

	validates_attachment_presence     :csv_file

	validates_inclusion_of :csv_file_content_type,
		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
		:allow_blank => true

#	perhaps by file extension rather than mime type?
#	validates_format_of :csv_file_file_name,
#		:with => %r{\.csv$}i,
#		:allow_blank => true

	validate :valid_csv_file_column_names

	def valid_csv_file_column_names
		#	'to_file' needed as the path method wouldn't be
		#	defined until after save.
		if !self.csv_file_file_name.blank? && self.csv_file.queued_for_write[:original].path
			f=CSV.open(self.csv_file.queued_for_write[:original].path,'rb')
			column_names = f.readline
			f.close
			if column_names != expected_column_names 
				errors.add(:csv_file, "Invalid column names in csv_file.")
			end
		end
	end

	#	This doesn't really do much of anything yet.
	def parse
		results = []
		if !self.csv_file_file_name.blank? &&
				File.exists?(self.csv_file.path)
			(f=CSV.open( self.csv_file.path, 'rb',{
				:headers => true })).each do |line|

				icf_master_tracker = IcfMasterTracker.find_or_create_by_master_id(
					line['master_id'],
					:master_tracker_date => self.master_tracker_date )

				successfully_updated = icf_master_tracker.update_attributes!(
					line.to_hash.delete_keys!(
						'master_id').merge(
						:master_tracker_date => self.master_tracker_date) )

				results.push(icf_master_tracker)
			end	#	(f=CSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
		end	#	if !self.csv_file_file_name.blank? && File.exists?(self.csv_file.path)
		results	#	TODO why am I returning anything?  will I use this later?
	end	#	def parse

	def self.expected_column_names
		["master_id", "master_id_mother", "language", "record_owner", "record_status", "record_status_date", "date_received", "last_attempt", "last_disposition", "curr_phone", "record_sent_for_matching", "record_received_from_matching", "sent_pre_incentive", "released_to_cati", "confirmed_cati_contact", "refused", "deceased_notification", "is_eligible", "ineligible_reason", "confirmation_packet_sent", "cati_protocol_exhausted", "new_phone_released_to_cati", "plea_notification_sent", "case_returned_for_new_info", "case_returned_from_berkeley", "cati_complete", "kit_mother_sent", "kit_infant_sent", "kit_child_sent", "kid_adolescent_sent", "kit_mother_refused_code", "kit_child_refused_code", "no_response_to_plea", "response_received_from_plea", "sent_to_in_person_followup", "kit_mother_received", "kit_child_received", "thank_you_sent", "physician_request_sent", "physician_response_received", "vaccine_auth_received", "recollect"]
	end
	
	def expected_column_names
		IcfMasterTrackerUpdate.expected_column_names
	end

end
