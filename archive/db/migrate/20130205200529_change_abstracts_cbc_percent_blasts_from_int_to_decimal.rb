class ChangeAbstractsCbcPercentBlastsFromIntToDecimal < ActiveRecord::Migration
	def up
		change_column :abstracts, :cbc_percent_blasts, :decimal,
			:precision => 6, :scale => 2
	end

	def down
		change_column :abstracts, :cbc_percent_blasts, :integer
	end
end
