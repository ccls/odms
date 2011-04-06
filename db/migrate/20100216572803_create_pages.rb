class CreatePages < ActiveRecord::Migration
	def self.up
		table_name = 'pages'
		create_table table_name do |t|
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
		end unless table_exists?(table_name)
		idxs = indexes(table_name).map(&:name)
		add_index( table_name, :path, :unique => true
			) unless idxs.include?("index_#{table_name}_on_path")
		add_index( table_name, :parent_id
			) unless idxs.include?("index_#{table_name}_on_parent_id")
#	acts_as_list doesn't like the uniqueness
#	when it reorders, positions are temporarily not unique
#		add_index :pages, :position, :unique => true, :name => 'by_position'
	end

	def self.down
		drop_table :pages
	end
end
