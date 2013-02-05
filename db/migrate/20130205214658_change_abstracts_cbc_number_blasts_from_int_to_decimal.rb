class ChangeAbstractsCbcNumberBlastsFromIntToDecimal < ActiveRecord::Migration
	def up
		change_column :abstracts, :cbc_number_blasts, :decimal,
			:precision => 8, :scale => 2
	end

	def down
		change_column :abstracts, :cbc_number_blasts, :integer
	end
end
