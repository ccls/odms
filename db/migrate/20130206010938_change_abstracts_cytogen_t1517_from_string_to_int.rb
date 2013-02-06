class ChangeAbstractsCytogenT1517FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_t1517, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :cytogen_t1517, :string, :limit => 9
	end
end
