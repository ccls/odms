class DropSubjectRelationships < ActiveRecord::Migration
	def self.up
		drop_table :subject_relationships
		remove_column :interviews, :subject_relationship_id
		add_column  :interviews, :subject_relationship, :string
	end

	def self.down
		create_table :subject_relationships do |t|
			t.integer :position
			t.string  :key, :null => false
			t.string  :description, :null => false
			t.timestamps
		end
		add_index :subject_relationships, :key, :unique => true
		add_index :subject_relationships, :description, :unique => true
		add_column  :interviews, :subject_relationship_id, :integer
		remove_column :interviews, :subject_relationship
	end
end
