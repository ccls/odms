class AddMoreLegacyColumnsToAbstracts < ActiveRecord::Migration
	def change
		add_column :abstracts, :abstracted_by, :integer, :limit => 2
		add_column :abstracts, :reviewed_by, :integer, :limit => 2
		add_column :abstracts, :data_entry_by, :integer, :limit => 2
		add_column :abstracts, :abstract_version_number, :integer, :limit => 2
		add_column :abstracts, :created_by, :string, :limit => 20
	end
end
