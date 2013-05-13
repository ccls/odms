class AddCclsImportNotesToBirthData < ActiveRecord::Migration
	def change
		add_column :birth_data, :ccls_import_notes, :text
	end
end
