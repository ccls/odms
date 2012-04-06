#
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

end
