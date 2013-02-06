class ChangeAbstractsCytogenT119FromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_t119, :integer
	end

	def down
		change_column :abstracts, :cytogen_t119, :string, :limit => 9
	end
end
