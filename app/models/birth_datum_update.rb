require 'csv'
#
#	The BirthDatumUpdate#csv_file comes from USC
#	It contains birth record info on existing case and new
#	potential control subjects.
#
class BirthDatumUpdate < ActiveRecord::Base

	has_attached_file :csv_file,
		YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(Rails.root,'config/birth_datum_update.yml')
		))).result)[Rails.env]

	has_many :birth_data

	has_many :odms_exceptions, :as => :exceptable

	validates_attachment_presence     :csv_file

	validates_inclusion_of :csv_file_content_type,
		:in => ["text/csv","text/plain","application/vnd.ms-excel"],
		:allow_blank => true

#	perhaps by file extension rather than mime type?
#	validates_format_of :csv_file_file_name,
#		:with => %r{\.csv$}i,
#		:allow_blank => true



#	Temporarily don't do this
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
					) unless (expected_column_names + %w(
						ignore1 ignore2 ignore3
						)).include?(column_name)
#					) unless expected_column_names.include?(column_name)
			end
#
#	TODO what about missing columns???
#
		end
	end

	def parse_csv_file
		unless self.csv_file_file_name.blank?
			csv_file_path = self.csv_file.queued_for_write[:original].path
			unless csv_file_path.nil?
				line_count = 0
				(f=CSV.open( csv_file_path, 'rb',{
						:headers => true })).each do |line|
					line_count += 1

					birth_datum_attributes = line.dup.to_hash

					#	remove any unexpected attribute which would cause create failure
					line.headers.each do |h|
						birth_datum_attributes.delete(h) unless expected_column_names.include?(h)
					end

					birth_datum = self.birth_data.create( birth_datum_attributes )
					if birth_datum.new_record?
						odms_exceptions.create({
							:name        => "birth_data append",
							:description => "Record failed to save",
							:notes       => line
						})	#	the line could be too long, so put in notes section
					end	#	if birth_datum.new_record?
				end	#	(f=CSV.open( self.csv_file.path, 'rb',{ :headers => true })).each
				if line_count != birth_data_count
					odms_exceptions.create({
						:name        => "birth_data append",
						:description => "Birth data upload validation failed: " <<
							"incorrect number of birth data records appended to birth_data."
					})
				end	#	if line_count != birth_data_count
			end	#	unless csv_file_path.nil?
		end	#	unless self.csv_file_file_name.blank?
	end	#	def parse_csv_file

	#	separated purely to allow stubbing in testing
	#	I can't seem to find a way to stub 'birth_data.count'
	def birth_data_count
		birth_data.count
	end

	def self.expected_column_names
		@expected_column_names ||= ( BirthDatum.attribute_names - %w( id birth_datum_update_id study_subject_id created_at updated_at ))
	end

	def expected_column_names
		BirthDatumUpdate.expected_column_names
	end

end
