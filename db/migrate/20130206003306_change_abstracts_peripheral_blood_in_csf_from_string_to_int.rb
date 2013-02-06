class ChangeAbstractsPeripheralBloodInCsfFromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :peripheral_blood_in_csf, :integer
	end

	def down
		change_column :abstracts, :peripheral_blood_in_csf, :string
	end
end
