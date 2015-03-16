class DropDocumentTypes < ActiveRecord::Migration
	def self.down
		create_table :document_types do |t|
			t.integer :position
			t.string  :key, :null => false
			t.string  :title
			t.string  :description
			t.timestamps
		end
		add_index :document_types, :key, :unique => true
	end

	def self.up
		drop_table :document_types
	end
end
