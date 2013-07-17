class ChangeAbstractsCsfWhiteBloodCountFromIntToDecimal < ActiveRecord::Migration
	def up
		change_column :abstracts, :csf_white_blood_count, :decimal,
			:precision => 8, :scale => 2
	end

	def down
		change_column :abstracts, :csf_white_blood_count, :integer
	end
end
