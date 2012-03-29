class CreateIcfMasterTrackers < ActiveRecord::Migration
	def self.up
		create_table :icf_master_trackers do |t|
			t.integer  :study_subject_id
			t.boolean  :flagged_for_update, :default => false
			t.text     :last_update_attempt_errors
			t.datetime :last_update_attempted_at

#	version 20110329
#			t.string :master_id
#			t.string :master_id_mother
#			t.string :language
#			t.string :record_owner
#			t.string :record_status
#			t.string :record_status_date
#			t.string :date_received
#			t.string :last_attempt
#			t.string :last_disposition
#			t.string :curr_phone
#			t.string :record_sent_for_matching
#			t.string :record_received_from_matching
#			t.string :sent_pre_incentive
#			t.string :released_to_cati
#			t.string :confirmed_cati_contact
#			t.string :refused
#			t.string :deceased_notification
#			t.string :is_eligible
#			t.string :ineligible_reason
#			t.string :confirmation_packet_sent
#			t.string :cati_protocol_exhausted
#			t.string :new_phone_released_to_cati
#			t.string :plea_notification_sent
#			t.string :case_returned_for_new_info
#			t.string :case_returned_from_berkeley
#			t.string :cati_complete
#			t.string :kit_mother_sent
#			t.string :kit_infant_sent
#			t.string :kit_child_sent
#			t.string :kid_adolescent_sent
#			t.string :kit_mother_refused_code
#			t.string :kit_child_refused_code
#			t.string :no_response_to_plea
#			t.string :response_received_from_plea
#			t.string :sent_to_in_person_followup
#			t.string :kit_mother_received
#			t.string :kit_child_received
#			t.string :thank_you_sent
#			t.string :physician_request_sent
#			t.string :physician_response_received
#			t.string :vaccine_auth_received
#			t.string :recollect

#	version 20120117
			t.string :Masterid
			t.string :Motherid
			t.string :Record_Owner
			t.string :Datereceived
			t.string :Lastatt
			t.string :Lastdisp
			t.string :Currphone
			t.string :Vacauthrecd
			t.string :Recollect
			t.string :Needpreincentive
			t.string :Active_Phone
			t.string :Recordsentformatching
			t.string :Recordreceivedfrommatching
			t.string :Sentpreincentive
			t.string :Releasedtocati
			t.string :Confirmedcaticontact
			t.string :Refused
			t.string :Deceasednotification
			t.string :Eligible
			t.string :Confirmationpacketsent
			t.string :Catiprotocolexhausted
			t.string :Newphonenumreleasedtocati
			t.string :Pleanotificationsent
			t.string :Casereturnedtoberkeleyfornewinf
			t.string :Casereturnedfromberkeley
			t.string :Caticomplete
			t.string :Kitmothersent
			t.string :Kitinfantsent
			t.string :Kitchildsent
			t.string :Kitadolescentsent
			t.string :Kitmotherrefusedcode
			t.string :Kitchildrefusedcode
			t.string :Noresponsetoplea
			t.string :Responsereceivedfromplea
			t.string :Senttoinpersonfollowup
			t.string :Kitmotherrecd
			t.string :Kitchildrecvd
			t.string :Thankyousent
			t.string :Physrequestsent
			t.string :Physresponsereceived

			t.timestamps
		end
		add_index :icf_master_trackers, :Masterid, :unique => true
	end

	def self.down
		drop_table :icf_master_trackers
	end
end
