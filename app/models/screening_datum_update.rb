require 'csv'
#
#	The ScreeningDatumUpdate#csv_file comes from ICF
#
#	It contains updated case info which will be passed to USC
#	to assist to correctly identifying controls?
#
class ScreeningDatumUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(Rails.root,'config/screening_datum_update.yml')
		))).result)[Rails.env]

	has_many :screening_data

	has_many :odms_exceptions, :as => :exceptable

	validates_attachment_presence     :csv_file

	validates_inclusion_of :csv_file_content_type,
		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
		:allow_blank => true

#	perhaps by file extension rather than mime type?
#	validates_format_of :csv_file_file_name,
#		:with => %r{\.csv$}i,
#		:allow_blank => true

	validate :valid_csv_file_column_names

	#	if only doing this after create,
	#	what happens on edit/update?
	#	probably don't want to allow that.
	after_create :parse_csv_file

	def valid_csv_file_column_names
		#	'to_file' needed as the path method wouldn't be
		#	defined until after save.
		#	to_file method has gone away
		#	possible replacement
		#	b.csv_file.queued_for_write[:original].path
		#	all I'm trying to do is read the file but nobody likes this idea
		#
		if !self.csv_file_file_name.blank?  && self.csv_file.queued_for_write[:original].path
			f=CSV.open(self.csv_file.queued_for_write[:original].path,'rb')
			column_names = f.readline
			f.close
			column_names.each do |column_name|
				errors.add(:csv_file, "Invalid column name '#{column_name}' in csv_file."
					) unless expected_column_names.include?(column_name)
			end
#
#	TODO what about missing columns???
#
		end
	end

	def parse_csv_file
		unless self.csv_file_file_name.blank?	#	unlikely as csv_file is required
			csv_file_path = self.csv_file.queued_for_write[:original].path
			unless csv_file_path.nil?
				line_count = 0
				(f=CSV.open( csv_file_path, 'rb',{
						:headers => true })).each do |line|
					line_count += 1

					screening_datum_attributes = line.dup.to_hash

					#	remove any unexpected attribute which would cause create failure
					line.headers.each do |h|
						screening_datum_attributes.delete(h) unless expected_column_names.include?(h)
					end

					if self.screening_data.create( screening_datum_attributes ).new_record?
						odms_exceptions.create({
							:name        => "screening_data append",
							:description => "Record failed to save",
							:notes       => line.to_s
						})	#	the line could be too long, so put in notes section
					end	#	if screening_datum.new_record?
				end	#	(f=CSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
				if line_count != screening_data_count
					odms_exceptions.create({
						:name        => "screening_data append",
						:description => "Screening data upload validation failed: " <<
							"incorrect number of screening data records appended to screening_data."
					})
				end	#	if line_count != screening_data_count
			end	#	unless csv_file_path.nil?
		end	#	unless self.csv_file_file_name.blank?
	end	#	def parse_csv_file

	#	separated purely to allow stubbing in testing
	#	I can't seem to find a way to stub 'screening_data.count'
	def screening_data_count
		screening_data.count
	end

	def self.expected_column_names
		@expected_column_names ||= ( ScreeningDatum.attribute_names - 
			%w( id screening_datum_update_id study_subject_id created_at updated_at ))
	end

	def expected_column_names
		ScreeningDatumUpdate.expected_column_names
	end

end
