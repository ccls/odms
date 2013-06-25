class DropVitalStatuses < ActiveRecord::Migration

  def up
  	drop_table "vital_statuses"
  end

  def down
		create_table "vital_statuses" do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.integer  "code"
			t.string   "description", :null => false
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end

		add_index "vital_statuses", ["code"], 
			:name => "index_vital_statuses_on_code", :unique => true
		add_index "vital_statuses", ["key"], 
			:name => "index_vital_statuses_on_key", :unique => true
  end

end
