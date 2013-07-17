class LengthenAbstractsSty3pFrom10To15 < ActiveRecord::Migration
	def up
		change_column :abstracts, :sty3p, :string, :limit => 15
	end

	def down
		change_column :abstracts, :sty3p, :string, :limit => 10
	end
end
