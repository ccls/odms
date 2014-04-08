class RemoveRequestTypeFromMedicalRecordRequest < ActiveRecord::Migration
	def change
		remove_column :medical_record_requests, :request_type
	end
end
