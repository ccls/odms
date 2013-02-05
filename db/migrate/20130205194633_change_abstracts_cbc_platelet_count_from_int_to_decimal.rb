class ChangeAbstractsCbcPlateletCountFromIntToDecimal < ActiveRecord::Migration
	def up
		change_column :abstracts, :cbc_platelet_count, :decimal, 
			:precision => 8, :scale => 2
	end

	def down
		change_column :abstracts, :cbc_platelet_count, :integer
	end
end
