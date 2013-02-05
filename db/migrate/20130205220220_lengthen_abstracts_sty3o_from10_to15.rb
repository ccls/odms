class LengthenAbstractsSty3oFrom10To15 < ActiveRecord::Migration
	def up
		change_column :abstracts, :sty3o, :string, :limit => 15
	end

	def down
		change_column :abstracts, :sty3o, :string, :limit => 10
	end
end
