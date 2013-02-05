class ModifyBirthDataDecimalColumns < ActiveRecord::Migration
	def up
		change_column :birth_data, :birth_weight_gms, :decimal,
			:precision => 8, :scale => 2
	end

	def down
		change_column :birth_data, :birth_weight_gms, :decimal,
			:precision => 10, :scale => 0
	end
end
