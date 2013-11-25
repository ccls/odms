class DropDataSources < ActiveRecord::Migration
	def up
		drop_table :data_sources
		remove_column :addressings, :data_source_id
		remove_column :phone_numbers, :data_source_id
	end

	def down
		create_table :data_sources do |t|
			t.integer  "position"
			t.string   "data_origin"
			t.string   "key",                :null => false
			t.string   "description",        :null => false
			t.integer  "organization_id"
			t.string   "other_organization"
			t.integer  "person_id"
			t.string   "other_person"
			t.datetime "created_at",         :null => false
			t.datetime "updated_at",         :null => false
		end
		add_index "data_sources", ["key"], :name => "index_data_sources_on_key", :unique => true
		add_column :addressings, :data_source_id, :integer
		add_column :phone_numbers, :data_source_id, :integer
	end
end
