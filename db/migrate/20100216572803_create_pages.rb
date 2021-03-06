class CreatePages < ActiveRecord::Migration
	def self.up
		create_table :pages do |t|
			t.integer :position
			t.integer :parent_id
			t.boolean :hide_menu, :default => false
			t.string :path
			t.string :title_en
			t.string :title_es
			t.string :menu_en
			t.string :menu_es
			t.text :body_en
			t.text :body_es
			t.timestamps
		end
		add_index :pages, :path, :unique => true
		add_index :pages, :parent_id
	end

	def self.down
		drop_table :pages
	end
end
