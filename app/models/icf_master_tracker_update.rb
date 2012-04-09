
#	The ICF Master Tracker Update simply takes an uploaded file
#	for parsing to create and update ICF Master Tracker records.
#
class IcfMasterTrackerUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(File.dirname(__FILE__),'../..','config/icf_master_tracker_update.yml')
		))).result)[Rails.env]

	validates_presence_of :master_tracker_date

#	validates_attachment :csv_file, :presence => true
	validates_attachment_presence     :csv_file
#	validates_attachment_content_type :csv_file,
#		:content_type => ["text/csv","text/plain","application/vnd.ms-excel"]
	validates_inclusion_of :csv_file_content_type,
		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
		:allow_blank => true

#	the paperclip content type validator does not work for multiple possible
#	content types.  It loops over all possible and basically will always
#	raise an error.  Using the core rails inclusion validator works fine.
#text/csv
#text/plain
#text/csv, text/plain, application/vnd.ms-excel


#	validates_attachment :csv_file, :presence => true,
#		:content_type => { :content_type => "text/csv" }
#	It seems that our csv files are uploaded with the content_type ...
#	@content_type="application/vnd.ms-excel"



#	perhaps by file extension rather than mime type?
#	validates_format_of :csv_file_file_name,
#		:with => %r{\.csv$}i,
#		:allow_blank => true


	validate :valid_csv_file_column_names

	def valid_csv_file_column_names
##		f=FasterCSV.open(self.csv_file.path,'rb')
##	if new record, csv_file.path doesn't work as is no id
##	if updating the csv_file, the existing csv_file.path is (may be?) the existing file
##		not the new file.
		if self.csv_file && self.csv_file.to_file
			f=FasterCSV.open(self.csv_file.to_file.path,'rb')
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
			(f=FasterCSV.open( self.csv_file.path, 'rb',{
				:headers => true })).each do |line|

#
#	The IcfMasterTracker will include an after_save or something that will
#	determine what has changed and update appropriately.  It may also
#	create OperationalEvents to document the data changes.  As it is
#	theoretically possible that the Masterid does not exist in the identifiers
#	table, perhaps add a successfully_updated_models flag which could
#	be used?
#

				icf_master_tracker = IcfMasterTracker.find_or_create_by_master_id(
					line['master_id'],
					:master_tracker_date => self.master_tracker_date )

#				icf_master_tracker = IcfMasterTracker.where(
#					:master_id => line['master_id']).first
#				if icf_master_tracker.nil?
#					icf_master_tracker = IcfMasterTracker.create(
#						:master_id           => line['master_id'],
#						:master_tracker_date => self.master_tracker_date )
#				end

#
#	NOTE Why no errors?  I think that it should raise errors,
#		although I really hope that there aren't any.
#

				#	NO BANG. Don't want to raise any errors.
				successfully_updated = icf_master_tracker.update_attributes!(
					line.to_hash.delete_keys!(
						'master_id').merge(
						:master_tracker_date => self.master_tracker_date) )

#	can't do this ... as it returns the value of the deleted key
#					line.to_hash.delete('master_id'))


#
#	errors = icf_master_tracker.errors.full_messages.to_sentence
#	These won't be validation errors as there shouldn't be any.
#	Perhaps "no column by that name" errors if csv file changes?
#
#	Add successfully_updated value?
#		icf_master_tracker.update_attribute(:sucessfully_updated, successfully_updated)
#	will the above include the line's attributes?
#
#	Add update_errors column?
#		icf_master_tracker.update_attribute(:update_errors, errors)
#

				results.push(icf_master_tracker)

			end	#	(f=FasterCSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
		end	#	if !self.csv_file_file_name.blank? && File.exists?(self.csv_file.path)
		results	#	TODO why am I returning anything?  will I use this later?
	end	#	def parse


#
#	Expect to use this in a validation, but do not just yet.
#
	def self.expected_column_names
		["master_id", "master_id_mother", "language", "record_owner", "record_status", "record_status_date", "date_received", "last_attempt", "last_disposition", "curr_phone", "record_sent_for_matching", "record_received_from_matching", "sent_pre_incentive", "released_to_cati", "confirmed_cati_contact", "refused", "deceased_notification", "is_eligible", "ineligible_reason", "confirmation_packet_sent", "cati_protocol_exhausted", "new_phone_released_to_cati", "plea_notification_sent", "case_returned_for_new_info", "case_returned_from_berkeley", "cati_complete", "kit_mother_sent", "kit_infant_sent", "kit_child_sent", "kid_adolescent_sent", "kit_mother_refused_code", "kit_child_refused_code", "no_response_to_plea", "response_received_from_plea", "sent_to_in_person_followup", "kit_mother_received", "kit_child_received", "thank_you_sent", "physician_request_sent", "physician_response_received", "vaccine_auth_received", "recollect"]
	end
	
	def expected_column_names
		IcfMasterTrackerUpdate.expected_column_names
	end

end
