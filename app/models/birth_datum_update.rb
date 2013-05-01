#
#	The BirthDatumUpdate#csv_file comes from USC
#	It contains birth record info on existing case and new
#	potential control subjects.
#
class BirthDatumUpdate < CSVFile

	attr_accessor :birth_data

	def initialize(csv_file,options={})
		super
		self.birth_data = []
		self.parse_csv_file unless self.options[:no_parse]
	end

	def parse_csv_file
		puts "Processing #{csv_file}..." if verbose
		%w( master_id ).each do |column|
			unless actual_columns.include?(column)
				Notification.plain(
					"Birth Data missing #{column} column. Skipping.\n",
					:subject => "ODMS: Birth Data missing #{column} column"
				).deliver
				abort( "Birth Data missing #{column} column." )
			end
		end

		study_subjects = []
		#
		#	Created and using the :debom converter as Janice's files seem to come with one.
		#	For some reason not always?
		#
		(f=CSV.open( csv_file, 'rb:bom|utf-8',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno} of #{total_lines}" if verbose

			birth_datum_attributes = line.dup.to_hash
			birth_datum_attributes.delete('ignore1')
			birth_datum_attributes.delete('ignore2')
			birth_datum_attributes.delete('ignore3')
			birth_datum_attributes.delete('first_name_again')


#			birth_datum_attributes['dob'] ||= birth_datum_attributes['case_dob'] 
#if birth_datum_attributes['dob'].blank?


#			#	remove any unexpected attribute which would cause create failure
#
#	it would also cause the loss of new attribute data.
#
#			line.headers.each do |h|
#				birth_datum_attributes.delete(h) unless expected_column_names.include?(h)
#			end

			birth_datum_attributes[:birth_data_file_name] = csv_file

			self.birth_data << BirthDatum.create!( birth_datum_attributes )

			if self.birth_data.last.new_record?	#	save failed?
#	FAIL 
#				odms_exceptions.create({
#					:name        => "birth_data append",
#					:description => "Record failed to save",
#					:notes       => line
#				})	#	the line could be too long, so put in notes section
			end	#	if birth_datum.new_record?

#
#	birth data associated with controls won't have a study subject
#
#			puts( self.birth_data.last.study_subject )
#			study_subjects.push( self.birth_data.last.study_subject )

		end	#	(f=CSV.open( self.csv_file, 'rb',{ :headers => true })).each

		Notification.updates_from_birth_data( csv_file, birth_data ).deliver

		#	TODO archive it?

	end	#	def parse_csv_file

	def archive
	end

	def self.expected_column_names
		@expected_column_names ||= ( BirthDatum.attribute_names - 
			%w( id birth_datum_update_id study_subject_id created_at updated_at ))
	end

	def expected_column_names
		BirthDatumUpdate.expected_column_names
	end

end
