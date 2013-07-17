class ChangeAbstractsIsCytogenHospFishT1221DoneFromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :is_cytogen_hosp_fish_t1221_done, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :is_cytogen_hosp_fish_t1221_done, :string, :limit => 5
	end
end
