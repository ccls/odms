class CreateGuides < ActiveRecord::Migration
	def self.up
		create_table :guides do |t|
			t.string :controller
			t.string :action
			t.text :body
			t.timestamps
		end
		add_index :guides, [:controller,:action], :unique => true
	end

	def self.down
		drop_table :guides
	end
end
