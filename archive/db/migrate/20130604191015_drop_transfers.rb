class DropTransfers < ActiveRecord::Migration
	def up
		drop_table "transfers"
	end

	def down
		create_table "transfers" do |t|
			t.integer  "position"
			t.integer  "aliquot_id"
			t.integer  "from_organization_id", :null => false
			t.integer  "to_organization_id",   :null => false
			t.decimal  "amount",               :precision => 8, :scale => 2
			t.string   "reason"
			t.boolean  "is_permanent"
			t.datetime "created_at", :null => false
			t.datetime "updated_at", :null => false
		end

		add_index "transfers", ["aliquot_id"], 
			:name => "index_transfers_on_aliquot_id"
		add_index "transfers", ["from_organization_id"], 
			:name => "index_transfers_on_from_organization_id"
		add_index "transfers", ["to_organization_id"], 
			:name => "index_transfers_on_to_organization_id"
	end
end
