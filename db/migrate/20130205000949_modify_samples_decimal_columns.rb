class ModifySamplesDecimalColumns < ActiveRecord::Migration
	def up
		change_column :samples, :quantity_in_sample, :decimal,
			:precision => 8, :scale => 2
	end

	def down
		change_column :samples, :quantity_in_sample, :decimal,
			:precision => 10, :scale => 0
	end
end
