class ModifyTransferDecimalColumns < ActiveRecord::Migration
	def up
		change_column :transfers, :amount, :decimal,
			:precision => 8, :scale => 2
	end

	def down
		change_column :transfers, :amount, :decimal,
			:precision => 10, :scale => 0
	end
end
