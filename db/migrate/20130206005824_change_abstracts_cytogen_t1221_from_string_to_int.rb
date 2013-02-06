class ChangeAbstractsCytogenT1221FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_t1221, :integer
	end

	def down
		change_column :abstracts, :cytogen_t1221, :string, :limit => 9
	end
end
