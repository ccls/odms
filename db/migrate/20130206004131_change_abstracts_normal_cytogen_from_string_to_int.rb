class ChangeAbstractsNormalCytogenFromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :normal_cytogen, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :normal_cytogen, :string, :limit => 5
	end
end
