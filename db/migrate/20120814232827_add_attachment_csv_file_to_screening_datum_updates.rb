class AddAttachmentCsvFileToScreeningDatumUpdates < ActiveRecord::Migration
	def self.up
		change_table :screening_datum_updates do |t|
			t.has_attached_file :csv_file
		end
	end

	def self.down
		drop_attached_file :screening_datum_updates, :csv_file
	end
end
