class ChangeAbstractsDiagnosisIsOtherFromIntToString < ActiveRecord::Migration
	def up
		change_column :abstracts, :diagnosis_is_other, :string, :limit => 50
	end

	def down
		change_column :abstracts, :diagnosis_is_other, :integer
	end
end
