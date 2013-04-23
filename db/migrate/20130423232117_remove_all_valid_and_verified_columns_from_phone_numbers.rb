class RemoveAllValidAndVerifiedColumnsFromPhoneNumbers < ActiveRecord::Migration
	def up
		change_table "phone_numbers" do |t|
			t.remove "is_valid"
			t.remove "why_invalid"
			t.remove "is_verified"
			t.remove "how_verified"
			t.remove "verified_on"
			t.remove "verified_by_uid"
		end
	end

	def down
		change_table "phone_numbers" do |t|
			t.integer "is_valid"
			t.string  "why_invalid"
			t.boolean "is_verified"
			t.string  "how_verified"
			t.date    "verified_on"
			t.string  "verified_by_uid"
		end
	end
end
