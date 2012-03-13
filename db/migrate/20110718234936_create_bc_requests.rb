class CreateBcRequests < ActiveRecord::Migration
	def self.up
		create_table :bc_requests do |t|
			t.integer :study_subject_id
			t.date    :sent_on
			t.string  :status
			t.text    :notes
			t.string  :request_type
			t.timestamps
		end
	end

	def self.down
		drop_table :bc_requests
	end
end
