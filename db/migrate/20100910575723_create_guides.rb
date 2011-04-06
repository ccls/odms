class CreateGuides < ActiveRecord::Migration
	def self.up
		table_name = 'guides'
		create_table table_name do |t|
			t.string :controller
			t.string :action
			t.text :body
			t.timestamps
		end unless table_exists?(table_name)
		idxs = indexes(table_name).map(&:name)
		add_index( table_name, [:controller,:action], :unique => true
			) unless idxs.include?("index_#{table_name}_on_controller_and_action")
	end

	def self.down
		drop_table :guides
	end
end
