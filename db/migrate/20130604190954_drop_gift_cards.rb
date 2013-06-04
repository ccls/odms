class DropGiftCards < ActiveRecord::Migration
	def up
		drop_table "gift_cards"
	end

	def down
		create_table "gift_cards" do |t|
			t.integer  "study_subject_id"
			t.integer  "project_id"
			t.date     "issued_on"
			t.string   "expiration", :limit => 25
			t.string   "vendor"
			t.string   "number",     :null => false
			t.datetime "created_at", :null => false
			t.datetime "updated_at", :null => false
		end

		add_index "gift_cards", ["number"], 
			:name => "index_gift_cards_on_number", :unique => true
	end
end
