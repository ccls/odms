class RemoveAllValidAndVerifiedColumnsFromAddressings < ActiveRecord::Migration
	def up
		change_table :addressings do |t|
			t.remove "valid_from"
			t.remove "valid_to"
			t.remove "is_valid"
			t.remove "why_invalid"
			t.remove "is_verified"
			t.remove "how_verified"
			t.remove "verified_on"
			t.remove "verified_by_uid"
		end
	end

	def down
		change_table :addressings do |t|
			t.date    "valid_from"
			t.date    "valid_to"
			t.integer "is_valid"
			t.string  "why_invalid"
			t.boolean "is_verified"
			t.string  "how_verified"
			t.date    "verified_on"
			t.string  "verified_by_uid"
		end
	end
end
