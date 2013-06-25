class DropIcfMasterTrackers < ActiveRecord::Migration
	def up
		drop_table "icf_master_trackers"
	end

	def down
		create_table "icf_master_trackers" do |t|
			t.integer  "study_subject_id"
			t.boolean  "flagged_for_update", :default => false
			t.text     "last_update_attempt_errors"
			t.datetime "last_update_attempted_at"
			t.string   "master_id"
			t.string   "master_id_mother"
			t.string   "language"
			t.string   "record_owner"
			t.string   "record_status"
			t.string   "record_status_date"
			t.string   "date_received"
			t.string   "last_attempt"
			t.string   "last_disposition"
			t.string   "curr_phone"
			t.string   "record_sent_for_matching"
			t.string   "record_received_from_matching"
			t.string   "sent_pre_incentive"
			t.string   "released_to_cati"
			t.string   "confirmed_cati_contact"
			t.string   "refused"
			t.string   "deceased_notification"
			t.string   "is_eligible"
			t.string   "ineligible_reason"
			t.string   "confirmation_packet_sent"
			t.string   "cati_protocol_exhausted"
			t.string   "new_phone_released_to_cati"
			t.string   "plea_notification_sent"
			t.string   "case_returned_for_new_info"
			t.string   "case_returned_from_berkeley"
			t.string   "cati_complete"
			t.string   "kit_mother_sent"
			t.string   "kit_infant_sent"
			t.string   "kit_child_sent"
			t.string   "kid_adolescent_sent"
			t.string   "kit_mother_refused_code"
			t.string   "kit_child_refused_code"
			t.string   "no_response_to_plea"
			t.string   "response_received_from_plea"
			t.string   "sent_to_in_person_followup"
			t.string   "kit_mother_received"
			t.string   "kit_child_received"
			t.string   "thank_you_sent"
			t.string   "physician_request_sent"
			t.string   "physician_response_received"
			t.string   "vaccine_auth_received"
			t.string   "recollect"
			t.datetime "created_at", :null => false
			t.datetime "updated_at", :null => false
		end
		add_index "icf_master_trackers", ["master_id"], :name => "index_icf_master_trackers_on_master_id", :unique => true
	end
end
