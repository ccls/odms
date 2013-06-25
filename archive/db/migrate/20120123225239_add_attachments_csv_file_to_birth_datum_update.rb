class AddAttachmentsCsvFileToBirthDatumUpdate < ActiveRecord::Migration
	def self.up
		add_column :birth_datum_updates, :csv_file_file_name, :string
		add_column :birth_datum_updates, :csv_file_content_type, :string
		add_column :birth_datum_updates, :csv_file_file_size, :integer
		add_column :birth_datum_updates, :csv_file_updated_at, :datetime
	end

	def self.down
		remove_column :birth_datum_updates, :csv_file_file_name
		remove_column :birth_datum_updates, :csv_file_content_type
		remove_column :birth_datum_updates, :csv_file_file_size
		remove_column :birth_datum_updates, :csv_file_updated_at
	end
end
