class ModifyAbstractDecimalColumns < ActiveRecord::Migration
	def up
		change_column :abstracts, :cbc_white_blood_count, :decimal,
			:precision => 8, :scale => 2
		change_column :abstracts, :cbc_hemoglobin_level, :decimal,
			:precision => 8, :scale => 2
	end

	def down
		change_column :abstracts, :cbc_white_blood_count, :decimal,
			:precision => 10, :scale => 0
		change_column :abstracts, :cbc_hemoglobin_level, :decimal,
			:precision => 10, :scale => 0
	end
end
