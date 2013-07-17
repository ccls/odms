class ConvertSomeAbstractStringFieldsToTextFields < ActiveRecord::Migration
	def up
		change_column :abstracts, :conventional_karyotype_results, :text
		change_column :abstracts, :hospital_fish_results, :text
	end

	def down
		change_column :abstracts, :conventional_karyotype_results, :string
		change_column :abstracts, :hospital_fish_results, :string
	end
end
