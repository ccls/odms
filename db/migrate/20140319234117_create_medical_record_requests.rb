class CreateMedicalRecordRequests < ActiveRecord::Migration
	def change
		create_table :medical_record_requests do |t|
			t.integer :study_subject_id
			t.date :sent_on
			t.date :returned_on
			t.boolean :is_found
			t.string :status
			t.text :notes
			t.string :request_type
			t.timestamps
		end
	end
end
